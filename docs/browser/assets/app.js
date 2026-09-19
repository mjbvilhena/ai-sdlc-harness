(function () {
  "use strict";

  var CACHE_PREFIX = "sdlc-docs-v1:";
  var SKILL_FILE_RE = /^skills\/([^/]+)\/(skill\.yaml|CONTENT\.md)$/;
  var DATA_FILE_RE = /^mcp-server\/data\/([^/]+)\/([^/]+\.md)$/;
  var DIR_LABELS = {
    templates: "Templates",
    dod: "Definitions of Done"
  };

  var params = new URLSearchParams(window.location.search);
  var base = window.DOCS_CONFIG || {};
  var config = {
    owner: params.get("owner") || base.owner || "mjbvilhena",
    repo: params.get("repo") || base.repo || "ai-sdlc-harness",
    ref: params.get("ref") || base.ref || "master"
  };

  var main = document.getElementById("main");
  var nav = document.getElementById("site-nav");
  var sourceLine = document.getElementById("source-line");
  var catalogPromise = null;

  function apiUrl(pathAndQuery) {
    return "https://api.github.com/repos/" + config.owner + "/" + config.repo + pathAndQuery;
  }

  function rawUrl(path) {
    var encoded = path.split("/").map(encodeURIComponent).join("/");
    return "https://raw.githubusercontent.com/" + config.owner + "/" + config.repo + "/" +
      encodeURIComponent(config.ref) + "/" + encoded;
  }

  function githubBlobUrl(path) {
    return "https://github.com/" + config.owner + "/" + config.repo + "/blob/" +
      encodeURIComponent(config.ref) + "/" + path;
  }

  function cacheKey(kind, extra) {
    return CACHE_PREFIX + config.owner + "/" + config.repo + "@" + config.ref + ":" + kind +
      (extra ? ":" + extra : "");
  }

  function readCache(kind, extra) {
    try {
      var raw = sessionStorage.getItem(cacheKey(kind, extra));
      return raw ? JSON.parse(raw) : null;
    } catch (err) {
      return null;
    }
  }

  function writeCache(kind, extra, value) {
    try {
      sessionStorage.setItem(cacheKey(kind, extra), JSON.stringify(value));
    } catch (err) {
      /* quota / private mode — ignore */
    }
  }

  function escapeHtml(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function unquote(value) {
    var text = String(value || "").trim();
    if ((text.charAt(0) === "\"" && text.charAt(text.length - 1) === "\"") ||
        (text.charAt(0) === "'" && text.charAt(text.length - 1) === "'")) {
      return text.slice(1, -1);
    }
    return text;
  }

  function parseSimpleYaml(text) {
    var data = {};
    var listKey = null;
    var lines = String(text || "").split(/\r?\n/);
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].replace(/\t/g, "  ");
      var trimmed = line.trim();
      if (!trimmed || trimmed.charAt(0) === "#") {
        continue;
      }
      var listItem = line.match(/^\s*-\s+(.*)$/);
      if (listItem && listKey) {
        data[listKey].push(unquote(listItem[1].replace(/\s+#.*$/, "")));
        continue;
      }
      var kv = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
      if (!kv) {
        continue;
      }
      var key = kv[1];
      var val = kv[2];
      if (val === "" || val === "|" || val === ">") {
        data[key] = [];
        listKey = key;
        continue;
      }
      if (val.charAt(0) === "\"" || val.charAt(0) === "'") {
        data[key] = unquote(val);
      } else {
        data[key] = unquote(val.replace(/\s+#.*$/, ""));
      }
      listKey = null;
    }
    return data;
  }

  function asList(value) {
    if (Array.isArray(value)) {
      return value.filter(Boolean);
    }
    if (value == null || value === "") {
      return [];
    }
    return [String(value)];
  }

  function labelForDir(dir) {
    return DIR_LABELS[dir] || dir.replace(/[_-]+/g, " ").replace(/\b\w/g, function (ch) {
      return ch.toUpperCase();
    });
  }

  function logicalName(stem) {
    return stem.replace(/[-_]+/g, " ");
  }

  function isRateLimited(status) {
    return status === 403 || status === 429;
  }

  function rateLimitMessage() {
    return "GitHub API rate limit reached for unauthenticated traffic. " +
      "The catalog uses the git tree API (one request) and caches it in sessionStorage. " +
      "Wait a few minutes and refresh, or retry from a less busy network.";
  }

  async function githubFetch(url) {
    var res = await fetch(url, {
      headers: { Accept: "application/vnd.github+json" }
    });
    if (isRateLimited(res.status)) {
      var err = new Error(rateLimitMessage());
      err.code = "rate-limit";
      throw err;
    }
    if (!res.ok) {
      throw new Error("GitHub API " + res.status + " for " + url);
    }
    return res.json();
  }

  async function listDirectory(path) {
    var data = await githubFetch(
      apiUrl("/contents/" + path.split("/").map(encodeURIComponent).join("/") +
        "?ref=" + encodeURIComponent(config.ref))
    );
    return Array.isArray(data) ? data : [];
  }

  async function walkCatalogPaths() {
    var paths = [];
    var skillDirs = await listDirectory("skills");
    for (var i = 0; i < skillDirs.length; i++) {
      if (skillDirs[i].type !== "dir") {
        continue;
      }
      var files = await listDirectory("skills/" + skillDirs[i].name);
      for (var j = 0; j < files.length; j++) {
        if (files[j].type === "file") {
          paths.push(files[j].path);
        }
      }
    }
    var dataDirs = await listDirectory("mcp-server/data");
    for (var d = 0; d < dataDirs.length; d++) {
      if (dataDirs[d].type !== "dir") {
        continue;
      }
      var docs = await listDirectory("mcp-server/data/" + dataDirs[d].name);
      for (var k = 0; k < docs.length; k++) {
        if (docs[k].type === "file") {
          paths.push(docs[k].path);
        }
      }
    }
    return paths;
  }

  async function fetchPathList() {
    var cached = readCache("tree");
    if (cached && Array.isArray(cached.paths)) {
      return { paths: cached.paths, fromCache: true };
    }
    try {
      var tree = await githubFetch(
        apiUrl("/git/trees/" + encodeURIComponent(config.ref) + "?recursive=1")
      );
      var paths = [];
      var entries = tree.tree || [];
      for (var i = 0; i < entries.length; i++) {
        if (entries[i].type === "blob" && entries[i].path) {
          paths.push(entries[i].path);
        }
      }
      if (tree.truncated) {
        paths = await walkCatalogPaths();
      }
      writeCache("tree", null, { paths: paths });
      return { paths: paths, fromCache: false };
    } catch (err) {
      if (err.code === "rate-limit") {
        throw err;
      }
      try {
        var walked = await walkCatalogPaths();
        writeCache("tree", null, { paths: walked });
        return { paths: walked, fromCache: false };
      } catch (inner) {
        throw err;
      }
    }
  }

  function catalogFromPaths(paths) {
    var skills = {};
    var dataDirs = {};
    for (var i = 0; i < paths.length; i++) {
      var path = paths[i];
      var skillMatch = path.match(SKILL_FILE_RE);
      if (skillMatch) {
        var name = skillMatch[1];
        if (!skills[name]) {
          skills[name] = { name: name, yamlPath: null, contentPath: null };
        }
        if (skillMatch[2] === "skill.yaml") {
          skills[name].yamlPath = path;
        } else {
          skills[name].contentPath = path;
        }
        continue;
      }
      var dataMatch = path.match(DATA_FILE_RE);
      if (dataMatch) {
        var dir = dataMatch[1];
        var file = dataMatch[2];
        if (!dataDirs[dir]) {
          dataDirs[dir] = [];
        }
        dataDirs[dir].push({
          dir: dir,
          file: file,
          path: path,
          slug: file.replace(/\.md$/i, ""),
          title: logicalName(file.replace(/\.md$/i, ""))
        });
      }
    }
    var skillList = Object.keys(skills).map(function (key) {
      return skills[key];
    }).filter(function (item) {
      return item.yamlPath || item.contentPath;
    }).sort(function (a, b) {
      return a.name.localeCompare(b.name);
    });
    var dirNames = Object.keys(dataDirs).sort();
    dirNames.forEach(function (dir) {
      dataDirs[dir].sort(function (a, b) {
        return a.slug.localeCompare(b.slug);
      });
    });
    return { skills: skillList, dataDirs: dataDirs, dirNames: dirNames };
  }

  async function fetchText(path) {
    var cached = readCache("file", path);
    if (typeof cached === "string") {
      return cached;
    }
    var res = await fetch(rawUrl(path));
    if (isRateLimited(res.status)) {
      var err = new Error(rateLimitMessage());
      err.code = "rate-limit";
      throw err;
    }
    if (!res.ok) {
      throw new Error("Could not read " + path + " (" + res.status + ")");
    }
    var text = await res.text();
    writeCache("file", path, text);
    return text;
  }

  async function loadSkillMeta(skill) {
    if (!skill.yamlPath) {
      skill.meta = { name: skill.name, description: "", targets: [], triggers: [] };
      return skill;
    }
    try {
      var yaml = await fetchText(skill.yamlPath);
      var parsed = parseSimpleYaml(yaml);
      skill.meta = {
        name: parsed.name || skill.name,
        description: parsed.description || "",
        version: parsed.version || "",
        author: parsed.author || "",
        targets: asList(parsed.targets),
        triggers: asList(parsed.triggers)
      };
    } catch (err) {
      skill.meta = { name: skill.name, description: "", targets: [], triggers: [], error: err.message };
    }
    return skill;
  }

  async function hydrateSkills(skills) {
    var queue = skills.slice();
    var workers = [];
    function next() {
      if (!queue.length) {
        return Promise.resolve();
      }
      var item = queue.shift();
      return loadSkillMeta(item).then(next);
    }
    for (var i = 0; i < Math.min(6, queue.length); i++) {
      workers.push(next());
    }
    await Promise.all(workers);
    return skills;
  }

  async function loadCatalog() {
    if (!catalogPromise) {
      catalogPromise = (async function () {
        var listed = await fetchPathList();
        var catalog = catalogFromPaths(listed.paths);
        catalog.fromCache = listed.fromCache;
        await hydrateSkills(catalog.skills);
        return catalog;
      })();
    }
    return catalogPromise;
  }

  function preprocessMarkdown(text) {
    return String(text || "").replace(/^(\s*)[-*] \[([ xX])\] /gm, function (_, indent, mark) {
      return indent + "- " + (mark.trim() ? "[x] " : "[ ] ");
    });
  }

  function renderMarkdown(text) {
    var html;
    if (typeof marked !== "undefined") {
      if (typeof marked.setOptions === "function") {
        marked.setOptions({ gfm: true, headerIds: true, mangle: false });
      }
      html = typeof marked.parse === "function" ? marked.parse(preprocessMarkdown(text)) : marked(preprocessMarkdown(text));
      html = html.replace(/<li>\[( |x|X)\] /g, function (_, mark) {
        var checked = mark.toLowerCase() === "x" ? " checked" : "";
        return "<li class=\"task\"><input type=\"checkbox\" disabled" + checked + "> ";
      });
    } else {
      html = "<pre>" + escapeHtml(text) + "</pre>";
    }
    return sanitizeHtml(html);
  }

  function sanitizeHtml(html) {
    var doc = new DOMParser().parseFromString("<div>" + html + "</div>", "text/html");
    var root = doc.body.firstElementChild;
    if (!root) {
      return "";
    }
    var banned = { SCRIPT: 1, IFRAME: 1, OBJECT: 1, EMBED: 1, LINK: 1, META: 1, FORM: 1, STYLE: 1 };
    function walk(node) {
      var children = Array.prototype.slice.call(node.children || []);
      for (var i = 0; i < children.length; i++) {
        var child = children[i];
        if (banned[child.tagName]) {
          child.remove();
          continue;
        }
        var attrs = Array.prototype.slice.call(child.attributes || []);
        for (var a = 0; a < attrs.length; a++) {
          var name = attrs[a].name.toLowerCase();
          var value = attrs[a].value || "";
          if (name.indexOf("on") === 0 || (name === "href" && /^\s*javascript:/i.test(value))) {
            child.removeAttribute(attrs[a].name);
          }
        }
        walk(child);
      }
    }
    walk(root);
    return root.innerHTML;
  }

  function parseRoute() {
    var hash = (window.location.hash || "#/").replace(/^#/, "");
    var parts = hash.split("/").filter(Boolean).map(decodeURIComponent);
    if (!parts.length) {
      return { page: "home" };
    }
    if (parts[0] === "skills") {
      if (parts[1]) {
        return { page: "skill", name: parts[1] };
      }
      return { page: "skills" };
    }
    if (parts[1]) {
      return { page: "doc", dir: parts[0], slug: parts[1] };
    }
    return { page: "data", dir: parts[0] };
  }

  function navHtml(catalog, route) {
    var items = [{ href: "#/", label: "Home", current: route.page === "home" }];
    items.push({
      href: "#/skills",
      label: "Skills",
      current: route.page === "skills" || route.page === "skill"
    });
    (catalog && catalog.dirNames ? catalog.dirNames : []).forEach(function (dir) {
      items.push({
        href: "#/" + encodeURIComponent(dir),
        label: labelForDir(dir),
        current: (route.page === "data" || route.page === "doc") && route.dir === dir
      });
    });
    return items.map(function (item) {
      return "<a href=\"" + item.href + "\"" +
        (item.current ? " aria-current=\"page\"" : "") + ">" + escapeHtml(item.label) + "</a>";
    }).join("");
  }

  function searchBox(placeholder) {
    return "<div class=\"search-row\">" +
      "<label class=\"muted\" for=\"catalog-filter\">Filter</label><br>" +
      "<input id=\"catalog-filter\" type=\"search\" placeholder=\"" + escapeHtml(placeholder) + "\" autocomplete=\"off\">" +
      "</div>";
  }

  function bindFilter() {
    var input = document.getElementById("catalog-filter");
    if (!input) {
      return;
    }
    var cards = Array.prototype.slice.call(document.querySelectorAll("[data-search]"));
    function apply() {
      var q = input.value.trim().toLowerCase();
      var shown = 0;
      cards.forEach(function (card) {
        var match = !q || (card.getAttribute("data-search") || "").indexOf(q) !== -1;
        card.classList.toggle("hidden", !match);
        if (match) {
          shown += 1;
        }
      });
      var empty = document.getElementById("filter-empty");
      if (empty) {
        empty.classList.toggle("hidden", shown > 0);
      }
    }
    input.addEventListener("input", apply);
  }

  function skillCard(skill) {
    var meta = skill.meta || {};
    var triggers = asList(meta.triggers);
    var search = [skill.name, meta.description, triggers.join(" "), asList(meta.targets).join(" ")]
      .join(" ").toLowerCase();
    return "<a class=\"card\" href=\"#/skills/" + encodeURIComponent(skill.name) + "\" data-search=\"" +
      escapeHtml(search) + "\">" +
      "<h3>" + escapeHtml(skill.name) + "</h3>" +
      "<p>" + escapeHtml(meta.description || "No description in skill.yaml") + "</p>" +
      (triggers.length ? "<div class=\"triggers\">" + escapeHtml(triggers.join(" · ")) + "</div>" : "") +
      "</a>";
  }

  function docCard(item) {
    var search = [item.slug, item.title, item.dir].join(" ").toLowerCase();
    return "<a class=\"card\" href=\"#/" + encodeURIComponent(item.dir) + "/" + encodeURIComponent(item.slug) +
      "\" data-search=\"" + escapeHtml(search) + "\">" +
      "<h3>" + escapeHtml(item.title) + "</h3>" +
      "<p class=\"muted\">" + escapeHtml(item.file) + "</p>" +
      "</a>";
  }

  function chips(values, plain) {
    return asList(values).map(function (value) {
      return "<span class=\"chip" + (plain ? " plain" : "") + "\">" + escapeHtml(value) + "</span>";
    }).join("");
  }

  function renderHome(catalog) {
    var sections = [
      "<h1>Catalog</h1>",
      "<p class=\"lede\">Lifecycle Driver skills and MCP knowledge files, listed from the live repository tree — not a hard-coded index.</p>",
      catalog.fromCache ? "<p class=\"banner\">Showing a session-cached tree. Refresh after the cache is cleared to force a new GitHub lookup.</p>" : "",
      searchBox("Search skills and documents"),
      "<p id=\"filter-empty\" class=\"empty hidden\">No items match that filter.</p>",
      "<h2>Skills (" + catalog.skills.length + ")</h2>",
      "<div class=\"card-grid\">" + catalog.skills.map(skillCard).join("") + "</div>"
    ];
    catalog.dirNames.forEach(function (dir) {
      var items = catalog.dataDirs[dir];
      sections.push("<h2>" + escapeHtml(labelForDir(dir)) + " (" + items.length + ")</h2>");
      sections.push("<div class=\"card-grid\">" + items.map(docCard).join("") + "</div>");
    });
    if (!catalog.skills.length && !catalog.dirNames.length) {
      sections.push("<p class=\"empty\">No skills or MCP data files were found on this ref.</p>");
    }
    main.innerHTML = sections.join("");
    bindFilter();
  }

  function renderSkillIndex(catalog) {
    main.innerHTML = [
      "<nav class=\"crumb\"><a href=\"#/\">Home</a> / Skills</nav>",
      "<h1>Skills</h1>",
      "<p class=\"lede\">Every directory under <code>skills/</code> that has <code>skill.yaml</code> or <code>CONTENT.md</code>.</p>",
      searchBox("Filter by name, description, or trigger"),
      "<p id=\"filter-empty\" class=\"empty hidden\">No skills match that filter.</p>",
      "<div class=\"card-grid\">" + catalog.skills.map(skillCard).join("") + "</div>"
    ].join("");
    bindFilter();
  }

  function renderDataIndex(catalog, dir) {
    var items = catalog.dataDirs[dir] || [];
    main.innerHTML = [
      "<nav class=\"crumb\"><a href=\"#/\">Home</a> / " + escapeHtml(labelForDir(dir)) + "</nav>",
      "<h1>" + escapeHtml(labelForDir(dir)) + "</h1>",
      "<p class=\"lede\">Markdown files discovered under <code>mcp-server/data/" + escapeHtml(dir) + "/</code>.</p>",
      searchBox("Filter by name"),
      "<p id=\"filter-empty\" class=\"empty hidden\">No documents match that filter.</p>",
      items.length
        ? "<div class=\"card-grid\">" + items.map(docCard).join("") + "</div>"
        : "<p class=\"empty\">No markdown files in this folder on the current ref.</p>"
    ].join("");
    bindFilter();
  }

  async function renderSkillDetail(catalog, name) {
    var skill = null;
    for (var i = 0; i < catalog.skills.length; i++) {
      if (catalog.skills[i].name === name) {
        skill = catalog.skills[i];
        break;
      }
    }
    if (!skill) {
      main.innerHTML = "<p class=\"banner error\">No skill named <code>" + escapeHtml(name) +
        "</code> on this ref. It may not exist yet on <code>" + escapeHtml(config.ref) + "</code>.</p>";
      return;
    }
    var meta = skill.meta || {};
    var body = "<p class=\"muted\">No <code>CONTENT.md</code> in this skill package.</p>";
    if (skill.contentPath) {
      try {
        body = "<div class=\"prose\">" + renderMarkdown(await fetchText(skill.contentPath)) + "</div>";
      } catch (err) {
        body = "<p class=\"banner error\">" + escapeHtml(err.message) + "</p>";
      }
    }
    main.innerHTML = [
      "<nav class=\"crumb\"><a href=\"#/\">Home</a> / <a href=\"#/skills\">Skills</a> / " + escapeHtml(skill.name) + "</nav>",
      "<h1>" + escapeHtml(meta.name || skill.name) + "</h1>",
      "<p class=\"lede\">" + escapeHtml(meta.description || "") + "</p>",
      "<div class=\"meta-line\">" +
        (meta.version ? "<span class=\"chip plain\">v" + escapeHtml(meta.version) + "</span>" : "") +
        chips(meta.targets) +
        chips(meta.triggers, true) +
        (meta.author ? "<span class=\"chip plain\">" + escapeHtml(meta.author) + "</span>" : "") +
      "</div>",
      "<p class=\"source-links\">" +
        (skill.yamlPath ? "<a href=\"" + githubBlobUrl(skill.yamlPath) + "\">skill.yaml</a> · " : "") +
        (skill.contentPath ? "<a href=\"" + githubBlobUrl(skill.contentPath) + "\">CONTENT.md</a>" : "") +
      "</p>",
      "<article class=\"article\">" + body + "</article>"
    ].join("");
  }

  async function renderDocDetail(catalog, dir, slug) {
    var items = catalog.dataDirs[dir] || [];
    var item = null;
    for (var i = 0; i < items.length; i++) {
      if (items[i].slug === slug) {
        item = items[i];
        break;
      }
    }
    if (!item) {
      main.innerHTML = "<p class=\"banner error\">No file <code>" + escapeHtml(slug) +
        ".md</code> under <code>mcp-server/data/" + escapeHtml(dir) + "/</code> on this ref.</p>";
      return;
    }
    var body;
    try {
      body = "<div class=\"prose\">" + renderMarkdown(await fetchText(item.path)) + "</div>";
    } catch (err) {
      body = "<p class=\"banner error\">" + escapeHtml(err.message) + "</p>";
    }
    main.innerHTML = [
      "<nav class=\"crumb\"><a href=\"#/\">Home</a> / <a href=\"#/" + encodeURIComponent(dir) + "\">" +
        escapeHtml(labelForDir(dir)) + "</a> / " + escapeHtml(item.title) + "</nav>",
      "<h1>" + escapeHtml(item.title) + "</h1>",
      "<p class=\"source-links\"><a href=\"" + githubBlobUrl(item.path) + "\">" + escapeHtml(item.path) + "</a></p>",
      "<article class=\"article\">" + body + "</article>"
    ].join("");
  }

  function renderError(err) {
    var extra = err && err.code === "rate-limit"
      ? "<p>If this tab loaded the tree earlier, try a refresh — sessionStorage may still have a cached inventory.</p>"
      : "<p>Check the network tab and that <code>" + escapeHtml(config.owner + "/" + config.repo) +
        "</code> is public on ref <code>" + escapeHtml(config.ref) + "</code>.</p>";
    main.innerHTML = "<div class=\"banner error\"><strong>Could not load catalog.</strong><br>" +
      escapeHtml(err && err.message ? err.message : String(err)) + extra + "</div>";
  }

  function renderNav(catalog, route) {
    nav.innerHTML = navHtml(catalog, route);
    if (sourceLine) {
      sourceLine.innerHTML = "Source: <a href=\"https://github.com/" + encodeURIComponent(config.owner) +
        "/" + encodeURIComponent(config.repo) + "/tree/" + encodeURIComponent(config.ref) + "\">" +
        escapeHtml(config.owner + "/" + config.repo) + "@" + escapeHtml(config.ref) + "</a>";
    }
  }

  async function render() {
    var route = parseRoute();
    document.title = "AI SDLC Harness — catalog";
    main.innerHTML = "<p class=\"banner\">Loading catalog from GitHub…</p>";
    renderNav(null, route);
    try {
      var catalog = await loadCatalog();
      renderNav(catalog, route);
      if (route.page === "home") {
        renderHome(catalog);
      } else if (route.page === "skills") {
        renderSkillIndex(catalog);
        document.title = "Skills — AI SDLC Harness";
      } else if (route.page === "skill") {
        await renderSkillDetail(catalog, route.name);
        document.title = route.name + " — AI SDLC Harness";
      } else if (route.page === "data") {
        renderDataIndex(catalog, route.dir);
        document.title = labelForDir(route.dir) + " — AI SDLC Harness";
      } else if (route.page === "doc") {
        await renderDocDetail(catalog, route.dir, route.slug);
        document.title = route.slug + " — AI SDLC Harness";
      }
    } catch (err) {
      renderError(err);
    }
  }

  window.addEventListener("hashchange", render);
  render();
})();

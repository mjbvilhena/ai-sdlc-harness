#!/usr/bin/env bash
# Shared helper for expanding {{SKILL_BODY}} / {{RULE_BODY}} from sibling CONTENT.md.
# Sourced by install/install_*.sh. Requires bash >= 3.2, cat, grep, mktemp.
# shellcheck shell=bash

placeholder_for_item() {
  local item_dir="$1"
  local parent
  parent="$(basename "$(dirname "$item_dir")")"
  if [[ "$parent" == "rules" ]]; then
    printf '%s\n' "{{RULE_BODY}}"
  else
    printf '%s\n' "{{SKILL_BODY}}"
  fi
}

assert_no_unresolved_placeholders() {
  local path="$1"
  if grep -qF '{{SKILL_BODY}}' "$path" || grep -qF '{{RULE_BODY}}' "$path"; then
    echo "Error: unresolved placeholder remains in ${path}. Refusing to install." >&2
    return 1
  fi
  return 0
}

validate_item_content() {
  local item_dir="$1"
  local item_name="$2"
  local source="$3"

  local content_file="${item_dir%/}/CONTENT.md"
  if [[ ! -f "$content_file" ]]; then
    echo "Error: ${item_name} is missing CONTENT.md (expected ${content_file})." >&2
    return 1
  fi

  local placeholder
  placeholder="$(placeholder_for_item "$item_dir")"
  if [[ -d "$source" ]]; then
    local found=false
    local src
    for src in "${source%/}"/*; do
      [[ -f "$src" ]] || continue
      if grep -qF "$placeholder" "$src"; then
        found=true
        break
      fi
    done
    if [[ "$found" != true ]]; then
      echo "Error: ${item_name} harness dir ${source} has no file containing ${placeholder}." >&2
      return 1
    fi
  else
    if [[ ! -f "$source" ]]; then
      echo "Error: ${item_name} is missing harness file ${source}." >&2
      return 1
    fi
    if ! grep -qF "$placeholder" "$source"; then
      echo "Error: ${item_name} file ${source} is missing ${placeholder}." >&2
      return 1
    fi
  fi
  return 0
}

# Expand a harness template into dest. Fails if CONTENT.md or the expected
# placeholder is missing. Never leaves unresolved placeholders on disk.
expand_harness_file() {
  local item_dir="$1"
  local source_file="$2"
  local dest_file="$3"
  local item_name="$4"

  local content_file="${item_dir%/}/CONTENT.md"
  if [[ ! -f "$content_file" ]]; then
    echo "Error: ${item_name} is missing CONTENT.md (expected ${content_file})." >&2
    return 1
  fi

  local placeholder
  placeholder="$(placeholder_for_item "$item_dir")"
  if ! grep -qF "$placeholder" "$source_file"; then
    echo "Error: ${item_name} file ${source_file} is missing ${placeholder}." >&2
    return 1
  fi

  local dest_dir
  dest_dir="$(dirname "$dest_file")"
  mkdir -p "$dest_dir"

  local tmp
  tmp="$(mktemp "${dest_dir}/.expand.XXXXXX")"

  local line trimmed last
  while IFS= read -r line || [[ -n "$line" ]]; do
    trimmed="${line#"${line%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
    if [[ "$trimmed" == "$placeholder" ]]; then
      cat "$content_file" >> "$tmp"
      if [[ -s "$content_file" ]]; then
        last="$(tail -c 1 "$content_file" || true)"
        if [[ "$last" != $'\n' ]]; then
          printf '\n' >> "$tmp"
        fi
      fi
    elif [[ "$line" == *'{{SKILL_BODY}}'* || "$line" == *'{{RULE_BODY}}'* ]]; then
      echo "Error: ${item_name} file ${source_file} must place ${placeholder} on its own line." >&2
      rm -f "$tmp"
      return 1
    else
      printf '%s\n' "$line" >> "$tmp"
    fi
  done < "$source_file"

  if ! assert_no_unresolved_placeholders "$tmp"; then
    rm -f "$tmp"
    return 1
  fi

  mv "$tmp" "$dest_file"
  return 0
}

# Copy a harness directory (AGY): expand files that contain a placeholder;
# copy other files as-is after refusing unresolved tokens.
expand_harness_dir() {
  local item_dir="$1"
  local harness_dir="$2"
  local dest_dir="$3"
  local item_name="$4"

  local content_file="${item_dir%/}/CONTENT.md"
  if [[ ! -f "$content_file" ]]; then
    echo "Error: ${item_name} is missing CONTENT.md (expected ${content_file})." >&2
    return 1
  fi

  mkdir -p "$dest_dir"

  local src dest base
  for src in "${harness_dir%/}"/*; do
    [[ -e "$src" ]] || continue
    base="$(basename "$src")"
    dest="${dest_dir%/}/${base}"
    if [[ -d "$src" ]]; then
      if grep -R -q -F '{{SKILL_BODY}}' "$src" 2>/dev/null || grep -R -q -F '{{RULE_BODY}}' "$src" 2>/dev/null; then
        echo "Error: unresolved placeholder in companion directory ${src}. Refusing to install." >&2
        return 1
      fi
      cp -R "$src" "$dest"
      continue
    fi
    if grep -q -F '{{SKILL_BODY}}' "$src" || grep -q -F '{{RULE_BODY}}' "$src"; then
      expand_harness_file "$item_dir" "$src" "$dest" "$item_name" || return 1
    else
      cp "$src" "$dest"
      assert_no_unresolved_placeholders "$dest" || return 1
    fi
  done

  # Primary harness file must have been expanded (placeholder required).
  local placeholder
  placeholder="$(placeholder_for_item "$item_dir")"
  local found=false
  for src in "${harness_dir%/}"/*; do
    [[ -f "$src" ]] || continue
    if grep -q -F "$placeholder" "$src"; then
      found=true
      break
    fi
  done
  if [[ "$found" != true ]]; then
    echo "Error: ${item_name} harness dir ${harness_dir} has no file containing ${placeholder}." >&2
    return 1
  fi
  return 0
}

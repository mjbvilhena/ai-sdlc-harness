#!/usr/bin/env bash
# Shared sdlc- destination naming and cleanup helpers.
# Sourced by install/install_*.sh. Requires bash >= 3.2.
# shellcheck shell=bash

SDLC_NAME_PREFIX="sdlc-"

# Dest / frontmatter name: keep sdlc-* as-is, otherwise prefix sdlc-.
sdlc_prefixed_name() {
  local name="$1"
  if [[ "$name" == "${SDLC_NAME_PREFIX}"* ]]; then
    printf '%s\n' "$name"
  else
    printf '%s\n' "${SDLC_NAME_PREFIX}${name}"
  fi
}

# Rewrite the first YAML frontmatter `name:` key to dest_name, if present.
# Leaves the file unchanged when there is no --- frontmatter or no name: key.
ensure_sdlc_frontmatter_name() {
  local file="$1"
  local dest_name="$2"

  [[ -f "$file" ]] || return 0

  local first
  IFS= read -r first < "$file" || true
  first="${first%$'\r'}"
  if [[ "$first" != "---" ]]; then
    return 0
  fi

  local tmp
  tmp="$(mktemp "${file}.sdlcname.XXXXXX")"

  local in_fm=1
  local seen_name=0
  local line_num=0
  local line raw
  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))
    raw="${line%$'\r'}"

    if [[ "$line_num" -eq 1 ]]; then
      printf '%s\n' "$raw" >> "$tmp"
      continue
    fi

    if [[ "$in_fm" -eq 1 ]]; then
      if [[ "$raw" == "---" ]]; then
        in_fm=0
        printf '%s\n' "$raw" >> "$tmp"
        continue
      fi
      if [[ "$seen_name" -eq 0 && "$raw" =~ ^name:[[:space:]]* ]]; then
        printf 'name: %s\n' "$dest_name" >> "$tmp"
        seen_name=1
        continue
      fi
    fi
    printf '%s\n' "$raw" >> "$tmp"
  done < "$file"

  mv "$tmp" "$file"
  return 0
}

# Apply frontmatter name rewrite to every regular file in dest_dir.
ensure_sdlc_frontmatter_names_in_dir() {
  local dest_dir="$1"
  local dest_name="$2"
  local path
  [[ -d "$dest_dir" ]] || return 0
  for path in "${dest_dir%/}"/*; do
    [[ -f "$path" ]] || continue
    ensure_sdlc_frontmatter_name "$path" "$dest_name"
  done
}

# Remove sdlc-* files matching pattern (e.g. "sdlc-*.md") under dest_dir.
# Dry-run prints paths only. Missing dest_dir is a no-op.
remove_sdlc_files() {
  local dest_dir="$1"
  local pattern="$2"
  local dry_run="${3:-false}"
  local path found=0

  if [[ ! -d "$dest_dir" ]]; then
    echo "  [info] Destination ${dest_dir} does not exist yet — nothing to clean."
    return 0
  fi

  echo "Cleaning previously installed sdlc-* artifacts in ${dest_dir}..."
  for path in "${dest_dir%/}"/${pattern}; do
    if [[ ! -e "$path" || ! -f "$path" ]]; then
      continue
    fi
    found=1
    if [[ "$dry_run" == true ]]; then
      echo "  [dry-run] Would remove: ${path}"
    else
      rm -f "$path"
      echo "  [ok] Removed: ${path}"
    fi
  done

  if [[ "$found" -eq 0 ]]; then
    echo "  [info] No sdlc-* artifacts to remove."
  fi
  return 0
}

# Remove sdlc-* directories under dest_dir (Antigravity skill folders).
# Dry-run prints paths only. Missing dest_dir is a no-op.
remove_sdlc_dirs() {
  local dest_dir="$1"
  local dry_run="${2:-false}"
  local path found=0

  if [[ ! -d "$dest_dir" ]]; then
    echo "  [info] Destination ${dest_dir} does not exist yet — nothing to clean."
    return 0
  fi

  echo "Cleaning previously installed sdlc-* artifacts in ${dest_dir}..."
  for path in "${dest_dir%/}"/sdlc-*/; do
    if [[ ! -d "$path" ]]; then
      continue
    fi
    found=1
    # Strip trailing slash for a stable printed path.
    path="${path%/}"
    if [[ "$dry_run" == true ]]; then
      echo "  [dry-run] Would remove: ${path}"
    else
      rm -rf "$path"
      echo "  [ok] Removed: ${path}"
    fi
  done

  if [[ "$found" -eq 0 ]]; then
    echo "  [info] No sdlc-* artifacts to remove."
  fi
  return 0
}

#!/usr/bin/env bash
# Linux MOTD project - illustrative excerpt only.
# This is a compact portfolio snippet, not the full project source.

set -euo pipefail

CONFIG_FILE="config/api_settings.conf"
HISTORY_FILE="data/quotes_history.json"

active_source() {
  awk -F= '/^ACTIVE_SOURCE=/ { print $2 }' "$CONFIG_FILE"
}

fetch_quote() {
  local source_name
  source_name="$(active_source)"

  # The full project maps each source to a URL and jq selectors.
  curl --silent --fail "$QUOTE_API_URL" |
    jq --arg source "$source_name" '{
      quote: .quote,
      author: (.author // "Unknown"),
      source: $source,
      fetched_at: now | todate
    }'
}

update_history() {
  local quote_json="$1"
  jq ". + [${quote_json}]" "$HISTORY_FILE" > "${HISTORY_FILE}.tmp"
  mv "${HISTORY_FILE}.tmp" "$HISTORY_FILE"
}


#!/usr/bin/env bash
# Source before invoking the saved yq expressions; this file never edits rules.
if ! command -v yq >/dev/null 2>&1; then
  echo 'Install Mike Farah yq v4 (tested with v4.54.1).' >&2
  return 2
fi
if [[ $(yq --version) != *'github.com/mikefarah/yq/'*'version v4.'* ]]; then
  echo 'Expected Mike Farah yq v4 (tested with v4.54.1).' >&2
  return 2
fi
RULE_AUTHORING_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../authoring" && pwd) || return 2
export RULE_AUTHORING_DIR

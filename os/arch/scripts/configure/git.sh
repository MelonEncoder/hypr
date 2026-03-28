#!/usr/bin/env bash
set -euo pipefail

KEY_PUB_PATH="${HOME}/.ssh/id_ed25519.pub"
SIGNING_KEY_PATH="$KEY_PUB_PATH"
GIT_NAME="${GIT_USER_NAME:-}"
GIT_EMAIL="${GIT_USER_EMAIL:-}"

if [ ! -f "$KEY_PUB_PATH" ]; then
  echo "Public key not found at $KEY_PUB_PATH" >&2
  exit 1
fi

git config --global gpg.format ssh
git config --global user.signingkey "$SIGNING_KEY_PATH"
git config --global commit.gpgsign true

if [ -n "$GIT_NAME" ]; then
  git config --global user.name "$GIT_NAME"
fi
if [ -n "$GIT_EMAIL" ]; then
  git config --global user.email "$GIT_EMAIL"
fi

echo "Git configured to use SSH signing with key: $SIGNING_KEY_PATH"
echo "To test: git commit --allow-empty -m 'test signed commit' && git log -1 --show-signature"

#!/usr/bin/env bash

set -euo pipefail

. "$(dirname "$0")/notifications_test_lib.sh"

usage() {
	printf 'Usage: %s [monitor-name] [image-path]\n' "${0##*/}"
	printf 'Sends an image-only notification and verifies the notification region changes.\n'
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	usage
	exit 0
fi

for cmd in gdbus; do
	if ! command -v "$cmd" >/dev/null 2>&1; then
		printf 'Missing required command: %s\n' "$cmd" >&2
		exit 1
	fi
done

notifications_require_tools
notifications_init_geometry "${1:-}"
trap notifications_cleanup EXIT

image_path="${2:-$(notifications_default_image_path)}"
if [[ ! -f "$image_path" ]]; then
	printf 'Image path not found: %s\n' "$image_path" >&2
	exit 1
fi

notifications_capture_before

gdbus call --session \
	--dest org.freedesktop.Notifications \
	--object-path /org/freedesktop/Notifications \
	--method org.freedesktop.Notifications.Notify \
	"silly-little-test" \
	0 \
	"" \
	"" \
	"" \
	"[]" \
	"{'image-path': <'$image_path'>}" \
	2500 >/dev/null

notifications_assert_changed "PASS: image-only notification rendered"

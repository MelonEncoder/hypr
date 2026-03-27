#!/usr/bin/env bash

set -euo pipefail

. "$(dirname "$0")/notifications_test_lib.sh"

usage() {
	printf 'Usage: %s [monitor-name]\n' "${0##*/}"
	printf 'Sends a text-only notification and verifies the notification region changes.\n'
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	usage
	exit 0
fi

for cmd in notify-send; do
	if ! command -v "$cmd" >/dev/null 2>&1; then
		printf 'Missing required command: %s\n' "$cmd" >&2
		exit 1
	fi
done

notifications_require_tools
notifications_init_geometry "${1:-}"
trap notifications_cleanup EXIT
notifications_capture_before

notify-send \
	-a "silly-little-test" \
	-t 2500 \
	-u normal \
	"Silly little test" \
	"Text-only notification should render on ${NOTIFICATION_TEST_MONITOR_NAME}"

notifications_assert_changed "text-only notification rendered"

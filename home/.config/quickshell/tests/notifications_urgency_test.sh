#!/usr/bin/env bash

set -euo pipefail

. "$(dirname "$0")/notifications_test_lib.sh"

usage() {
	printf 'Usage: %s [monitor-name]\n' "${0##*/}"
	printf 'Sends low, normal, and critical notifications to verify urgency styling.\n'
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

send_urgency_notification() {
	local urgency="$1"
	local summary="$2"
	local body="$3"

	notifications_capture_before

	notify-send \
		-a "silly-little-test" \
		-t 3500 \
		-u "$urgency" \
		"$summary" \
		"$body"

	notifications_assert_changed "PASS: ${urgency} urgency notification rendered"
	sleep 0.6
}

send_urgency_notification \
	low \
	"Silly little test: low" \
	"Low urgency should use the low accent color on ${NOTIFICATION_TEST_MONITOR_NAME}."

send_urgency_notification \
	normal \
	"Silly little test: normal" \
	"Normal urgency should use the normal accent color on ${NOTIFICATION_TEST_MONITOR_NAME}."

send_urgency_notification \
	critical \
	"Silly little test: critical" \
	"Critical urgency should use the critical accent color on ${NOTIFICATION_TEST_MONITOR_NAME}."

#!/usr/bin/env bash

set -euo pipefail

notifications_require_tools() {
	for cmd in hyprctl jq grim compare mktemp; do
		if ! command -v "$cmd" >/dev/null 2>&1; then
			printf 'Missing required command: %s\n' "$cmd" >&2
			exit 1
		fi
	done
}

readonly NOTIFICATION_THEME_MARGIN=20
readonly NOTIFICATION_THEME_WIDTH=380
readonly NOTIFICATION_THEME_STACK_GAP_BELOW_BAR=8
readonly BAR_THEME_BAR_PADDING=6
readonly THEME_FONT_SIZE=12
readonly BAR_THEME_WIDGET_PADDING=8
readonly BAR_THEME_WIDGET_HEIGHT=$((THEME_FONT_SIZE + (BAR_THEME_WIDGET_PADDING * 2)))
readonly NOTIFICATION_PANEL_TOP_OFFSET=$((NOTIFICATION_THEME_MARGIN + BAR_THEME_WIDGET_HEIGHT + (BAR_THEME_BAR_PADDING * 2) + NOTIFICATION_THEME_STACK_GAP_BELOW_BAR))
readonly NOTIFICATION_TEST_CAPTURE_HEIGHT=600

notifications_init_geometry() {
	local requested_monitor="${1:-}"

	NOTIFICATION_TEST_WORKDIR="$(mktemp -d)"
	export NOTIFICATION_TEST_WORKDIR
	NOTIFICATION_TEST_BEFORE_PNG="$NOTIFICATION_TEST_WORKDIR/before.png"
	NOTIFICATION_TEST_AFTER_PNG="$NOTIFICATION_TEST_WORKDIR/after.png"
	export NOTIFICATION_TEST_BEFORE_PNG NOTIFICATION_TEST_AFTER_PNG

	local monitors_json

	monitors_json="$(hyprctl -j monitors)"

	if [[ -z "$requested_monitor" ]]; then
		requested_monitor="$(jq -r '.[] | select(.focused == true) | .name' <<<"$monitors_json" | head -n 1)"
	fi

	if [[ -z "$requested_monitor" ]]; then
		printf 'Could not determine the target monitor.\n' >&2
		exit 1
	fi

	local monitor_geometry
	monitor_geometry="$(jq -c --arg name "$requested_monitor" '.[] | select(.name == $name) | {x, y, width, height}' <<<"$monitors_json")"
	if [[ -z "$monitor_geometry" ]]; then
		printf 'Monitor %s was not found.\n' "$requested_monitor" >&2
		exit 1
	fi

	NOTIFICATION_TEST_MONITOR_NAME="$requested_monitor"
	NOTIFICATION_TEST_MONITOR_X="$(jq -r '.x' <<<"$monitor_geometry")"
	NOTIFICATION_TEST_MONITOR_Y="$(jq -r '.y' <<<"$monitor_geometry")"
	NOTIFICATION_TEST_MONITOR_W="$(jq -r '.width' <<<"$monitor_geometry")"
	NOTIFICATION_TEST_MONITOR_H="$(jq -r '.height' <<<"$monitor_geometry")"
	NOTIFICATION_TEST_PANEL_W="$NOTIFICATION_THEME_WIDTH"
	NOTIFICATION_TEST_PANEL_X=$((NOTIFICATION_TEST_MONITOR_X + NOTIFICATION_TEST_MONITOR_W - NOTIFICATION_TEST_PANEL_W - NOTIFICATION_THEME_MARGIN))
	NOTIFICATION_TEST_PANEL_Y=$((NOTIFICATION_TEST_MONITOR_Y + NOTIFICATION_PANEL_TOP_OFFSET))
	NOTIFICATION_TEST_PANEL_H=$((NOTIFICATION_TEST_MONITOR_H - NOTIFICATION_PANEL_TOP_OFFSET - NOTIFICATION_THEME_MARGIN))
	if (( NOTIFICATION_TEST_PANEL_H > NOTIFICATION_TEST_CAPTURE_HEIGHT )); then
		NOTIFICATION_TEST_PANEL_H=$NOTIFICATION_TEST_CAPTURE_HEIGHT
	fi
	if (( NOTIFICATION_TEST_PANEL_H <= 0 )); then
		printf 'Computed invalid notification capture height for monitor %s.\n' "$requested_monitor" >&2
		exit 1
	fi
	export NOTIFICATION_TEST_MONITOR_NAME
	export NOTIFICATION_TEST_MONITOR_X NOTIFICATION_TEST_MONITOR_Y
	export NOTIFICATION_TEST_MONITOR_W NOTIFICATION_TEST_MONITOR_H
	export NOTIFICATION_TEST_PANEL_X NOTIFICATION_TEST_PANEL_Y
	export NOTIFICATION_TEST_PANEL_W NOTIFICATION_TEST_PANEL_H

	local expected_right_edge=$((NOTIFICATION_TEST_MONITOR_X + NOTIFICATION_TEST_MONITOR_W))
	local panel_right_edge=$((NOTIFICATION_TEST_PANEL_X + NOTIFICATION_TEST_PANEL_W))

	if (( panel_right_edge + NOTIFICATION_THEME_MARGIN != expected_right_edge )); then
		printf 'Notification layer is not flush with the right edge: got x=%d w=%d, expected right edge=%d.\n' \
			"$NOTIFICATION_TEST_PANEL_X" "$NOTIFICATION_TEST_PANEL_W" "$expected_right_edge" >&2
		exit 1
	fi

	if (( NOTIFICATION_TEST_PANEL_Y <= NOTIFICATION_TEST_MONITOR_Y )); then
		printf 'Notification capture region overlaps the bar: got y=%d, monitor top=%d.\n' \
			"$NOTIFICATION_TEST_PANEL_Y" "$NOTIFICATION_TEST_MONITOR_Y" >&2
		exit 1
	fi
}

notifications_capture_before() {
	grim -g "${NOTIFICATION_TEST_PANEL_X},${NOTIFICATION_TEST_PANEL_Y} ${NOTIFICATION_TEST_PANEL_W}x${NOTIFICATION_TEST_PANEL_H}" \
		"$NOTIFICATION_TEST_BEFORE_PNG"
}

notifications_assert_changed() {
	local reason="${1:-Notification region did not change.}"
	local pixel_delta=0

	for _ in $(seq 1 20); do
		sleep 0.2
		grim -g "${NOTIFICATION_TEST_PANEL_X},${NOTIFICATION_TEST_PANEL_Y} ${NOTIFICATION_TEST_PANEL_W}x${NOTIFICATION_TEST_PANEL_H}" \
			"$NOTIFICATION_TEST_AFTER_PNG"
		pixel_delta="$(compare -metric AE "$NOTIFICATION_TEST_BEFORE_PNG" "$NOTIFICATION_TEST_AFTER_PNG" null: 2>&1 | awk '{ print $1 }' || true)"
		if [[ "$pixel_delta" =~ ^[0-9]+(\.[0-9]+)?$ ]] && awk "BEGIN { exit !($pixel_delta > 0) }"; then
			printf 'PASS: %s on %s (pixel delta %s).\n' "$reason" "$NOTIFICATION_TEST_MONITOR_NAME" "$pixel_delta"
			return 0
		fi
	done

	if ! [[ "$pixel_delta" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
		printf 'Could not evaluate screenshot difference. compare reported: %s\n' "$pixel_delta" >&2
		exit 1
	fi

	printf '%s\n' "$reason" >&2
	exit 1
}

notifications_default_image_path() {
	if [[ -f "/usr/share/icons/hicolor/scalable/apps/org.quickshell.svg" ]]; then
		printf '%s\n' "/usr/share/icons/hicolor/scalable/apps/org.quickshell.svg"
		return 0
	fi

	printf 'Could not find a default test image.\n' >&2
	exit 1
}

notifications_cleanup() {
	if [[ -n "${NOTIFICATION_TEST_WORKDIR:-}" && -d "${NOTIFICATION_TEST_WORKDIR:-}" ]]; then
		rm -rf "$NOTIFICATION_TEST_WORKDIR"
	fi
}

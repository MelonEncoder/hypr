pragma Singleton

import QtQuick
import "../constants"

QtObject {
	readonly property int margin: 20
	readonly property int width: 380
	readonly property int min_height: 72
	readonly property int max_body_lines: 4
	readonly property int stack_gap_below_bar: 8
	readonly property int spacing: 6
	readonly property int padding: 12
	readonly property int inner_spacing: 6
	readonly property int action_spacing: 4
	readonly property int image_size: 28
	readonly property int action_height: Theme.font_size + 10
	readonly property int radius: Theme.radius_normal
	readonly property int border_width: Theme.border_width
	readonly property int slide_offset: 28
	readonly property int top_accent_height: 2
	readonly property int image_max_height: 120
	readonly property int image_radius: Theme.radius_normal

	readonly property color background_color: Theme.color_surface
	readonly property color border_color: Theme.color_border
	readonly property color icon_background_color: Qt.rgba(1, 1, 1, 0.06)
	readonly property color action_color: Qt.rgba(1, 1, 1, 0.08)
	readonly property color action_hover_color: Qt.rgba(1, 1, 1, 0.16)
	readonly property color action_pressed_color: Qt.rgba(1, 1, 1, 0.05)
	readonly property color image_background_color: Qt.rgba(0, 0, 0, 0.078)
	readonly property color accent_low: Qt.rgba(0.498, 0.863, 0.541, 1)
	readonly property color accent_normal: Qt.rgba(0.941, 0.702, 0.353, 1)
	readonly property color accent_critical: Qt.rgba(0.937, 0.420, 0.420, 1)
}

pragma Singleton

import QtQuick
import "../constants"

QtObject {
	readonly property int margin: 24
	readonly property int width: 360
	readonly property int min_height: 104
	readonly property int max_body_lines: 4
	readonly property int stack_gap_below_bar: 12
	readonly property int spacing: 10
	readonly property int padding: 10
	readonly property int inner_spacing: 8
	readonly property int action_spacing: 6
	readonly property int image_size: 32
	readonly property int action_height: Theme.font_size + 12
	readonly property int radius: 8
	readonly property int border_width: 2
	readonly property int slide_offset: 40
	readonly property int accent_width: 4
	readonly property int image_max_height: 120
	readonly property int image_radius: 6

	readonly property color background_color: Theme.color_background
	readonly property color border_color: Theme.color_border
	readonly property color action_color: Theme.color_surface
	readonly property color action_hover_color: Theme.color_surface_hover
	readonly property color action_pressed_color: Theme.color_surface_pressed
	readonly property color image_background_color: "#14000000"
	readonly property color accent_low: "#7fdc8a"
	readonly property color accent_normal: "#f0b35a"
	readonly property color accent_critical: "#ef6b6b"
}

pragma Singleton

import QtQuick
import "../constants"

QtObject {
    // margin + padding
	readonly property int screen_margin: 48
	readonly property int column_width: 400
	readonly property int column_spacing: 50
	readonly property int header_spacing: 0
	readonly property int column_offset: -90
	readonly property int time_font_size: 68
	readonly property int date_font_size: 18
	// input
	readonly property int input_height: 50
	readonly property int input_radius: Theme.radius_normal * 2
	readonly property int input_border_width: 3
	readonly property int input_padding: 18
	readonly property int input_font_size: 16
	readonly property int status_font_size: 14
	readonly property int status_height: 24
	// bg
	readonly property int background_blur_max: 40
	readonly property real background_blur_strength: 0.6
	// shadow
	readonly property color text_shadow_color: "#99000000"
	readonly property real text_shadow_blur: 0.5
	readonly property real text_shadow_horizontal_offset: 0
	readonly property real text_shadow_vertical_offset: 0
	readonly property color input_shadow_color: "#99000000"
	readonly property real input_shadow_blur: 0.6
	readonly property real input_shadow_horizontal_offset: 0
	readonly property real input_shadow_vertical_offset: 0

	readonly property string time_font_family: "JetBrains Mono"
	readonly property string body_font_family: "JetBrains Mono"

	readonly property color base_color: "#191414"
	readonly property color scrim_color: "#4d191414"
	readonly property color date_color: "#ffffffff"
	readonly property color input_fill_color: "#ffffffff"
	readonly property color input_text_color: "#ff000000"
	readonly property color input_border_color: "#ff000000"
	readonly property color input_focus_border_color: "#ff000000"
	readonly property color input_fail_border_color: "#ffcc2222"
	readonly property color placeholder_color: "#a6000000"
	readonly property color status_color: "#ffffffff"
	readonly property color error_color: "#ffcc2222"
}

pragma Singleton

import QtQuick
import "../constants"

QtObject {
	readonly property int screen_margin: 48
	readonly property int column_width: 400
	readonly property int column_spacing: 10
	readonly property int column_offset: -90
	readonly property int time_font_size: 64
	readonly property int date_font_size: 16
	readonly property int input_height: 50
	readonly property int input_radius: Theme.radius_background
	readonly property int input_border_width: 3
	readonly property int input_padding: 18
	readonly property int input_font_size: 16
	readonly property int status_font_size: 14
	readonly property int status_height: 24
	readonly property int background_blur_max: 32
	readonly property real background_blur_strength: 0.22
	readonly property real background_brightness: -0.08
	readonly property real background_saturation: 0.9

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

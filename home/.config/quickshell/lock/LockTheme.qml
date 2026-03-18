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
	readonly property color text_shadow_color: Qt.rgba(0, 0, 0, 0.6)
	readonly property real text_shadow_blur: 0.5
	readonly property real text_shadow_horizontal_offset: 0
	readonly property real text_shadow_vertical_offset: 0
	readonly property color input_shadow_color: Qt.rgba(0, 0, 0, 0.6)
	readonly property real input_shadow_blur: 0.6
	readonly property real input_shadow_horizontal_offset: 0
	readonly property real input_shadow_vertical_offset: 0

	readonly property string time_font_family: "JetBrains Mono"
	readonly property string body_font_family: "JetBrains Mono"

	readonly property color base_color: Qt.rgba(0.098, 0.078, 0.078, 1)
	readonly property color scrim_color: Qt.rgba(0.098, 0.078, 0.078, 0.302)
	readonly property color date_color: Qt.rgba(1, 1, 1, 1)
	readonly property color input_fill_color: Qt.rgba(1, 1, 1, 1)
	readonly property color input_text_color: Qt.rgba(0, 0, 0, 1)
	readonly property color input_border_color: Qt.rgba(0, 0, 0, 1)
	readonly property color input_focus_border_color: Qt.rgba(0, 0, 0, 1)
	readonly property color input_fail_border_color: Qt.rgba(0.8, 0.133, 0.133, 1)
	readonly property color placeholder_color: Qt.rgba(0, 0, 0, 0.651)
	readonly property color status_color: Qt.rgba(1, 1, 1, 1)
	readonly property color error_color: Qt.rgba(0.8, 0.133, 0.133, 1)
}

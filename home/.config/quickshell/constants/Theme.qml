pragma Singleton

import QtQuick
import "."

QtObject {
	readonly property color color_background: Qt.rgba(0, 0, 0, 1)
	readonly property color color_surface: Qt.rgba(0.184, 0.184, 0.184, 1)
	readonly property color color_surface_hover: Qt.rgba(0.267, 0.267, 0.267, 1)
	readonly property color color_surface_pressed: Qt.rgba(0.227, 0.227, 0.227, 1)
	readonly property color color_privacy: Qt.rgba(0.937, 0.475, 0.263, 1)
	readonly property color color_border: Qt.rgba(1, 1, 1, 0.4)
	readonly property color color_text: Qt.rgba(1, 1, 1, 1)
	readonly property color color_text_muted: Qt.rgba(0.851, 0.851, 0.851, 1)
	readonly property color color_text_subtle: Qt.rgba(0.749, 0.749, 0.749, 1)
	readonly property color color_text_on_active: Qt.rgba(1, 1, 1, 1)

	readonly property string font_family: "JetBrainsMono"
	readonly property string font_family_icon: "Symbols Nerd Font"
	readonly property int font_size: 12

	readonly property int radius_background: 2
	readonly property int radius_normal: 4
	readonly property int border_width: 0

	readonly property color background: color_background
}

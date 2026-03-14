pragma Singleton

import QtQuick
import "."

QtObject {
	readonly property color color_background: "#ff000000"
	readonly property color color_surface: "#2f2f2f"
	readonly property color color_surface_hover: "#444444"
	readonly property color color_surface_pressed: "#3a3a3a"
	readonly property color color_privacy: "#ef7943"
	readonly property color color_border: "#66ffffff"
	readonly property color color_text: "#ffffff"
	readonly property color color_text_muted: "#d9d9d9"
	readonly property color color_text_subtle: "#bfbfbf"
	readonly property color color_text_on_active: "#ffffff"

	readonly property string font_family: "JetBrainsMono"
	readonly property string font_family_icon: "Symbols Nerd Font"
	readonly property int font_size: 12

	readonly property int radius_background: 2
	readonly property int radius_normal: 4
	readonly property int border_width: 0

	readonly property color background: color_background
}

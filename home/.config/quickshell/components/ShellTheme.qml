pragma Singleton

import QtQuick
import "."

QtObject {
	// Base colors
	readonly property color color_background: Qt.rgba(0, 0, 0, 1)
	readonly property color color_surface: Qt.rgba(0.184, 0.184, 0.184, 1)
	readonly property color color_surface_hover: Qt.rgba(0.267, 0.267, 0.267, 1)
	readonly property color color_surface_pressed: Qt.rgba(0.227, 0.227, 0.227, 1)
	readonly property color color_privacy: Qt.rgba(0.937, 0.475, 0.263, 1)
	readonly property color color_border: Qt.rgba(1, 1, 1, 0.4)
	readonly property color color_border_subtle: Qt.rgba(1, 1, 1, 0.267)
	readonly property color color_overlay_light: Qt.rgba(1, 1, 1, 0.2)
	readonly property color color_overlay_dark: Qt.rgba(0, 0, 0, 0.078)

	// Text colors
	readonly property color color_text: Qt.rgba(1, 1, 1, 1)
	readonly property color color_text_muted: Qt.rgba(0.851, 0.851, 0.851, 1)
	readonly property color color_text_subtle: Qt.rgba(0.749, 0.749, 0.749, 1)

	// Typography
	readonly property string font_family: "JetBrainsMono"
	readonly property string font_family_icon: "Symbols Nerd Font"
	readonly property int font_size: 12

	// Shape
	readonly property int radius_background: 2
	readonly property int radius_normal: 4
	readonly property int border_width: 0

	// Aliases
	readonly property color background: color_background

	// Wallpaper
	property string wallpaper: "random"

	// Bar layout
	readonly property int bar_padding: 6
	readonly property int bar_widget_padding: 8
	readonly property int bar_widget_height: font_size + (bar_widget_padding * 2)

	// Notification colors
	readonly property color notification_icon_background: Qt.rgba(1, 1, 1, 0.06)
	readonly property color notification_action: Qt.rgba(1, 1, 1, 0.08)
	readonly property color notification_action_hover: Qt.rgba(1, 1, 1, 0.16)
	readonly property color notification_action_pressed: Qt.rgba(1, 1, 1, 0.05)
	readonly property color notification_accent_low: Qt.rgba(0.498, 0.863, 0.541, 1)
	readonly property color notification_accent_normal: Qt.rgba(0.941, 0.702, 0.353, 1)
	readonly property color notification_accent_critical: Qt.rgba(0.937, 0.420, 0.420, 1)

	// Lock screen colors
	readonly property color lock_shadow: Qt.rgba(0, 0, 0, 0.6)
	readonly property color lock_base: Qt.rgba(0.098, 0.078, 0.078, 1)
	readonly property color lock_scrim: Qt.rgba(0.098, 0.078, 0.078, 0.302)
	readonly property color lock_error: Qt.rgba(0.8, 0.133, 0.133, 1)
	readonly property color lock_placeholder: Qt.rgba(0, 0, 0, 0.651)

	// Wallpaper picker colors
	readonly property color wallpaper_window_border: Qt.rgba(1, 1, 1, 0.333)
	readonly property color wallpaper_caption: Qt.rgba(0, 0, 0, 0.733)

	// Launcher colors
	readonly property color launcher_overlay: Qt.rgba(0, 0, 0, 0.4)
	readonly property color launcher_search_active_border: Qt.rgba(1, 1, 1, 0.533)
	readonly property color launcher_row: Qt.rgba(1, 1, 1, 0.102)
	readonly property color launcher_row_hover: Qt.rgba(1, 1, 1, 0.133)
	readonly property color launcher_row_selected: Qt.rgba(1, 1, 1, 0.188)
	readonly property color launcher_icon_background: Qt.rgba(1, 1, 1, 0.094)

	// Workspace indicator colors
	readonly property color workspace_dot_occupied: Qt.rgba(0.690, 0.690, 0.690, 1)
	readonly property color workspace_dot_empty: Qt.rgba(0.478, 0.478, 0.478, 1)
}

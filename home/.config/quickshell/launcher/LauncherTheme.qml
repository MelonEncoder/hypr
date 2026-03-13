pragma Singleton

import QtQuick
import "../constants"

QtObject {
	readonly property int window_width: 760
	readonly property int window_height: 640
	readonly property int window_margin: 48
	readonly property int content_padding: 22
	readonly property int section_spacing: 16
	readonly property int search_height: 52
	readonly property int search_padding: 16
	readonly property int list_spacing: 8
	readonly property int row_height: 62
	readonly property int row_radius: Theme.radius_normal + 4
	readonly property int icon_size: 28
	readonly property int icon_wrap_size: 40
	readonly property int border_width: 2

	readonly property color overlay_color: "#66000000"
	readonly property color panel_color: Theme.background
	readonly property color panel_border_color: "#33ffffff"
	readonly property color search_color: Theme.color_surface
	readonly property color search_border_color: "#44ffffff"
	readonly property color search_active_border_color: "#88ffffff"
	readonly property color row_color: "#1affffff"
	readonly property color row_hover_color: "#22ffffff"
	readonly property color row_selected_color: "#30ffffff"
	readonly property color icon_background_color: "#18ffffff"
	readonly property color hint_color: Theme.color_text_subtle
	readonly property color muted_color: Theme.color_text_muted
}

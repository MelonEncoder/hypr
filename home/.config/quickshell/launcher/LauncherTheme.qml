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

	readonly property color overlay_color: Qt.rgba(0, 0, 0, 0.4)
	readonly property color panel_color: Theme.background
	readonly property color panel_border_color: Qt.rgba(1, 1, 1, 0.2)
	readonly property color search_color: Theme.color_surface
	readonly property color search_border_color: Qt.rgba(1, 1, 1, 0.267)
	readonly property color search_active_border_color: Qt.rgba(1, 1, 1, 0.533)
	readonly property color row_color: Qt.rgba(1, 1, 1, 0.102)
	readonly property color row_hover_color: Qt.rgba(1, 1, 1, 0.133)
	readonly property color row_selected_color: Qt.rgba(1, 1, 1, 0.188)
	readonly property color icon_background_color: Qt.rgba(1, 1, 1, 0.094)
	readonly property color hint_color: Theme.color_text_subtle
	readonly property color muted_color: Theme.color_text_muted
}

pragma Singleton

import QtQuick
import "../constants"

QtObject {
	readonly property int window_margin: 24
	readonly property int content_padding: 8
	readonly property int content_spacing: 10
	readonly property int visible_preview_count: 3
	readonly property int preview_spacing: 12
	readonly property int preview_width: 345
	readonly property int preview_height: 230
	readonly property real selected_preview_scale: 1.16
	readonly property real inactive_preview_scale: 1 / selected_preview_scale
	readonly property int selected_preview_width: Math.round(preview_width * selected_preview_scale)
	readonly property int selected_preview_height: Math.round(preview_height * selected_preview_scale)
	readonly property int preview_slot_width: selected_preview_width
	readonly property int preview_slot_height: selected_preview_height
	readonly property int list_surface_height: preview_slot_height + (content_padding * 2)
	readonly property int preview_margin: 6
	readonly property int caption_height: 28
	readonly property int caption_padding: 8
	readonly property int window_radius: 18
	readonly property int preview_radius: 12
	readonly property int caption_radius: 0
	readonly property int window_border_width: 2
	readonly property int selected_border_width: 2
	readonly property int default_border_width: 0
	readonly property color window_color: Theme.color_background
	readonly property color window_border_color: Qt.rgba(1, 1, 1, 0.333)
	readonly property color preview_selected_color: Qt.rgba(1, 1, 1, 0.2)
	readonly property color preview_default_color: Qt.rgba(0, 0, 0, 0.078)
	readonly property color preview_selected_border_color: Qt.rgba(1, 1, 1, 1)
	readonly property color preview_default_border_color: Qt.rgba(1, 1, 1, 0.267)
	readonly property color caption_color: Qt.rgba(0, 0, 0, 0.733)
}

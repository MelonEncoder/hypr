pragma Singleton

import QtQuick
import "../constants"

QtObject {
	readonly property int content_margin: 4
	readonly property int section_margin: 12
	readonly property int widget_spacing: 8
	readonly property int widget_padding: 8
	readonly property int widget_height: Theme.font_size + (widget_padding * 2)
	readonly property int inner_spacing: 6
	readonly property int popup_offset: 4
	readonly property int tray_item_size: 22
	readonly property int tray_icon_size: 16
}

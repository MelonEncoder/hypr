pragma Singleton

import QtQuick
import "../constants"

QtObject {
	readonly property int contentMargin: 4
	readonly property int sectionMargin: 12
	readonly property int widgetSpacing: 8
	readonly property int widgetPadding: 8
	readonly property int widgetHeight: Theme.font.size + (widgetPadding * 2)
	readonly property int innerSpacing: 6
	readonly property int popupOffset: 4
	readonly property int trayItemSize: 22
	readonly property int trayIconSize: 16
	readonly property int workspaceItemHeight: 20
	readonly property int workspaceItemPaddingX: 12
}

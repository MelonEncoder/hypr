pragma Singleton

import QtQuick

Item {
	// Unified typography and shape
	// Color system
	readonly property color accentColor: "#ff8a8a"
	readonly property color barBackground: "#111111"
	readonly property color surfaceBackground: "#1f1f1f"
	readonly property color widgetBackgroundIdle: surfaceBackground
	readonly property color widgetBackgroundHover: accentColor
	readonly property color widgetBackgroundActive: accentColor
	readonly property color surfaceBorder: "#66ffffff"
	readonly property color textPrimary: "#ffffff"
	readonly property color textOnActive: "#ffffff"
	readonly property color textMuted: "#d9d9d9"
	readonly property color textSubtle: "#bfbfbf"

	// Radius scale
	readonly property int radiusBg: 2 // all the backgrounds should
	readonly property int radius: 4 // default radius

	// Border scale
	readonly property int borderWidth: 1

	// Typography scale
	readonly property string fontFamily: "JetBrains Mono"
	readonly property int fontSize: 12 // used for regular text
	readonly property int fontIconSize: 14 // used for text based icons

	// Layout scale
	readonly property int barHeight: 33
	readonly property int widgetMarginY: 4
	readonly property int edgeMarginX: 4
	readonly property int widgetHeight: barHeight - (widgetMarginY * 2)
	readonly property int sectionMargin: 12
	readonly property int widgetPaddingX: 12
	readonly property int widgetPaddingY: 8
	readonly property int widgetSpacing: 10
	readonly property int innerSpacing: 6
	readonly property int popupOffset: 4

	// Component sizing
	readonly property int trayItemSize: 22
	readonly property int trayIconSize: 16
	readonly property int workspaceItemHeight: 20
	readonly property int workspaceItemPaddingX: 12
}

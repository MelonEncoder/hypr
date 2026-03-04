pragma Singleton

import QtQuick
import "."

QtObject {
	readonly property QtObject colors: QtObject {
		readonly property color background: "#ff000000"
		readonly property color surface: "#2f2f2f"
		readonly property color surfaceHover: "#ff8a8a"
		readonly property color surfaceActive: "#ff8a8a"
		readonly property color border: "#66ffffff"
		readonly property color text: "#ffffff"
		readonly property color textMuted: "#d9d9d9"
		readonly property color textSubtle: "#bfbfbf"
		readonly property color textOnActive: "#ffffff"
	}

	readonly property QtObject font: QtObject {
		readonly property string family: "JetBrains Nerd Mono"
		readonly property int size: 12
	}
		
	readonly property int radiusBg: 2
	readonly property int radius: 4
	readonly property int borderSize: 0
}

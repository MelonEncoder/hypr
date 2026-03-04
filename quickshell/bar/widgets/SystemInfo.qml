import QtQuick
import Quickshell.Io
import ".."
import "../../constants"

Rectangle {
	id: root
	property bool expanded: false
	property bool hovered: clickArea.containsMouse
	property string osInfo: "Arch Linux"
	property string kernelInfo: ""

	implicitWidth: label.implicitWidth + (BarTheme.widgetPadding * 2)
	implicitHeight: BarTheme.widgetHeight
	radius: Theme.radius
	color: root.expanded
		? Theme.colors.surfaceActive
		: (root.hovered ? Theme.colors.surfaceHover : Theme.colors.surface)
	border.width: Theme.borderSize
	border.color: Theme.colors.border

	Text {
		id: label
		anchors.centerIn: parent
		text: root.expanded ? (root.osInfo + (root.kernelInfo !== "" ? " | " + root.kernelInfo : "")) : ""
		color: root.expanded ? Theme.colors.textOnActive : Theme.colors.text
		font.pixelSize: Theme.font.size
		font.family: Theme.font.family
		elide: Text.ElideRight
	}

	MouseArea {
		id: clickArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: root.expanded = !root.expanded
	}

	StdioCollector {
		id: osProbeOut
		waitForEnd: true
		onStreamFinished: {
			var lines = text.trim().split("\n")
			if (lines.length > 0 && lines[0].length > 0) root.osInfo = lines[0]
			if (lines.length > 1 && lines[1].length > 0) root.kernelInfo = "kernel " + lines[1]
		}
	}

	Process {
		id: osProbe
		stdout: osProbeOut
		command: [
			"sh",
			"-c",
			"source /etc/os-release 2>/dev/null; printf '%s\\n' \"${PRETTY_NAME:-Arch Linux}\"; uname -r"
		]
	}

	Component.onCompleted: osProbe.running = true
}

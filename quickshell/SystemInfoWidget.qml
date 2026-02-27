import QtQuick
import QtQuick.Controls
import Quickshell.Io

Button {
	id: root
	property bool expanded: false
	property string osInfo: "Arch Linux"
	property string kernelInfo: ""
	hoverEnabled: true

	implicitWidth: label.implicitWidth + Theme.widgetPaddingX
	implicitHeight: Theme.widgetHeight
	onClicked: expanded = !expanded

	contentItem: Text {
		id: label
		text: root.expanded ? (root.osInfo + (root.kernelInfo !== "" ? " | " + root.kernelInfo : "")) : ""
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		color: root.expanded ? Theme.textOnActive : Theme.textPrimary
		font.pixelSize: Theme.fontIconSize
		font.family: Theme.fontFamily
		elide: Text.ElideRight
	}

	background: Rectangle {
		radius: Theme.radius
		color: root.expanded
			? Theme.widgetBackgroundActive
			: (root.hovered ? Theme.widgetBackgroundHover : Theme.widgetBackgroundIdle)
		border.width: Theme.borderWidth
		border.color: Theme.surfaceBorder
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

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
	property string distroDisplay: formatDistro(root.osInfo)
	property string kernelDisplay: formatKernel(root.kernelInfo)

	implicitWidth: label.implicitWidth + (BarTheme.widget_padding * 2)
	implicitHeight: BarTheme.widget_height
	radius: Theme.radius_normal
	color: root.expanded
		? Theme.color_surface_active
		: (root.hovered ? Theme.color_surface_hover : Theme.color_surface)
	border.width: Theme.border_width
	border.color: Theme.color_border

	Text {
		id: label
		anchors.centerIn: parent
		text: root.expanded ? (root.distroDisplay + (root.kernelDisplay !== "" ? " | " + root.kernelDisplay : "")) : ""
		color: root.expanded ? Theme.color_text_on_active : Theme.color_text
		font.pixelSize: Theme.font_size
		font.family: Theme.font_family
		elide: Text.ElideRight
	}

	MouseArea {
		id: clickArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: root.expanded = !root.expanded
	}

	function formatDistro(value: string): string {
		var text = value.trim()
		if (text.length === 0) return "Linux"
		return text.replace(/\s+/g, " ")
	}

	function formatKernel(value: string): string {
		var text = value.trim()
		if (text.length === 0) return ""
		var dash = text.indexOf("-")
		if (dash > 0) text = text.slice(0, dash)
		return text
	}

	StdioCollector {
		id: osProbeOut
		waitForEnd: true
		onStreamFinished: {
			var lines = text.trim().split("\n")
			if (lines.length > 0 && lines[0].length > 0) root.osInfo = lines[0]
			if (lines.length > 1 && lines[1].length > 0) root.kernelInfo = lines[1]
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

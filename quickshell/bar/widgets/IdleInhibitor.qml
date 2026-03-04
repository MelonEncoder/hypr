import QtQuick
import Quickshell.Io
import ".."
import "../../constants"

Rectangle {
	id: toggleButton
	property bool inhibited: false
	property bool hovered: clickArea.containsMouse

	implicitWidth: label.implicitWidth + (BarTheme.widgetPadding * 2)
	implicitHeight: BarTheme.widgetHeight
	radius: Theme.radius
	color: toggleButton.inhibited
		? Theme.colors.surfaceActive
		: (toggleButton.hovered ? Theme.colors.surfaceHover : Theme.colors.surface)
	border.width: Theme.borderSize
	border.color: Theme.colors.border

	Text {
		id: label
		anchors.centerIn: parent
		text: toggleButton.inhibited ? "󰈈" : ""
		color: toggleButton.inhibited ? Theme.colors.textOnActive : Theme.colors.text
		font.pixelSize: Theme.font.size
		font.family: Theme.font.family
	}
	MouseArea {
		id: clickArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: toggleButton.inhibited = !toggleButton.inhibited
	}

	Process {
		id: inhibitor
		running: toggleButton.inhibited
		command: [
			"systemd-inhibit",
			"--what=idle",
			"--mode=block",
			"--why=Quickshell idle inhibitor",
			"sleep",
			"infinity"
		]
		onRunningChanged: {
			if (!running && toggleButton.inhibited) toggleButton.inhibited = false
		}
	}
}

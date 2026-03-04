import QtQuick
import Quickshell.Io
import ".."
import "../../constants"

Rectangle {
	id: toggleButton
	property bool inhibited: false
	property bool hovered: clickArea.containsMouse
	property bool pressed: clickArea.pressed

	implicitWidth: label.implicitWidth + (BarTheme.widget_padding * 2)
	implicitHeight: BarTheme.widget_height
	radius: Theme.radius_normal
	color: toggleButton.pressed
		? Theme.color_surface_pressed
		: (toggleButton.inhibited ? Theme.color_text : (toggleButton.hovered ? Theme.color_surface_hover : Theme.color_surface))
	border.width: Theme.border_width
	border.color: Theme.color_border

	Text {
		id: label
		anchors.centerIn: parent
		text: toggleButton.inhibited ? "󰈈" : ""
		color: toggleButton.inhibited ? Theme.color_background : Theme.color_text
		font.pixelSize: Theme.font_size
		font.family: Theme.font_family
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

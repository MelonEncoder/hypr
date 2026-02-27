import QtQuick
import QtQuick.Controls
import Quickshell.Io

Button {
	id: toggleButton
	property bool inhibited: false

	implicitWidth: label.implicitWidth + 12
	implicitHeight: label.implicitHeight + 12
	onClicked: inhibited = !inhibited

	contentItem: Text {
		id: label
		text: toggleButton.inhibited ? "󰈈" : ""
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		color: toggleButton.inhibited ? Colors.textOnActive : Colors.textPrimary
		font.pixelSize: 16
	}

	background: Rectangle {
		radius: 5

		color: toggleButton.inhibited ? Colors.activeBackground : Colors.surfaceBackground
		border.width: 1
		border.color: toggleButton.inhibited ? Colors.activeBackground : Colors.surfaceBorder
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

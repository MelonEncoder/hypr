import QtQuick
import QtQuick.Controls
import Quickshell.Io

Button {
	id: toggleButton
	property bool inhibited: false
	hoverEnabled: true

	implicitWidth: label.implicitWidth + Theme.widgetPaddingX
	implicitHeight: Theme.widgetHeight
	onClicked: inhibited = !inhibited

	contentItem: Text {
		id: label
		text: toggleButton.inhibited ? "󰈈" : ""
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
		color: toggleButton.inhibited ? Theme.textOnActive : Theme.textPrimary
		font.pixelSize: Theme.fontIconSize
		font.family: Theme.fontFamily
	}

	background: Rectangle {
		radius: Theme.radius

		color: toggleButton.inhibited
			? Theme.widgetBackgroundActive
			: (toggleButton.hovered ? Theme.widgetBackgroundHover : Theme.widgetBackgroundIdle)
		border.width: Theme.borderWidth
		border.color: Theme.surfaceBorder
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

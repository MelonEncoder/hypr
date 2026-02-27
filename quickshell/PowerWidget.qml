import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

Button {
	id: root
	property bool expanded: false
	hoverEnabled: true

	implicitWidth: label.implicitWidth + Theme.widgetPaddingX
	implicitHeight: Theme.widgetHeight

	onClicked: {
		expanded = !expanded
	}

	contentItem: Text {
		id: label
		text: "󰐥"
		color: root.expanded ? Theme.textOnActive : Theme.textPrimary
		font.pixelSize: Theme.fontIconSize
		font.family: Theme.fontFamily
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}

	background: Rectangle {
		radius: Theme.radius
		color: root.expanded
			? Theme.widgetBackgroundActive
			: (root.hovered ? Theme.widgetBackgroundHover : Theme.widgetBackgroundIdle)
		border.width: Theme.borderWidth
		border.color: Theme.surfaceBorder
	}

	Process {
		id: powerAction
	}

	function runAction(cmd: string): void {
		powerAction.exec(["sh", "-c", cmd])
		root.expanded = false
	}

	Rectangle {
		visible: root.expanded
		y: root.height + Theme.popupOffset
		width: 250
		height: 130
		radius: Theme.radius
		color: Theme.widgetBackgroundHover
		border.width: Theme.borderWidth
		border.color: Theme.surfaceBorder
		z: 1000

		GridLayout {
			anchors.fill: parent
			anchors.margins: 8
			columns: 3
			rowSpacing: 6
			columnSpacing: 6

			Button {
				text: "Lock"
				onClicked: root.runAction("loginctl lock-session")
			}
			Button {
				text: "Logout"
				onClicked: root.runAction("hyprctl dispatch exit")
			}
			Button {
				text: "Suspend"
				onClicked: root.runAction("systemctl suspend")
			}
			Button {
				text: "Reboot"
				onClicked: root.runAction("systemctl reboot")
			}
			Button {
				text: "Shutdown"
				onClicked: root.runAction("systemctl poweroff")
			}
			Button {
				text: "Cancel"
				onClicked: root.expanded = false
			}
		}
	}
}

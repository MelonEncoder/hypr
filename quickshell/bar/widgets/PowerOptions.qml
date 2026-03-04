import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../../constants"

Rectangle {
	id: root
	property bool expanded: false
	property bool hovered: rootClickArea.containsMouse

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
		text: "󰐥"
		color: root.expanded ? Theme.colors.textOnActive : Theme.colors.text
		font.pixelSize: Theme.font.size
		font.family: Theme.font.family
	}
	MouseArea {
		id: rootClickArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: root.expanded = !root.expanded
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
		y: root.height + BarTheme.popupOffset
		width: 250
		height: 130
		radius: Theme.radius
		color: Theme.colors.surfaceHover
		border.width: Theme.borderSize
		border.color: Theme.colors.border
		z: 1000

		GridLayout {
			anchors.fill: parent
			anchors.margins: 8
			columns: 3
			rowSpacing: 6
			columnSpacing: 6

			Rectangle {
				Layout.fillWidth: true
				Layout.fillHeight: true
				radius: Theme.radius
				color: lockHover.containsMouse ? Theme.colors.surfaceActive : Theme.colors.surface
				border.width: Theme.borderSize
				border.color: Theme.colors.border
				Text {
					anchors.centerIn: parent
					text: "Lock"
					color: Theme.colors.text
					font.pixelSize: Theme.font.size
					font.family: Theme.font.family
				}
				MouseArea {
					id: lockHover
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: root.runAction("loginctl lock-session")
				}
			}
			Rectangle {
				Layout.fillWidth: true
				Layout.fillHeight: true
				radius: Theme.radius
				color: logoutHover.containsMouse ? Theme.colors.surfaceActive : Theme.colors.surface
				border.width: Theme.borderSize
				border.color: Theme.colors.border
				Text {
					anchors.centerIn: parent
					text: "Logout"
					color: Theme.colors.text
					font.pixelSize: Theme.font.size
					font.family: Theme.font.family
				}
				MouseArea {
					id: logoutHover
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: root.runAction("hyprctl dispatch exit")
				}
			}
			Rectangle {
				Layout.fillWidth: true
				Layout.fillHeight: true
				radius: Theme.radius
				color: suspendHover.containsMouse ? Theme.colors.surfaceActive : Theme.colors.surface
				border.width: Theme.borderSize
				border.color: Theme.colors.border
				Text {
					anchors.centerIn: parent
					text: "Suspend"
					color: Theme.colors.text
					font.pixelSize: Theme.font.size
					font.family: Theme.font.family
				}
				MouseArea {
					id: suspendHover
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: root.runAction("systemctl suspend")
				}
			}
			Rectangle {
				Layout.fillWidth: true
				Layout.fillHeight: true
				radius: Theme.radius
				color: rebootHover.containsMouse ? Theme.colors.surfaceActive : Theme.colors.surface
				border.width: Theme.borderSize
				border.color: Theme.colors.border
				Text {
					anchors.centerIn: parent
					text: "Reboot"
					color: Theme.colors.text
					font.pixelSize: Theme.font.size
					font.family: Theme.font.family
				}
				MouseArea {
					id: rebootHover
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: root.runAction("systemctl reboot")
				}
			}
			Rectangle {
				Layout.fillWidth: true
				Layout.fillHeight: true
				radius: Theme.radius
				color: shutdownHover.containsMouse ? Theme.colors.surfaceActive : Theme.colors.surface
				border.width: Theme.borderSize
				border.color: Theme.colors.border
				Text {
					anchors.centerIn: parent
					text: "Shutdown"
					color: Theme.colors.text
					font.pixelSize: Theme.font.size
					font.family: Theme.font.family
				}
				MouseArea {
					id: shutdownHover
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: root.runAction("systemctl poweroff")
				}
			}
			Rectangle {
				Layout.fillWidth: true
				Layout.fillHeight: true
				radius: Theme.radius
				color: cancelHover.containsMouse ? Theme.colors.surfaceActive : Theme.colors.surface
				border.width: Theme.borderSize
				border.color: Theme.colors.border
				Text {
					anchors.centerIn: parent
					text: "Cancel"
					color: Theme.colors.text
					font.pixelSize: Theme.font.size
					font.family: Theme.font.family
				}
				MouseArea {
					id: cancelHover
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: root.expanded = false
				}
			}
		}
	}
}

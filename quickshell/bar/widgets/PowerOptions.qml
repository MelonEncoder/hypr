import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import ".."
import "../../constants"

Rectangle {
	id: root
	property bool expanded: false
	property bool hovered: rootClickArea.containsMouse
	property bool pressed: rootClickArea.pressed

	implicitWidth: label.implicitWidth + (BarTheme.widget_padding * 2)
	implicitHeight: BarTheme.widget_height
	radius: Theme.radius_normal
	color: root.pressed
		? Theme.color_surface_pressed
		: (root.hovered ? Theme.color_surface_hover : Theme.color_surface)
	border.width: Theme.border_width
	border.color: Theme.color_border

	Text {
		id: label
		anchors.centerIn: parent
		text: "󰐥"
		color: Theme.color_text
		font.pixelSize: Theme.font_size
		font.family: Theme.font_family
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
		y: root.height + BarTheme.popup_offset
		width: 250
		height: 130
		radius: Theme.radius_normal
		color: Theme.color_surface
		border.width: Theme.border_width
		border.color: Theme.color_border
		z: 1000

		GridLayout {
			anchors.fill: parent
			anchors.margins: 8
			columns: 3
			rowSpacing: 6
			columnSpacing: 6

			Rectangle {
				property bool hovered: lockHover.containsMouse
				property bool pressed: lockHover.pressed
				Layout.fillWidth: true
				Layout.fillHeight: true
				radius: Theme.radius_normal
				color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : Theme.color_surface)
				border.width: Theme.border_width
				border.color: Theme.color_border
				Text {
					anchors.centerIn: parent
					text: "Lock"
					color: Theme.color_text
					font.pixelSize: Theme.font_size
					font.family: Theme.font_family
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
				property bool hovered: logoutHover.containsMouse
				property bool pressed: logoutHover.pressed
				Layout.fillWidth: true
				Layout.fillHeight: true
				radius: Theme.radius_normal
				color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : Theme.color_surface)
				border.width: Theme.border_width
				border.color: Theme.color_border
				Text {
					anchors.centerIn: parent
					text: "Logout"
					color: Theme.color_text
					font.pixelSize: Theme.font_size
					font.family: Theme.font_family
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
				property bool hovered: suspendHover.containsMouse
				property bool pressed: suspendHover.pressed
				Layout.fillWidth: true
				Layout.fillHeight: true
				radius: Theme.radius_normal
				color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : Theme.color_surface)
				border.width: Theme.border_width
				border.color: Theme.color_border
				Text {
					anchors.centerIn: parent
					text: "Suspend"
					color: Theme.color_text
					font.pixelSize: Theme.font_size
					font.family: Theme.font_family
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
				property bool hovered: rebootHover.containsMouse
				property bool pressed: rebootHover.pressed
				Layout.fillWidth: true
				Layout.fillHeight: true
				radius: Theme.radius_normal
				color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : Theme.color_surface)
				border.width: Theme.border_width
				border.color: Theme.color_border
				Text {
					anchors.centerIn: parent
					text: "Reboot"
					color: Theme.color_text
					font.pixelSize: Theme.font_size
					font.family: Theme.font_family
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
				property bool hovered: shutdownHover.containsMouse
				property bool pressed: shutdownHover.pressed
				Layout.fillWidth: true
				Layout.fillHeight: true
				radius: Theme.radius_normal
				color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : Theme.color_surface)
				border.width: Theme.border_width
				border.color: Theme.color_border
				Text {
					anchors.centerIn: parent
					text: "Shutdown"
					color: Theme.color_text
					font.pixelSize: Theme.font_size
					font.family: Theme.font_family
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
				property bool hovered: cancelHover.containsMouse
				property bool pressed: cancelHover.pressed
				Layout.fillWidth: true
				Layout.fillHeight: true
				radius: Theme.radius_normal
				color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : Theme.color_surface)
				border.width: Theme.border_width
				border.color: Theme.color_border
				Text {
					anchors.centerIn: parent
					text: "Cancel"
					color: Theme.color_text
					font.pixelSize: Theme.font_size
					font.family: Theme.font_family
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

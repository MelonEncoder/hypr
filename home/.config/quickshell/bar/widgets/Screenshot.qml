pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import ".."
import "../../constants"

Rectangle {
	id: root
	property bool expanded: false
	property bool hovered: clickArea.containsMouse
	property bool pressed: clickArea.pressed
	readonly property int popupWidth: 220
	readonly property int optionHeight: BarTheme.widget_height

	function trigger(mode: string): void {
		ipcExec.exec([
			"quickshell",
			"ipc",
			"call",
			"screenshot",
			mode
		])
		root.expanded = false
	}

	implicitWidth: content.implicitWidth + (BarTheme.widget_padding * 2)
	implicitHeight: BarTheme.widget_height
	radius: Theme.radius_normal
	color: root.pressed ? Theme.color_surface_pressed : (root.hovered ? Theme.color_surface_hover : Theme.color_surface)
	border.width: Theme.border_width
	border.color: Theme.color_border

	Behavior on color {
		ColorAnimation {
			duration: Animations.duration_hover
			easing.type: Animations.easing_standard
		}
	}

	Item {
		id: content
		anchors.centerIn: parent
		implicitWidth: iconText.implicitWidth
		implicitHeight: iconText.implicitHeight

		Text {
			id: iconText
			anchors.centerIn: parent
			text: "󰄀"
			color: Theme.color_text
			font.pixelSize: Theme.font_size + 3
			font.family: Theme.font_family_icon
		}
	}

	MouseArea {
		id: clickArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: root.expanded = !root.expanded
	}

	PopupWindow {
		id: dropdown
		anchor.item: root
		visible: root.expanded
		anchor.rect.x: -(root.popupWidth - root.width)
		anchor.rect.y: root.height + BarTheme.popup_offset_y
		implicitWidth: root.popupWidth + (BarTheme.widget_padding * 2)
		implicitHeight: popupContent.implicitHeight + (BarTheme.widget_padding * 2)
		color: "transparent"

		Rectangle {
			anchors.fill: parent
			radius: Theme.radius_background
			color: Theme.color_background
			border.width: Theme.border_width
			border.color: Theme.color_border

				Column {
					id: popupContent
					x: BarTheme.widget_padding
					y: BarTheme.widget_padding
					width: root.popupWidth
					spacing: BarTheme.inner_spacing
					height: childrenRect.height

				Rectangle {
					id: fullscreenButton
					implicitWidth: parent.width
					implicitHeight: root.optionHeight
					radius: Theme.radius_normal
					color: fullscreenMouse.pressed ? Theme.color_surface_pressed : (fullscreenMouse.containsMouse ? Theme.color_surface_hover : Theme.color_surface)

					RowLayout {
						anchors.fill: parent
						anchors.leftMargin: BarTheme.widget_padding
						anchors.rightMargin: BarTheme.widget_padding
						spacing: BarTheme.inner_spacing

						Text {
							text: "󰍹"
							color: Theme.color_text
							font.pixelSize: Theme.font_size + 2
							font.family: Theme.font_family_icon
						}

						Text {
							Layout.fillWidth: true
							text: "Full screen"
							color: Theme.color_text
							font.pixelSize: Theme.font_size
							font.family: Theme.font_family
						}
					}

					MouseArea {
						id: fullscreenMouse
						anchors.fill: parent
						hoverEnabled: true
						cursorShape: Qt.PointingHandCursor
						onClicked: root.trigger("fullscreen")
					}
				}

				Rectangle {
					id: selectionButton
					implicitWidth: parent.width
					implicitHeight: root.optionHeight
					radius: Theme.radius_normal
					color: selectionMouse.pressed ? Theme.color_surface_pressed : (selectionMouse.containsMouse ? Theme.color_surface_hover : Theme.color_surface)

					RowLayout {
						anchors.fill: parent
						anchors.leftMargin: BarTheme.widget_padding
						anchors.rightMargin: BarTheme.widget_padding
						spacing: BarTheme.inner_spacing

						Text {
							text: "󰹑"
							color: Theme.color_text
							font.pixelSize: Theme.font_size + 2
							font.family: Theme.font_family_icon
						}

						Text {
							Layout.fillWidth: true
							text: "Select area"
							color: Theme.color_text
							font.pixelSize: Theme.font_size
							font.family: Theme.font_family
						}
					}

					MouseArea {
						id: selectionMouse
						anchors.fill: parent
						hoverEnabled: true
						cursorShape: Qt.PointingHandCursor
						onClicked: root.trigger("selection")
					}
				}
			}
		}
	}

	Process {
		id: ipcExec
	}
}

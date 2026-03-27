pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import "SystemOptions"
import ".."

Rectangle {
	id: root
	property bool expanded: false
	property bool hovered: clickArea.containsMouse
	property bool pressed: clickArea.pressed
	property string widgetIcon: ""
	property string panelScreenName: ""
	property int ddcDisplay: 1
	readonly property int iconSpacing: 4
	readonly property int slotSize: Math.max(1, Theme.bar_widget_height - 8)
	readonly property int popupWidth: 280
	readonly property int popupMaxHeight: 420
	readonly property var optionComponents: [
		screenshotComponent,
		brightnessComponent,
		wifiComponent,
		bluetoothComponent,
		powerProfilesComponent
	]

	implicitWidth: slotSize + (Theme.bar_widget_padding * 2)
	implicitHeight: Theme.bar_widget_height
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
		id: icon
		anchors.fill: parent

		Text {
			anchors.centerIn: parent
			text: root.widgetIcon
			color: Theme.color_text
			font.pixelSize: Theme.font_size + 2
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
		anchor.rect.x: 0
		anchor.rect.y: Theme.bar_widget_height + (Theme.bar_padding * 2)
		implicitHeight: dropdown.screen.height
		implicitWidth: dropdown.screen.width
		color: "transparent"

		Rectangle {
		    id: backdrop
            anchors.fill: parent
            color: "transparent"

    		MouseArea {
    			anchors.fill: parent
    			enabled: root.expanded
    			onClicked: root.expanded = false
    		}
    	}

		Rectangle {
		    id: popupContainer
			x: dropdown.width - root.popupWidth - 30
			y: Theme.bar_widget_height + (Theme.bar_padding * 2)
			width: root.popupWidth + (Theme.bar_widget_padding * 2)
			height: popupContent.implicitHeight + (Theme.bar_widget_padding * 2)
			radius: Theme.radius_background
			color: Theme.color_background
			border.width: Theme.border_width
			border.color: Theme.color_border

			Item {
				id: popupContent
				x: Theme.bar_widget_padding
				y: Theme.bar_widget_padding
				width: root.popupWidth
				implicitHeight: optionsColumn.implicitHeight

				Column {
					id: optionsColumn
					width: parent.width
					spacing: 6

					Screenshot {
						width: popupContent.width
					}
					Brightness {
						width: popupContent.width
						panelScreenName: root.panelScreenName
						ddcDisplay: root.ddcDisplay
					}
					Volume {
						width: popupContent.width
					}
					Wifi {
						width: popupContent.width
					}
					Bluetooth {
						width: popupContent.width
					}
					PowerProfiles {
						width: popupContent.width
					}
				}
			}
		}
	}
}

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import "SystemOptions"
import ".." as Bar
import "../../constants" as Constants

Rectangle {
	id: root
	property bool expanded: false
	property bool hovered: clickArea.containsMouse
	property bool pressed: clickArea.pressed
	property string widgetIcon: ""
	property string panelScreenName: ""
	property int ddcDisplay: 1
	readonly property int iconSpacing: 4
	readonly property int slotSize: Math.max(1, Bar.BarTheme.widget_height - 8)
	readonly property int popupWidth: 280
	readonly property int popupMaxHeight: 420
	readonly property var optionComponents: [
		brightnessComponent,
		wifiComponent,
		bluetoothComponent,
		powerProfilesComponent
	]

	implicitWidth: slotSize + (Bar.BarTheme.widget_padding * 2)
	implicitHeight: Bar.BarTheme.widget_height
	radius: Constants.Theme.radius_normal
	color: root.pressed ? Constants.Theme.color_surface_pressed : (root.hovered ? Constants.Theme.color_surface_hover : Constants.Theme.color_surface)
	border.width: Constants.Theme.border_width
	border.color: Constants.Theme.color_border

	Behavior on color {
		ColorAnimation {
			duration: Constants.Animations.duration_hover
			easing.type: Constants.Animations.easing_standard
		}
	}


	Item {
		id: icon
		anchors.fill: parent

		Text {
			anchors.centerIn: parent
			text: root.widgetIcon
			color: Constants.Theme.color_text
			font.pixelSize: Constants.Theme.font_size + 2
			font.family: Constants.Theme.font_family_icon
		}
	}

	MouseArea {
		id: clickArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: {
			root.expanded = !root.expanded
		}
	}

		PopupWindow {
			id: dropdown
			anchor.item: root
			visible: root.expanded

		anchor.rect.x: -(root.popupWidth - root.width)
		anchor.rect.y: root.height + Bar.BarTheme.popup_offset_y

			implicitWidth: root.popupWidth + (Bar.BarTheme.widget_padding * 2)
			implicitHeight: popupContent.implicitHeight + (Bar.BarTheme.widget_padding * 2)
			color: "transparent"

		Rectangle {
			anchors.fill: parent
			radius: Constants.Theme.radius_background
			color: Constants.Theme.color_background
			border.width: Constants.Theme.border_width
			border.color: Constants.Theme.color_border
			clip: true

			Item {
				id: popupContent
				x: Bar.BarTheme.widget_padding
				y: Bar.BarTheme.widget_padding
				width: root.popupWidth
				implicitHeight: optionsColumn.implicitHeight

				Column {
					id: optionsColumn
					width: parent.width
					spacing: Bar.BarTheme.inner_spacing

					Repeater {
						model: root.optionComponents

						Loader {
							required property var modelData
							width: optionsColumn.width
							height: item ? item.implicitHeight : 0
							sourceComponent: modelData
						}
					}
				}
			}
		}
	}

	Component {
		id: brightnessComponent

		Brightness {
			width: popupContent.width
			panelScreenName: root.panelScreenName
			ddcDisplay: root.ddcDisplay
		}
	}

	Component {
		id: wifiComponent

		Wifi {
			width: popupContent.width
		}
	}

	Component {
		id: bluetoothComponent

		Bluetooth {
			width: popupContent.width
		}
	}

	Component {
		id: powerProfilesComponent

		PowerProfiles {
			width: popupContent.width
		}
	}
}

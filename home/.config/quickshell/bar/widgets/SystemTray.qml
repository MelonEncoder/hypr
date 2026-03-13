pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import ".."
import "../../constants"

Rectangle {
	id: root
	property bool expanded: false
	property bool hovered: clickArea.containsMouse
	property bool pressed: clickArea.pressed

	implicitWidth: label.implicitWidth + (BarTheme.widget_padding * 2)
	implicitHeight: BarTheme.widget_height
	radius: Theme.radius_normal
	color: root.pressed
		? Theme.color_surface_pressed
		: (root.hovered ? Theme.color_surface_hover : Theme.color_surface)
	border.width: Theme.border_width
	border.color: Theme.color_border

	Behavior on color {
		ColorAnimation {
			duration: Animations.duration_hover
			easing.type: Animations.easing_standard
		}
	}

	Text {
		id: label
		anchors.centerIn: parent
		text: root.expanded ?  "" : ""
		color: Theme.color_text
		font.pixelSize: Theme.font_size
		font.family: Theme.font_family_icon
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
		visible: root.expanded || dropdownBackground.opacity > 0.01

		anchor.rect.x: -1 * (trayRow.width / 2) 
		anchor.rect.y: root.height + BarTheme.popup_offset_y

		implicitWidth: trayRow.implicitWidth + (BarTheme.widget_padding * 2)
		implicitHeight: trayRow.implicitHeight + (BarTheme.widget_padding * 2)
		color: "transparent"

		Rectangle {
			id: dropdownBackground
			anchors.fill: parent
			radius: Theme.radius_background
			color: Theme.color_background
			border.width: Theme.border_width
			border.color: Theme.color_border
			clip: true
			opacity: root.expanded ? 1 : 0
			scale: root.expanded ? 1 : Animations.dropdown_scale_closed
			y: root.expanded ? 0 : -Animations.dropdown_offset
			transformOrigin: Item.Top

			Behavior on opacity {
				NumberAnimation {
					duration: Animations.duration_dropdown
					easing.type: Animations.easing_emphasized
				}
			}

			Behavior on scale {
				NumberAnimation {
					duration: Animations.duration_dropdown
					easing.type: Animations.easing_emphasized
				}
			}

			Behavior on y {
				NumberAnimation {
					duration: Animations.duration_dropdown
					easing.type: Animations.easing_emphasized
				}
			}

			RowLayout {
				id: trayRow
				anchors.centerIn: parent
				spacing: BarTheme.inner_spacing

				Repeater {
					model: SystemTray.items

					Rectangle {
						id: trayItem
						required property var modelData
						property bool hovered: trayHover.containsMouse
						property bool pressed: trayHover.pressed
						readonly property string itemLabel: {
							if (!modelData) return "?"
							var text = (modelData.tooltipTitle || modelData.title || modelData.id || "?") + ""
							return text.length > 0 ? text.charAt(0).toUpperCase() : "?"
						}
						radius: Theme.radius_normal
						color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : Theme.color_surface)
						implicitWidth: BarTheme.tray_item_size + (BarTheme.widget_padding)
						implicitHeight: BarTheme.tray_item_size + (BarTheme.widget_padding)

						IconImage {
							id: trayIcon
							anchors.centerIn: parent
							source: trayItem.modelData.icon
							implicitSize: BarTheme.tray_icon_size
							visible: source.toString() !== "" && status === Image.Ready
							asynchronous: true
						}

						Text {
							anchors.centerIn: parent
							visible: !trayIcon.visible
							text: trayItem.itemLabel
							color: Theme.color_text
							font.pixelSize: Math.max(9, Theme.font_size - 1)
							font.family: Theme.font_family
							font.bold: true
						}

						MouseArea {
							id: trayHover
							anchors.fill: parent
							hoverEnabled: true
							cursorShape: Qt.PointingHandCursor
							acceptedButtons: Qt.LeftButton | Qt.RightButton
							onClicked: function(mouse) {
								if (!trayItem.modelData) return

								if (mouse.button == Qt.LeftButton) {
									if (!trayItem.modelData.onlyMenu) {
										trayItem.modelData.activate()
									}
								}

								if (mouse.button == Qt.RightButton && trayItem.modelData.hasMenu) {
									var point = trayItem.mapToItem(null, Math.round(trayItem.width / 2), trayItem.height)
									trayItem.modelData.display(dropdown, Math.round(point.x), Math.round(point.y))
								}
							}
						}
					}
				}
			}
		}
	}
}

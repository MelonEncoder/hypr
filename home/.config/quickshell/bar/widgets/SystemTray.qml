pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import ".." as Bar
import "../../constants" as Constants

Rectangle {
	id: root
	property bool expanded: false
	property bool hovered: clickArea.containsMouse
	property bool pressed: clickArea.pressed

	implicitWidth: label.implicitWidth + (Bar.BarTheme.widget_padding * 2)
	implicitHeight: Bar.BarTheme.widget_height
	radius: Constants.Theme.radius_normal
	color: root.pressed
		? Constants.Theme.color_surface_pressed
		: (root.hovered ? Constants.Theme.color_surface_hover : Constants.Theme.color_surface)
	border.width: Constants.Theme.border_width
	border.color: Constants.Theme.color_border

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
		color: Constants.Theme.color_text
		font.pixelSize: Constants.Theme.font_size
		font.family: Constants.Theme.font_family_icon
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
		implicitWidth: dropdown.screen.width
		implicitHeight: dropdown.screen.height
		color: "transparent"

		Rectangle {
		    width: parent.width
			height: parent.height
			color: "transparent"
			MouseArea {
			    anchors.fill: parent
				enabled: root.expanded
				onClicked: root.expanded = false
			}
		}

		Rectangle {
			x: dropdown.width - 350
			y: Bar.BarTheme.popup_offset_y
			width: trayRow.implicitWidth + (Bar.BarTheme.widget_padding * 2)
			height: trayRow.implicitHeight + (Bar.BarTheme.widget_padding * 2)
			radius: Constants.Theme.radius_background
			color: Constants.Theme.color_background
			border.width: Constants.Theme.border_width
			border.color: Constants.Theme.color_border
			opacity: root.expanded ? 1 : 0
			scale: root.expanded ? 1 : Animations.dropdown_scale_closed

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
				spacing: Bar.BarTheme.inner_spacing

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
						radius: Constants.Theme.radius_normal
						color: pressed ? Constants.Theme.color_surface_pressed : (hovered ? Constants.Theme.color_surface_hover : Constants.Theme.color_surface)
						implicitWidth: Bar.BarTheme.tray_item_size + (Bar.BarTheme.widget_padding)
						implicitHeight: Bar.BarTheme.tray_item_size + (Bar.BarTheme.widget_padding)

						IconImage {
							id: trayIcon
							anchors.centerIn: parent
							source: {
								var s = (trayItem.modelData.icon || "").toString()
								if (s.startsWith("image://icon/") && s.indexOf("?fallback=") === -1)
									return s + "?fallback=application-x-executable"
								return s
							}
							implicitSize: Bar.BarTheme.tray_icon_size
							visible: source.toString() !== "" && status === Image.Ready
							asynchronous: true
						}

						Text {
							anchors.centerIn: parent
							visible: !trayIcon.visible
							text: trayItem.itemLabel
							color: Constants.Theme.color_text
							font.pixelSize: Math.max(9, Constants.Theme.font_size - 1)
							font.family: Constants.Theme.font_family
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

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Widgets
import Quickshell
import ".."
import "../../constants"

Rectangle {
	id: root
	property bool expanded: false
	property bool hovered: clickArea.containsMouse
	property bool pressed: clickArea.pressed
	property int brightnessPercent: 50
	property int brightnessMax: 100
	property int ddcDisplay: 1
	property int pendingBrightnessRaw: -1
	readonly property int iconSpacing: 4
	readonly property int slotSize: Math.max(1, BarTheme.widget_height - 8)
	readonly property int popupWidth: 280

	function clampPercent(value: int): int {
		return Math.max(0, Math.min(100, value))
	}

	function setBrightness(percent: int): void {
		var next = clampPercent(percent)
		if (next === root.brightnessPercent) return
		root.brightnessPercent = next
		var max = Math.max(1, root.brightnessMax)
		root.pendingBrightnessRaw = Math.round((next * max) / 100)
		brightnessApplyTimer.restart()
	}

	function updateBrightnessFromTrack(mouseX: real): void {
		var width = Math.max(1, brightnessTrack.width)
		var ratio = Math.max(0, Math.min(1, mouseX / width))
		setBrightness(Math.round(ratio * 100))
	}

	function runPowerAction(action: string): void {
		var cmd = ""
		if (action === "poweroff") cmd = "systemctl poweroff"
		else if (action === "reboot") cmd = "systemctl reboot"
		else if (action === "suspend") cmd = "systemctl suspend"
		else if (action === "logout") cmd = "hyprctl dispatch exit"
		else if (action === "lock") cmd = "hyprlock"
		if (cmd.length === 0) return

		root.expanded = false
		powerControl.exec(["sh", "-c", cmd + " >/dev/null 2>&1 || true"])
	}

	implicitWidth: slotSize + (BarTheme.widget_padding * 2)
	implicitHeight: BarTheme.widget_height
	radius: Theme.radius_normal
	color: root.pressed ? Theme.color_surface_pressed : (root.hovered ? Theme.color_surface_hover : Theme.color_surface)
	border.width: Theme.border_width
	border.color: Theme.color_border


	Item {
		id: icon
		anchors.fill: parent

		Text {
			anchors.centerIn: parent
			text: ""
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
		onClicked: {
			root.expanded = !root.expanded
			if (root.expanded) brightnessProbe.exec(["sh", "-c", "ddcutil --brief --display " + root.ddcDisplay + " getvcp 10 2>/dev/null || true"])
		}
	}

	PopupWindow {
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
			clip: true

			ColumnLayout {
				id: popupContent
				anchors.fill: parent
				anchors.margins: BarTheme.widget_padding
				spacing: BarTheme.inner_spacing
				width: root.popupWidth

				RowLayout {
					id: powerOptions
					Layout.fillWidth: true
					spacing: BarTheme.inner_spacing

					Repeater {
						model: [
							{ action: "poweroff", icon: "" },
							{ action: "reboot", icon: "" },
							{ action: "suspend", icon: "" },
							{ action: "logout", icon: "󰍃" },
							{ action: "lock", icon: ""}
						]

						Rectangle {
							id: powerButton
							required property var modelData
							property bool hovered: powerHover.containsMouse
							property bool pressed: powerHover.pressed

							Layout.fillWidth: true
							Layout.preferredHeight: width
							radius: Theme.radius_normal
							color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : Theme.color_surface)

							Text {
								anchors.centerIn: parent
								text: powerButton.modelData.icon
								color: Theme.color_text
								font.pixelSize: Theme.font_size + 2
								font.family: Theme.font_family_icon
							}

							MouseArea {
								id: powerHover
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor
								onClicked: root.runPowerAction(powerButton.modelData.action)
							}
						}
					}
				}
				
					Rectangle {
						id: brightnessControl
						Layout.fillWidth: true
						Layout.preferredHeight: brightnessContent.implicitHeight + (BarTheme.widget_padding * 2)
						radius: Theme.radius_normal
						color: Theme.color_surface

						ColumnLayout {
							id: brightnessContent
							anchors.fill: parent
							anchors.margins: BarTheme.widget_padding
							spacing: BarTheme.inner_spacing

						Text {
							id: brightnessLabel
							text: "Brightness " + root.brightnessPercent + "%"
							color: Theme.color_text
							font.pixelSize: Theme.font_size
							font.family: Theme.font_family
							Layout.fillWidth: true
						}

						Rectangle {
							id: brightnessTrack
							Layout.fillWidth: true
							Layout.preferredHeight: 8
							radius: 4
							color: Theme.color_surface_hover

							Rectangle {
								id: brightnessIndicator
								width: Math.round((brightnessTrack.width * root.brightnessPercent) / 100)
								height: parent.height
								radius: parent.radius
								color: Theme.color_text
							}

							MouseArea {
								anchors.fill: parent
								hoverEnabled: true
								onPressed: function(mouse) {
									root.updateBrightnessFromTrack(mouse.x)
								}
								onPositionChanged: function(mouse) {
									if (!pressed) return
									root.updateBrightnessFromTrack(mouse.x)
								}
							}
						}
					}
				}

				Rectangle {
					id: wifiControl
					Layout.fillWidth: true
					Layout.preferredHeight: wifiMenu.implicitHeight + BarTheme.widget_padding
					radius: Theme.radius_normal
					color: Theme.color_surface

					ColumnLayout {
						id: wifiMenu
						anchors.fill: parent
						anchors.margins: Math.round(BarTheme.widget_padding / 2)
						spacing: 4

						Rectangle {
							Layout.fillWidth: true
							Layout.preferredHeight: BarTheme.widget_height
							radius: Theme.radius_normal
							color: Theme.color_surface_hover

							Text {
								anchors.left: parent.left
								anchors.leftMargin: 8
								anchors.verticalCenter: parent.verticalCenter
								text: "Wi-Fi"
								color: Theme.color_text
								font.pixelSize: Theme.font_size
								font.family: Theme.font_family
							}
						}

						ColumnLayout {
							Layout.fillWidth: true
							spacing: 3

							Repeater {
								model: ["HomeNet", "Office-5G", "Phone Hotspot"]

								Rectangle {
									required property var modelData
									Layout.fillWidth: true
									Layout.preferredHeight: 24
									radius: Theme.radius_normal
									color: "transparent"

									Text {
										anchors.left: parent.left
										anchors.leftMargin: 8
										anchors.verticalCenter: parent.verticalCenter
										text: parent.modelData
										color: Theme.color_text
										font.pixelSize: Theme.font_size
										font.family: Theme.font_family
										elide: Text.ElideRight
										width: parent.width - 16
									}
								}
							}
						}
					}
				}

				Rectangle {
					id: bluetoothControl
					Layout.fillWidth: true
					Layout.preferredHeight: btMenu.implicitHeight + BarTheme.widget_padding
					radius: Theme.radius_normal
					color: Theme.color_surface

					ColumnLayout {
						id: btMenu
						anchors.fill: parent
						anchors.margins: Math.round(BarTheme.widget_padding / 2)
						spacing: 4

						Rectangle {
							Layout.fillWidth: true
							Layout.preferredHeight: BarTheme.widget_height
							radius: Theme.radius_normal
							color: Theme.color_surface_hover

							Text {
								anchors.left: parent.left
								anchors.leftMargin: 8
								anchors.verticalCenter: parent.verticalCenter
								text: "Bluetooth"
								color: Theme.color_text
								font.pixelSize: Theme.font_size
								font.family: Theme.font_family
							}
						}

						ColumnLayout {
							Layout.fillWidth: true
							spacing: 3

							Repeater {
								model: ["Headphones", "Keyboard", "Controller"]

								Rectangle {
									required property var modelData
									Layout.fillWidth: true
									Layout.preferredHeight: 24
									radius: Theme.radius_normal
									color: "transparent"

									Text {
										anchors.left: parent.left
										anchors.leftMargin: 8
										anchors.verticalCenter: parent.verticalCenter
										text: parent.modelData
										color: Theme.color_text
										font.pixelSize: Theme.font_size
										font.family: Theme.font_family
										elide: Text.ElideRight
										width: parent.width - 16
									}
								}
							}
						}
					}
				}
			}
		}
	}


	Process {
		id: powerControl
	}

	Process {
		id: brightnessSet
	}

	Process {
		id: brightnessProbe
		stdout: StdioCollector {
			id: brightnessOut
			waitForEnd: true
			onStreamFinished: {
				var raw = text.trim()
				if (raw.length === 0) return
				var currentMatch = raw.match(/current value =\s*([0-9]+)/)
				var maxMatch = raw.match(/max value =\s*([0-9]+)/)
				if (!currentMatch || !maxMatch) return
				var current = parseInt(currentMatch[1])
				var max = parseInt(maxMatch[1])
				if (isNaN(current) || isNaN(max) || max <= 0) return
				root.brightnessMax = max
				root.brightnessPercent = root.clampPercent(Math.round((current * 100) / max))
			}
		}
	}

	Timer {
		id: brightnessApplyTimer
		interval: 120
		running: false
		repeat: false
		onTriggered: {
			if (root.pendingBrightnessRaw < 0) return
			brightnessSet.exec([
				"sh",
				"-c",
				"ddcutil --display " + root.ddcDisplay + " setvcp 10 " + root.pendingBrightnessRaw + " >/dev/null 2>&1 || true"
			])
		}
	}

	Component.onCompleted: brightnessProbe.exec(["sh", "-c", "ddcutil --brief --display " + root.ddcDisplay + " getvcp 10 2>/dev/null || true"])
}

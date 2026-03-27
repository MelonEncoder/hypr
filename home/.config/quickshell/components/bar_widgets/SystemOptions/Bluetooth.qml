import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import "../../"

Rectangle {
	id: root
	property bool expanded: false
	readonly property int sectionMargin: Math.round(Theme.bar_widget_padding / 2)
	readonly property var btAdapter: Bluetooth.defaultAdapter
	readonly property var btDevices: btAdapter && btAdapter.devices ? btAdapter.devices.values : []
	readonly property bool enabled: !!btAdapter && btAdapter.enabled
	readonly property bool discovering: !!btAdapter && btAdapter.discovering
	readonly property var connectedDevices: getConnectedBtDevices()
	readonly property var availableDevices: getAvailableBtDevices()
	readonly property int expandedContentHeight: bluetoothExpandedContent.implicitHeight

	function btName(device: var): string {
		if (!device) return ""
		if (device.name && isUsefulBtName(device.name)) return device.name
		if (device.deviceName && isUsefulBtName(device.deviceName)) return device.deviceName
		return ""
	}

	function currentBluetoothSubtitle(): string {
		return root.enabled ? "On" : "Off"
	}

	function isUsefulBtName(value: string): bool {
		if (!value || value.length === 0) return false
		var trimmed = value.trim()
		if (trimmed.length === 0) return false
		if (/^([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}$/.test(trimmed)) return false
		return true
	}

	function getConnectedBtDevices(): var {
		var connected = []
		for (var i = 0; i < btDevices.length; i++) {
			if (btDevices[i] && btDevices[i].connected && btName(btDevices[i]).length > 0) connected.push(btDevices[i])
		}
		return connected
	}

	function getAvailableBtDevices(): var {
		var available = []
		for (var i = 0; i < btDevices.length; i++) {
			var dev = btDevices[i]
			if (!dev || dev.connected || dev.blocked || btName(dev).length === 0) continue
			available.push(dev)
		}
		return available
	}

	function refreshBluetooth(): void {
		if (!btAdapter || !btAdapter.enabled || btAdapter.discovering) return
		btAdapter.discovering = true
	}

	implicitWidth: 280
	implicitHeight: btFrame.implicitHeight + (root.sectionMargin * 2)
	width: implicitWidth
	height: implicitHeight
	Layout.fillWidth: true
	Layout.preferredWidth: implicitWidth
	Layout.preferredHeight: implicitHeight
	radius: Theme.radius_normal
	color: Theme.color_surface

	Item {
		id: btFrame
		x: root.sectionMargin
		y: root.sectionMargin
		width: parent.width - (root.sectionMargin * 2)
		implicitHeight: btMenu.implicitHeight

		ColumnLayout {
			id: btMenu
			width: parent.width
			spacing: 4

			Rectangle {
				id: bluetoothHeader
				property bool hovered: bluetoothHeaderMouse.containsMouse
				property bool pressed: bluetoothHeaderMouse.pressed
				Layout.fillWidth: true
				Layout.preferredHeight: Theme.bar_widget_height * 1.5
				radius: Theme.radius_normal
				color: pressed ? Theme.color_surface_pressed : Theme.color_surface_hover

				Behavior on color {
					ColorAnimation {
						duration: Animations.duration_hover
						easing.type: Animations.easing_standard
					}
				}

				RowLayout {
					anchors {
						left: parent.left
						right: parent.right
						verticalCenter: parent.verticalCenter
						leftMargin: 10
						rightMargin: 10
					}
					spacing: 12

					Text {
						text: root.enabled ? "󰂱" : "󰂲"
						color: Theme.color_text
						font.pixelSize: Theme.font_size + 2
						font.family: Theme.font_family_icon
						Layout.alignment: Qt.AlignVCenter
					}

					Column {
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignVCenter
						spacing: 1

						Text {
							text: root.enabled ? "Bluetooth" : "Bluetooth Off"
							color: Theme.color_text
							font.pixelSize: Theme.font_size
							font.family: Theme.font_family
						}

						Text {
							text: root.currentBluetoothSubtitle()
							color: Theme.color_text_subtle
							font.pixelSize: Theme.font_size
							font.family: Theme.font_family
							elide: Text.ElideRight
							width: Math.max(0, bluetoothHeader.width - 60)
						}
					}

					Text {
						text: root.expanded ? "" : ""
						color: Theme.color_text_subtle
						font.pixelSize: Theme.font_size - 2
						font.family: Theme.font_family_icon
						Layout.alignment: Qt.AlignVCenter
					}
				}

				MouseArea {
					id: bluetoothHeaderMouse
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: {
						root.expanded = !root.expanded
						if (root.expanded) root.refreshBluetooth()
					}
				}
			}

			Item {
				visible: root.expanded || opacity > 0.01
				Layout.fillWidth: true
				Layout.preferredHeight: root.expanded ? root.expandedContentHeight : 0
				implicitHeight: root.expanded ? root.expandedContentHeight : 0
				opacity: root.expanded ? 1 : 0
				clip: true

				Behavior on Layout.preferredHeight {
					NumberAnimation {
						duration: Animations.duration_dropdown_section
						easing.type: Animations.easing_emphasized
					}
				}

				Behavior on opacity {
					NumberAnimation {
						duration: Animations.duration_dropdown_section
						easing.type: Animations.easing_emphasized
					}
				}

				ColumnLayout {
					id: bluetoothExpandedContent
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: 3

					Text {
						text: "Connected"
						color: Theme.color_text_subtle
						font.pixelSize: Theme.font_size
						font.family: Theme.font_family
						Layout.fillWidth: true
						Layout.topMargin: 4
					}

					Repeater {
						model: root.connectedDevices

						Rectangle {
							id: connectedBtDevice
							required property var modelData
							property bool hovered: connectedDeviceMouse.containsMouse
							property bool pressed: connectedDeviceMouse.pressed
							Layout.fillWidth: true
							Layout.preferredHeight: Theme.bar_widget_height
							radius: Theme.radius_normal
							color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")

							Behavior on color {
								ColorAnimation {
									duration: Animations.duration_hover
									easing.type: Animations.easing_standard
								}
							}

							Text {
								anchors.left: parent.left
								anchors.leftMargin: 10
								anchors.verticalCenter: parent.verticalCenter
								text: root.btName(connectedBtDevice.modelData)
								color: Theme.color_text
								font.pixelSize: Theme.font_size
								font.family: Theme.font_family
								elide: Text.ElideRight
								width: parent.width - 20
							}

							MouseArea {
								id: connectedDeviceMouse
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor
								onClicked: connectedBtDevice.modelData.disconnect()
							}
						}
					}

					Rectangle {
						Layout.fillWidth: true
						Layout.preferredHeight: Theme.bar_widget_height
						radius: Theme.radius_normal
						color: "transparent"
						visible: root.connectedDevices.length === 0

						Text {
							anchors.left: parent.left
							anchors.leftMargin: 10
							anchors.verticalCenter: parent.verticalCenter
							text: !btAdapter
								? "Bluetooth unavailable"
								: (root.enabled ? "None connected" : "Bluetooth disabled")
							color: Theme.color_text_subtle
							font.pixelSize: Theme.font_size
							font.family: Theme.font_family
						}
					}

					Text {
						text: "Available"
						color: Theme.color_text_subtle
						font.pixelSize: Theme.font_size
						font.family: Theme.font_family
						Layout.fillWidth: true
						Layout.topMargin: 4
					}

					Repeater {
						model: root.availableDevices

						Rectangle {
							id: availableBtDevice
							required property var modelData
							property bool hovered: availableDeviceMouse.containsMouse
							property bool pressed: availableDeviceMouse.pressed
							Layout.fillWidth: true
							Layout.preferredHeight: Theme.bar_widget_height
							radius: Theme.radius_normal
							color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")

							Behavior on color {
								ColorAnimation {
									duration: Animations.duration_hover
									easing.type: Animations.easing_standard
								}
							}

							Text {
								anchors.left: parent.left
								anchors.leftMargin: 10
								anchors.verticalCenter: parent.verticalCenter
								text: root.btName(availableBtDevice.modelData)
								color: Theme.color_text
								font.pixelSize: Theme.font_size
								font.family: Theme.font_family
								elide: Text.ElideRight
								width: parent.width - 20
							}

							MouseArea {
								id: availableDeviceMouse
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor
								onClicked: availableBtDevice.modelData.connect()
							}
						}
					}

					Rectangle {
						Layout.fillWidth: true
						Layout.preferredHeight: Theme.bar_widget_height
						radius: Theme.radius_normal
						color: "transparent"
						visible: root.availableDevices.length === 0

						Text {
							anchors.left: parent.left
							anchors.leftMargin: 10
							anchors.verticalCenter: parent.verticalCenter
							text: !btAdapter
								? "Bluetooth unavailable"
								: (root.enabled
									? (root.discovering ? "Scanning..." : "None available")
									: "Bluetooth disabled")
							color: Theme.color_text_subtle
							font.pixelSize: Theme.font_size
							font.family: Theme.font_family
						}
					}
				}
			}
		}
	}

	Timer {
		id: bluetoothDiscoveryStop
		interval: 10000
		running: root.expanded && root.discovering
		repeat: false
		onTriggered: {
			if (btAdapter && btAdapter.discovering) btAdapter.discovering = false
		}
	}
}

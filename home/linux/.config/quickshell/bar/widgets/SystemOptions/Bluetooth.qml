import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import "../../../constants" as Constants
import "../../" as Bar

Rectangle {
	id: root
	property bool expanded: false
	readonly property int sectionMargin: Math.round(Bar.BarTheme.widget_padding / 2)
	readonly property var btAdapter: Bluetooth.defaultAdapter
	readonly property var btDevices: btAdapter && btAdapter.devices && btAdapter.devices.values ? btAdapter.devices.values : []
	readonly property bool enabled: !!btAdapter && btAdapter.enabled
	readonly property bool discovering: !!btAdapter && btAdapter.discovering
	readonly property var connectedDevices: getConnectedBtDevices()
	readonly property var availableDevices: getAvailableBtDevices()
	readonly property int expandedContentHeight: bluetoothExpandedContent.implicitHeight

	function btName(device: var): string {
		if (!device) return ""
		if (device.deviceName && isUsefulBtName(device.deviceName)) return device.deviceName
		if (device.name && isUsefulBtName(device.name)) return device.name
		return ""
	}

	function currentBluetoothSubtitle(): string {
		if (!root.enabled) return "bluetooth disabled"
		if (root.connectedDevices.length > 0) return root.btName(root.connectedDevices[0])
		return "none connected"
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

	function connectDevice(device: var): void {
		if (!device || !root.enabled) return
		device.connect()
	}

	function disconnectDevice(device: var): void {
		if (!device) return
		device.disconnect()
	}

	function refreshBluetooth(): void {
		if (!root.btAdapter || !root.btAdapter.enabled || root.btAdapter.discovering) return
		root.btAdapter.discovering = true
	}

	implicitWidth: 280
	implicitHeight: btFrame.implicitHeight + (root.sectionMargin * 2)
	width: implicitWidth
	height: implicitHeight
	Layout.fillWidth: true
	Layout.preferredWidth: implicitWidth
	Layout.preferredHeight: implicitHeight
	radius: Constants.Theme.radius_normal
	color: Constants.Theme.color_surface

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
				Layout.fillWidth: true
				Layout.preferredHeight: Bar.BarTheme.widget_height + 10
				radius: Constants.Theme.radius_normal
				color: Constants.Theme.color_surface_hover

				Column {
					anchors.left: parent.left
					anchors.leftMargin: 8
					anchors.verticalCenter: parent.verticalCenter
					spacing: 0

					Text {
						text: root.enabled ? "Bluetooth" : "Bluetooth Off"
						color: Constants.Theme.color_text
						font.pixelSize: Constants.Theme.font_size
						font.family: Constants.Theme.font_family
					}

					Text {
						text: root.currentBluetoothSubtitle()
						color: Constants.Theme.color_text_subtle
						font.pixelSize: Constants.Theme.font_size - 1
						font.family: Constants.Theme.font_family
						elide: Text.ElideRight
						width: Math.max(0, bluetoothHeader.width - 32)
					}
				}

				Text {
					anchors.right: parent.right
					anchors.rightMargin: 8
					anchors.verticalCenter: parent.verticalCenter
					text: root.expanded ? "" : ""
					color: Constants.Theme.color_text
					font.pixelSize: Constants.Theme.font_size
					font.family: Constants.Theme.font_family_icon
				}

				MouseArea {
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

				Behavior on opacity {
					NumberAnimation {
						duration: Constants.Animations.duration_dropdown_section
						easing.type: Constants.Animations.easing_emphasized
					}
				}

				ColumnLayout {
					id: bluetoothExpandedContent
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: 3

					Text {
						text: "Connected Devices"
						color: Constants.Theme.color_text_subtle
						font.pixelSize: Constants.Theme.font_size - 1
						font.family: Constants.Theme.font_family
						Layout.fillWidth: true
					}

					Repeater {
						model: root.connectedDevices

						Rectangle {
							id: connectedBtDevice
							required property var modelData
							property bool hovered: connectedDeviceMouse.containsMouse
							property bool pressed: connectedDeviceMouse.pressed
							Layout.fillWidth: true
							Layout.preferredHeight: 24
							radius: Constants.Theme.radius_normal
							color: pressed ? Constants.Theme.color_surface_pressed : (hovered ? Constants.Theme.color_surface_hover : "transparent")

							Text {
								anchors.left: parent.left
								anchors.leftMargin: 8
								anchors.verticalCenter: parent.verticalCenter
								text: root.btName(connectedBtDevice.modelData)
								color: Constants.Theme.color_text
								font.pixelSize: Constants.Theme.font_size
								font.family: Constants.Theme.font_family
								elide: Text.ElideRight
								width: parent.width - 16
							}

							MouseArea {
								id: connectedDeviceMouse
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor
								onClicked: root.disconnectDevice(connectedBtDevice.modelData)
							}
						}
					}

					Rectangle {
						Layout.fillWidth: true
						Layout.preferredHeight: 24
						radius: Constants.Theme.radius_normal
						color: "transparent"
						visible: root.connectedDevices.length === 0

						Text {
							anchors.left: parent.left
							anchors.leftMargin: 8
							anchors.verticalCenter: parent.verticalCenter
							text: root.enabled ? "None connected" : "Bluetooth disabled"
							color: Constants.Theme.color_text_subtle
							font.pixelSize: Constants.Theme.font_size - 1
							font.family: Constants.Theme.font_family
						}
					}

					Text {
						text: "Available"
						color: Constants.Theme.color_text_subtle
						font.pixelSize: Constants.Theme.font_size - 1
						font.family: Constants.Theme.font_family
						Layout.fillWidth: true
					}

					Repeater {
						model: root.availableDevices

						Rectangle {
							id: availableBtDevice
							required property var modelData
							property bool hovered: availableDeviceMouse.containsMouse
							property bool pressed: availableDeviceMouse.pressed
							Layout.fillWidth: true
							Layout.preferredHeight: 24
							radius: Constants.Theme.radius_normal
							color: pressed ? Constants.Theme.color_surface_pressed : (hovered ? Constants.Theme.color_surface_hover : "transparent")

							Text {
								anchors.left: parent.left
								anchors.leftMargin: 8
								anchors.verticalCenter: parent.verticalCenter
								text: root.btName(availableBtDevice.modelData)
								color: Constants.Theme.color_text
								font.pixelSize: Constants.Theme.font_size
								font.family: Constants.Theme.font_family
								elide: Text.ElideRight
								width: parent.width - 16
							}

							MouseArea {
								id: availableDeviceMouse
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor
								onClicked: root.connectDevice(availableBtDevice.modelData)
							}
						}
					}

					Rectangle {
						Layout.fillWidth: true
						Layout.preferredHeight: 24
						radius: Constants.Theme.radius_normal
						color: "transparent"
						visible: root.availableDevices.length === 0

						Text {
							anchors.left: parent.left
							anchors.leftMargin: 8
							anchors.verticalCenter: parent.verticalCenter
							text: root.enabled
								? (root.discovering ? "Scanning..." : "None available")
								: "Bluetooth disabled"
							color: Constants.Theme.color_text_subtle
							font.pixelSize: Constants.Theme.font_size - 1
							font.family: Constants.Theme.font_family
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
			if (root.btAdapter && root.btAdapter.discovering) root.btAdapter.discovering = false
		}
	}
}

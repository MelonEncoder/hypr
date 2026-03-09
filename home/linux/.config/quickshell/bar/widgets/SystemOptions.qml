pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Widgets
import Quickshell
import ".."
import "../../constants"

Rectangle {
	id: root
	property bool expanded: false
	property bool hovered: clickArea.containsMouse
	property bool pressed: clickArea.pressed
	property string panelScreenName: ""
	property int brightnessPercent: 50
	property int brightnessMax: 100
	property int ddcDisplay: 1
	property int pendingBrightnessRaw: -1
	property int pendingBrightnessPercent: -1
	property string brightnessBackend: "ddcutil"
	property string brightnessCtlDevice: ""
	property bool wifiExpanded: false
	property bool bluetoothExpanded: false
	property bool wifiLoading: false
	property bool bluetoothLoading: false
	property var wifiNetworks: []
	property var btScannedDevices: []
	readonly property int iconSpacing: 4
	readonly property int slotSize: Math.max(1, BarTheme.widget_height - 8)
	readonly property int popupWidth: 280
	readonly property string wifiScanCommand: "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan no 2>/dev/null | awk -F: '{inuse=$1; signal=$(NF-1); sec=$NF; ssid=$2; for(i=3;i<=NF-2;i++) ssid=ssid \":\" $i; gsub(/^[ \\t]+|[ \\t]+$/, \"\", ssid); if (ssid != \"\") printf \"%s\\t%s\\t%s\\t%s\\n\", inuse, ssid, signal, sec;}'"
	readonly property string bluetoothScanCommand: "bluetoothctl devices 2>/dev/null | sed -n 's/^Device \\([^ ]*\\) \\(.*\\)$/\\1\\t\\2/p'"
	readonly property var btAdapter: Bluetooth.defaultAdapter
	readonly property var btDevices: btAdapter && btAdapter.devices && btAdapter.devices.values ? btAdapter.devices.values : []
	readonly property var connectedWifiNetworks: getConnectedWifiNetworks()
	readonly property var availableWifiNetworks: getAvailableWifiNetworks()
	readonly property var connectedBtDevices: getConnectedBtDevices()
	readonly property var availableBtDevices: getAvailableBtDevices()

	function clampPercent(value: int): int {
		return Math.max(0, Math.min(100, value))
	}

	function setBrightness(percent: int): void {
		var next = clampPercent(percent)
		if (next === root.brightnessPercent) return
		root.brightnessPercent = next
		var max = Math.max(1, root.brightnessMax)
		root.pendingBrightnessRaw = Math.round((next * max) / 100)
		root.pendingBrightnessPercent = next
		brightnessApplyTimer.restart()
	}

	function updateBrightnessFromTrack(mouseX: real): void {
		var width = Math.max(1, brightnessTrack.width)
		var ratio = Math.max(0, Math.min(1, mouseX / width))
		setBrightness(Math.round(ratio * 100))
	}

	function shellQuote(value: string): string {
		if (!value) return "''"
		return "'" + value.replace(/'/g, "'\"'\"'") + "'"
	}

	function detectBrightnessBackend(): void {
		brightnessDetect.exec([
			"sh",
			"-c",
			"name=" + shellQuote(root.panelScreenName) + "; " +
			"if printf '%s' \"$name\" | grep -Eq '^(eDP|LVDS|DSI)' ; then " +
				"for dev in /sys/class/backlight/*; do " +
					"[ -d \"$dev\" ] || continue; " +
					"printf 'brightnessctl\\t%s\\n' \"$(basename \"$dev\")\"; " +
					"exit 0; " +
				"done; " +
			"fi; " +
			"printf 'ddcutil\\t%s\\n' \"$name\""
		])
	}

	function probeBrightness(): void {
		if (root.brightnessBackend === "brightnessctl" && root.brightnessCtlDevice.length > 0) {
			brightnessProbe.exec([
				"sh",
				"-c",
				"current=$(brightnessctl -d " + shellQuote(root.brightnessCtlDevice) + " g 2>/dev/null); " +
				"max=$(brightnessctl -d " + shellQuote(root.brightnessCtlDevice) + " m 2>/dev/null); " +
				"[ -n \"$current\" ] && [ -n \"$max\" ] && printf 'current value = %s\\nmax value = %s\\n' \"$current\" \"$max\" || true"
			])
			return
		}
		brightnessProbe.exec([
			"sh",
			"-c",
			"ddcutil --brief --display " + root.ddcDisplay + " getvcp 10 2>/dev/null || true"
		])
	}

	function btName(device: var): string {
		if (!device) return "Unknown Device"
		if (device.deviceName && device.deviceName.length > 0) return device.deviceName
		if (device.name && device.name.length > 0) return device.name
		if (device.address && device.address.length > 0) return device.address
		return "Unknown Device"
	}

	function wifiName(network: var): string {
		if (!network) return "Unknown Network"
		if (network.ssid && network.ssid.length > 0) return network.ssid
		return "Hidden Network"
	}

	function getConnectedWifiNetworks(): var {
		var connected = []
		for (var i = 0; i < wifiNetworks.length; i++) {
			if (wifiNetworks[i] && wifiNetworks[i].connected) connected.push(wifiNetworks[i])
		}
		return connected
	}

	function getAvailableWifiNetworks(): var {
		var available = []
		for (var i = 0; i < wifiNetworks.length; i++) {
			var net = wifiNetworks[i]
			if (!net || net.connected) continue
			available.push(net)
		}
		return available
	}

	function connectWifi(network: var): void {
		if (!network || !network.ssid) return
		wifiCtl.exec(["sh", "-c", "nmcli dev wifi connect " + shellQuote(network.ssid) + " >/dev/null 2>&1 || true"])
		wifiRefresh.restart()
	}

	function disconnectWifi(): void {
		wifiCtl.exec([
			"sh",
			"-c",
			"conn=\"$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | awk -F: '$2==\"802-11-wireless\"{print $1; exit}')\"; [ -n \"$conn\" ] && nmcli connection down id \"$conn\" >/dev/null 2>&1 || true"
		])
		wifiRefresh.restart()
	}

	function refreshWifi(): void {
		root.wifiLoading = true
		wifiScan.exec(["sh", "-c", root.wifiScanCommand])
	}

	function getConnectedBtDevices(): var {
		var connected = []
		for (var i = 0; i < btDevices.length; i++) {
			if (btDevices[i] && btDevices[i].connected) connected.push(btDevices[i])
		}
		return connected
	}

	function getAvailableBtDevices(): var {
		var seen = {}
		var available = []
		for (var k = 0; k < btDevices.length; k++) {
			var known = btDevices[k]
			if (known && known.connected && known.address) seen[known.address] = true
		}
		for (var i = 0; i < btDevices.length; i++) {
			var dev = btDevices[i]
			if (!dev || dev.connected) continue
			if (dev.paired || dev.trusted || dev.address) {
				available.push(dev)
				if (dev.address) seen[dev.address] = true
			}
		}
		for (var j = 0; j < btScannedDevices.length; j++) {
			var scanned = btScannedDevices[j]
			if (!scanned || !scanned.address) continue
			if (seen[scanned.address]) continue
			available.push(scanned)
			seen[scanned.address] = true
		}
		return available
	}

	function connectDevice(device: var): void {
		if (!device) return
		if (typeof device.connectDevice === "function") {
			device.connectDevice()
			return
		}
		if (typeof device.connect === "function") {
			device.connect()
			return
		}
		if (device.address) {
			bluetoothCtl.exec(["sh", "-c", "bluetoothctl connect " + shellQuote(device.address) + " >/dev/null 2>&1 || true"])
		}
		bluetoothRefresh.restart()
	}

	function disconnectDevice(device: var): void {
		if (!device) return
		if (typeof device.disconnectDevice === "function") {
			device.disconnectDevice()
			return
		}
		if (typeof device.disconnect === "function") {
			device.disconnect()
			return
		}
		if (device.address) {
			bluetoothCtl.exec(["sh", "-c", "bluetoothctl disconnect " + shellQuote(device.address) + " >/dev/null 2>&1 || true"])
		}
		bluetoothRefresh.restart()
	}

	function refreshBluetooth(): void {
		root.bluetoothLoading = true
		bluetoothScan.exec(["sh", "-c", root.bluetoothScanCommand])
	}

	implicitWidth: slotSize + (BarTheme.widget_padding * 2)
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
			if (root.expanded) {
				root.detectBrightnessBackend()
				root.refreshWifi()
				root.refreshBluetooth()
			}
		}
	}

	PopupWindow {
		id: dropdown
		anchor.item: root
		visible: root.expanded || dropdownPanel.opacity > 0.01

		anchor.rect.x: -(root.popupWidth - root.width)
		anchor.rect.y: root.height + BarTheme.popup_offset_y

		implicitWidth: root.popupWidth + (BarTheme.widget_padding * 2)
		implicitHeight: popupContent.implicitHeight + (BarTheme.widget_padding * 2)
		color: "transparent"

		Rectangle {
			id: dropdownPanel
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

			ColumnLayout {
				id: popupContent
				anchors.fill: parent
				anchors.margins: BarTheme.widget_padding
				spacing: BarTheme.inner_spacing
				width: root.popupWidth

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
								id: wifiMainButton
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

								Text {
									anchors.right: parent.right
									anchors.rightMargin: 8
									anchors.verticalCenter: parent.verticalCenter
									text: root.wifiExpanded ? "" : ""
									color: Theme.color_text
									font.pixelSize: Theme.font_size
									font.family: Theme.font_family_icon
								}

								MouseArea {
									anchors.fill: parent
									hoverEnabled: true
									cursorShape: Qt.PointingHandCursor
									onClicked: {
										root.wifiExpanded = !root.wifiExpanded
										if (root.wifiExpanded) root.refreshWifi()
									}
								}
							}

							Item {
								visible: root.wifiExpanded || opacity > 0.01
								Layout.fillWidth: true
								implicitHeight: root.wifiExpanded ? wifiExpandedContent.implicitHeight : 0
								opacity: root.wifiExpanded ? 1 : 0
								clip: true

								Behavior on implicitHeight {
									NumberAnimation {
										duration: Animations.duration_dropdown_section
										easing.type: Animations.easing_standard
									}
								}

								Behavior on opacity {
									NumberAnimation {
										duration: Animations.duration_dropdown_section
										easing.type: Animations.easing_emphasized
									}
								}

								ColumnLayout {
									id: wifiExpandedContent
									anchors.left: parent.left
									anchors.right: parent.right
									spacing: 3

									Text {
										text: "Connected"
										color: Theme.color_text_subtle
										font.pixelSize: Theme.font_size - 1
										font.family: Theme.font_family
										Layout.fillWidth: true
									}

									Repeater {
										model: root.connectedWifiNetworks

										Rectangle {
											id: connectedWifiItem
											required property var modelData
											property bool hovered: connectedWifiMouse.containsMouse
											property bool pressed: connectedWifiMouse.pressed
											Layout.fillWidth: true
											Layout.preferredHeight: 24
											radius: Theme.radius_normal
											color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")

											Text {
												anchors.left: parent.left
												anchors.leftMargin: 8
												anchors.verticalCenter: parent.verticalCenter
												text: root.wifiName(connectedWifiItem.modelData)
												color: Theme.color_text
												font.pixelSize: Theme.font_size
												font.family: Theme.font_family
												elide: Text.ElideRight
												width: parent.width - 16
											}

											MouseArea {
												id: connectedWifiMouse
												anchors.fill: parent
												hoverEnabled: true
												cursorShape: Qt.PointingHandCursor
												onClicked: root.disconnectWifi()
											}
										}
									}

									Rectangle {
										Layout.fillWidth: true
										Layout.preferredHeight: 24
										radius: Theme.radius_normal
										color: "transparent"
										visible: root.wifiLoading || root.connectedWifiNetworks.length === 0

										Text {
											anchors.left: parent.left
											anchors.leftMargin: 8
											anchors.verticalCenter: parent.verticalCenter
											text: root.wifiLoading ? "Loading..." : "None connected"
											color: Theme.color_text_subtle
											font.pixelSize: Theme.font_size - 1
											font.family: Theme.font_family
										}
									}

									Text {
										text: "Available"
										color: Theme.color_text_subtle
										font.pixelSize: Theme.font_size - 1
										font.family: Theme.font_family
										Layout.fillWidth: true
									}

									Repeater {
										model: root.availableWifiNetworks

										Rectangle {
											id: availableWifiItem
											required property var modelData
											property bool hovered: availableWifiMouse.containsMouse
											property bool pressed: availableWifiMouse.pressed
											Layout.fillWidth: true
											Layout.preferredHeight: 24
											radius: Theme.radius_normal
											color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")

											Text {
												anchors.left: parent.left
												anchors.leftMargin: 8
												anchors.verticalCenter: parent.verticalCenter
												text: root.wifiName(availableWifiItem.modelData)
												color: Theme.color_text
												font.pixelSize: Theme.font_size
												font.family: Theme.font_family
												elide: Text.ElideRight
												width: parent.width - 16
											}

											MouseArea {
												id: availableWifiMouse
												anchors.fill: parent
												hoverEnabled: true
												cursorShape: Qt.PointingHandCursor
												onClicked: root.connectWifi(availableWifiItem.modelData)
											}
										}
									}

									Rectangle {
										Layout.fillWidth: true
										Layout.preferredHeight: 24
										radius: Theme.radius_normal
										color: "transparent"
										visible: root.wifiLoading || root.availableWifiNetworks.length === 0

										Text {
											anchors.left: parent.left
											anchors.leftMargin: 8
											anchors.verticalCenter: parent.verticalCenter
											text: root.wifiLoading ? "Loading..." : "None available"
											color: Theme.color_text_subtle
											font.pixelSize: Theme.font_size - 1
											font.family: Theme.font_family
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
								id: bluetoothMainButton
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

								Text {
									anchors.right: parent.right
									anchors.rightMargin: 8
									anchors.verticalCenter: parent.verticalCenter
									text: root.bluetoothExpanded ? "" : ""
									color: Theme.color_text
									font.pixelSize: Theme.font_size
									font.family: Theme.font_family_icon
								}

									MouseArea {
										anchors.fill: parent
										hoverEnabled: true
										cursorShape: Qt.PointingHandCursor
										onClicked: {
											root.bluetoothExpanded = !root.bluetoothExpanded
											if (root.bluetoothExpanded) root.refreshBluetooth()
										}
									}
								}

							Item {
								visible: root.bluetoothExpanded || opacity > 0.01
								Layout.fillWidth: true
								implicitHeight: root.bluetoothExpanded ? bluetoothExpandedContent.implicitHeight : 0
								opacity: root.bluetoothExpanded ? 1 : 0
								clip: true

								Behavior on implicitHeight {
									NumberAnimation {
										duration: Animations.duration_dropdown_section
										easing.type: Animations.easing_standard
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
										font.pixelSize: Theme.font_size - 1
										font.family: Theme.font_family
										Layout.fillWidth: true
									}

									Repeater {
										model: root.connectedBtDevices

										Rectangle {
											id: connectedBtDevice
											required property var modelData
											property bool hovered: connectedDeviceMouse.containsMouse
											property bool pressed: connectedDeviceMouse.pressed
											Layout.fillWidth: true
											Layout.preferredHeight: 24
											radius: Theme.radius_normal
											color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")

											Text {
												anchors.left: parent.left
												anchors.leftMargin: 8
												anchors.verticalCenter: parent.verticalCenter
												text: root.btName(connectedBtDevice.modelData)
												color: Theme.color_text
												font.pixelSize: Theme.font_size
												font.family: Theme.font_family
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
										radius: Theme.radius_normal
										color: "transparent"
										visible: root.bluetoothLoading || root.connectedBtDevices.length === 0

										Text {
											anchors.left: parent.left
											anchors.leftMargin: 8
											anchors.verticalCenter: parent.verticalCenter
											text: root.bluetoothLoading ? "Loading..." : "None connected"
											color: Theme.color_text_subtle
											font.pixelSize: Theme.font_size - 1
											font.family: Theme.font_family
										}
									}

									Text {
										text: "Available"
										color: Theme.color_text_subtle
										font.pixelSize: Theme.font_size - 1
										font.family: Theme.font_family
										Layout.fillWidth: true
									}

									Repeater {
										model: root.availableBtDevices

										Rectangle {
											id: availableBtDevice
											required property var modelData
											property bool hovered: availableDeviceMouse.containsMouse
											property bool pressed: availableDeviceMouse.pressed
											Layout.fillWidth: true
											Layout.preferredHeight: 24
											radius: Theme.radius_normal
											color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")

											Text {
												anchors.left: parent.left
												anchors.leftMargin: 8
												anchors.verticalCenter: parent.verticalCenter
												text: root.btName(availableBtDevice.modelData)
												color: Theme.color_text
												font.pixelSize: Theme.font_size
												font.family: Theme.font_family
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
										radius: Theme.radius_normal
										color: "transparent"
										visible: root.bluetoothLoading || root.availableBtDevices.length === 0

										Text {
											anchors.left: parent.left
											anchors.leftMargin: 8
											anchors.verticalCenter: parent.verticalCenter
											text: root.bluetoothLoading ? "Loading..." : "None available"
											color: Theme.color_text_subtle
											font.pixelSize: Theme.font_size - 1
											font.family: Theme.font_family
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
		id: bluetoothCtl
	}

	Process {
		id: wifiCtl
	}

	StdioCollector {
		id: wifiScanOut
		waitForEnd: true
		onStreamFinished: {
			var raw = text.trim()
			if (raw.length === 0) {
				root.wifiNetworks = []
				root.wifiLoading = false
				return
			}

			var lines = raw.split("\n")
			var parsed = []
			for (var i = 0; i < lines.length; i++) {
				var line = lines[i]
				if (!line || line.length === 0) continue
				var parts = line.split("\t")
				if (parts.length < 4) continue
				var inUse = parts[0]
				var ssid = parts[1]
				var signal = parseInt(parts[2])
				var security = parts[3]
				parsed.push({
					ssid: ssid,
					signal: isNaN(signal) ? 0 : signal,
					security: security,
					connected: inUse === "*"
				})
			}
			root.wifiNetworks = parsed
			root.wifiLoading = false
		}
	}

	Process {
		id: wifiScan
		stdout: wifiScanOut
	}

	StdioCollector {
		id: bluetoothScanOut
		waitForEnd: true
		onStreamFinished: {
			var raw = text.trim()
			if (raw.length === 0) {
				root.btScannedDevices = []
				root.bluetoothLoading = false
				return
			}

			var lines = raw.split("\n")
			var parsed = []
			for (var i = 0; i < lines.length; i++) {
				var line = lines[i]
				if (!line || line.length === 0) continue
				var parts = line.split("\t")
				if (parts.length < 2) continue
				parsed.push({
					address: parts[0],
					deviceName: parts.slice(1).join("\t"),
					name: parts.slice(1).join("\t"),
					connected: false
				})
			}
			root.btScannedDevices = parsed
			root.bluetoothLoading = false
		}
	}

	Process {
		id: bluetoothScan
		stdout: bluetoothScanOut
	}

	Timer {
		id: wifiRefresh
		interval: 1200
		running: false
		repeat: false
		onTriggered: root.refreshWifi()
	}

	Timer {
		id: bluetoothRefresh
		interval: 1200
		running: false
		repeat: false
		onTriggered: root.refreshBluetooth()
	}

	Process {
		id: brightnessSet
	}

	Process {
		id: brightnessDetect
		stdout: StdioCollector {
			waitForEnd: true
			onStreamFinished: {
				var raw = text.trim()
				if (raw.length === 0) return
				var parts = raw.split(/\t+/)
				var backend = parts.length > 0 ? parts[0].trim() : ""
				if (backend !== "brightnessctl" && backend !== "ddcutil") backend = "ddcutil"
				root.brightnessBackend = backend
				root.brightnessCtlDevice = backend === "brightnessctl" && parts.length > 1 ? parts[1].trim() : ""
				root.probeBrightness()
			}
		}
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
			if (root.brightnessBackend === "brightnessctl") {
				if (root.pendingBrightnessPercent < 0 || root.brightnessCtlDevice.length === 0) return
				brightnessSet.exec([
					"sh",
					"-c",
					"brightnessctl -d " + shellQuote(root.brightnessCtlDevice) + " set " + root.pendingBrightnessPercent + "% >/dev/null 2>&1 || true"
				])
				return
			}
			if (root.pendingBrightnessRaw < 0) return
			brightnessSet.exec([
				"sh",
				"-c",
				"ddcutil --display " + root.ddcDisplay + " setvcp 10 " + root.pendingBrightnessRaw + " >/dev/null 2>&1 || true"
			])
		}
	}

	Component.onCompleted: {
		root.detectBrightnessBackend()
		root.refreshWifi()
		root.refreshBluetooth()
	}
}

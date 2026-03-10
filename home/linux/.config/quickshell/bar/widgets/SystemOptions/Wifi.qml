import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../../constants" as Constants
import "../../" as Bar

Rectangle {
	id: root
	property bool expanded: false
	property bool loading: false
	property var wifiNetworks: []
	readonly property int sectionMargin: Math.round(Bar.BarTheme.widget_padding / 2)
	readonly property string wifiScanCommand: "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan no 2>/dev/null | awk -F: '{inuse=$1; signal=$(NF-1); sec=$NF; ssid=$2; for(i=3;i<=NF-2;i++) ssid=ssid \":\" $i; gsub(/^[ \\t]+|[ \\t]+$/, \"\", ssid); if (ssid != \"\") printf \"%s\\t%s\\t%s\\t%s\\n\", inuse, ssid, signal, sec;}'"
	readonly property var connectedNetworks: getConnectedWifiNetworks()
	readonly property var availableNetworks: getAvailableWifiNetworks()
	readonly property int expandedContentHeight: wifiExpandedContent.implicitHeight

	function wifiName(network: var): string {
		if (!network) return "Unknown Network"
		if (network.ssid && network.ssid.length > 0) return network.ssid
		return "Hidden Network"
	}

	function currentWifiSubtitle(): string {
		if (root.loading) return "loading..."
		if (root.connectedNetworks.length > 0) return root.wifiName(root.connectedNetworks[0])
		return "none connected"
	}

	function shellQuote(value: string): string {
		if (!value) return "''"
		return "'" + value.replace(/'/g, "'\"'\"'") + "'"
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
		root.loading = true
		wifiScan.exec(["sh", "-c", root.wifiScanCommand])
	}

	implicitWidth: 280
	implicitHeight: wifiFrame.implicitHeight + (root.sectionMargin * 2)
	width: implicitWidth
	height: implicitHeight
	Layout.fillWidth: true
	Layout.preferredWidth: implicitWidth
	Layout.preferredHeight: implicitHeight
	radius: Constants.Theme.radius_normal
	color: Constants.Theme.color_surface

	Item {
		id: wifiFrame
		x: root.sectionMargin
		y: root.sectionMargin
		width: parent.width - (root.sectionMargin * 2)
		implicitHeight: wifiMenu.implicitHeight

		ColumnLayout {
			id: wifiMenu
			width: parent.width
			spacing: 4

			Rectangle {
				id: wifiHeader
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
						text: "Wi-Fi"
						color: Constants.Theme.color_text
						font.pixelSize: Constants.Theme.font_size
						font.family: Constants.Theme.font_family
					}

					Text {
						text: root.currentWifiSubtitle()
						color: Constants.Theme.color_text_subtle
						font.pixelSize: Constants.Theme.font_size - 1
						font.family: Constants.Theme.font_family
						elide: Text.ElideRight
						width: Math.max(0, wifiHeader.width - 32)
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
						if (root.expanded) root.refreshWifi()
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
					id: wifiExpandedContent
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: 3

					Text {
						text: "Available"
						color: Constants.Theme.color_text_subtle
						font.pixelSize: Constants.Theme.font_size - 1
						font.family: Constants.Theme.font_family
						Layout.fillWidth: true
					}

					Repeater {
						model: root.availableNetworks

						Rectangle {
							id: availableWifiItem
							required property var modelData
							property bool hovered: availableWifiMouse.containsMouse
							property bool pressed: availableWifiMouse.pressed
							Layout.fillWidth: true
							Layout.preferredHeight: 24
							radius: Constants.Theme.radius_normal
							color: pressed ? Constants.Theme.color_surface_pressed : (hovered ? Constants.Theme.color_surface_hover : "transparent")

							Text {
								anchors.left: parent.left
								anchors.leftMargin: 8
								anchors.verticalCenter: parent.verticalCenter
								text: root.wifiName(availableWifiItem.modelData)
								color: Constants.Theme.color_text
								font.pixelSize: Constants.Theme.font_size
								font.family: Constants.Theme.font_family
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
						radius: Constants.Theme.radius_normal
						color: "transparent"
						visible: root.loading || root.availableNetworks.length === 0

						Text {
							anchors.left: parent.left
							anchors.leftMargin: 8
							anchors.verticalCenter: parent.verticalCenter
							text: root.loading ? "Loading..." : "None available"
							color: Constants.Theme.color_text_subtle
							font.pixelSize: Constants.Theme.font_size - 1
							font.family: Constants.Theme.font_family
						}
					}
				}
			}
		}
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
				root.loading = false
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
			root.loading = false
		}
	}

	Process {
		id: wifiScan
		stdout: wifiScanOut
	}

	Timer {
		id: wifiRefresh
		interval: 1200
		running: false
		repeat: false
		onTriggered: root.refreshWifi()
	}

	Component.onCompleted: root.refreshWifi()
}

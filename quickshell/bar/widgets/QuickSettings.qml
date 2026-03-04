import QtQuick
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import ".."
import "../../constants"

Rectangle {
	id: root
	property bool active: false
	property bool hovered: clickArea.containsMouse
	property string networkKind: "offline"
	property string networkName: ""
	property int networkSignal: 0

	function toPercent(node: var): int {
		if (!node || !node.audio) return 0
		var v = node.audio.volume
		if (isNaN(v)) return 0
		return Math.max(0, Math.min(150, Math.round(v * 100)))
	}

	function netIcon(): string {
		if (networkKind === "wifi") {
			if (networkSignal <= 0) return "󰤮"
			if (networkSignal < 25) return "󰤯"
			if (networkSignal < 50) return "󰤟"
			if (networkSignal < 75) return "󰤢"
			return "󰤥"
		}
		if (networkKind === "ethernet") return "󰈀"
		return "󰖪"
	}

	function netText(): string {
		if (networkKind === "offline") return "Offline"
		if (networkName.length > 0) return networkName
		return networkKind === "wifi" ? "Wi-Fi" : "Ethernet"
	}

	function volumeIcon(): string {
		if (speakerMuted || speakerVolume <= 0) return "󰖁"
		if (speakerVolume < 35) return "󰕿"
		if (speakerVolume < 70) return "󰖀"
		return "󰕾"
	}

	function bluetoothIcon(): string {
		if (!btAdapter || !btAdapter.enabled) return "󰂲"

		var devices = btAdapter.devices && btAdapter.devices.values ? btAdapter.devices.values : []
		var connected = null
		for (var i = 0; i < devices.length; i++) {
			if (devices[i].connected) {
				connected = devices[i]
				break
			}
		}

		if (!connected) return "󰂯"

		var key = ((connected.icon || "") + " " + (connected.deviceName || "") + " " + (connected.name || "")).toLowerCase()
		if (key.indexOf("headset") >= 0) return "󰋋"
		if (key.indexOf("headphone") >= 0) return "󰋎"
		if (key.indexOf("earbud") >= 0) return "󰥰"
		if (key.indexOf("speaker") >= 0) return "󰓃"
		return "󰂯"
	}

	readonly property var sink: Pipewire.defaultAudioSink
	readonly property var source: Pipewire.defaultAudioSource
	readonly property var btAdapter: Bluetooth.defaultAdapter
	readonly property int speakerVolume: toPercent(sink)
	readonly property bool speakerMuted: !!sink && !!sink.audio && sink.audio.muted

	implicitWidth: label.implicitWidth + (BarTheme.widgetPadding * 2)
	implicitHeight: BarTheme.widgetHeight
	radius: Theme.radius
	color: root.active
		? Theme.colors.surfaceActive
		: (root.hovered ? Theme.colors.surfaceHover : Theme.colors.surface)
	border.width: Theme.borderSize
	border.color: Theme.colors.border

	Text {
		id: label
		anchors.centerIn: parent
		text: root.netIcon() + "  " + root.volumeIcon() + "  " + root.bluetoothIcon()
		color: root.active ? Theme.colors.textOnActive : Theme.colors.text
		font.pixelSize: Theme.font.size
		font.family: Theme.font.family
		elide: Text.ElideRight
	}
	MouseArea {
		id: clickArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: root.active = !root.active
	}

	StdioCollector {
		id: networkOut
		waitForEnd: true
		onStreamFinished: {
			var lines = text.trim().split("\n")
			var connected = ""
			for (var i = 0; i < lines.length; i++) {
				if (lines[i].indexOf(":connected:") >= 0) {
					connected = lines[i]
					break
				}
			}

			if (connected.length === 0) {
				root.networkKind = "offline"
				root.networkName = ""
				root.networkSignal = 0
				return
			}

			var parts = connected.split(":")
			var type = parts.length > 0 ? parts[0] : ""
			var name = parts.length > 2 ? parts[2] : ""
			var signal = parts.length > 3 ? parseInt(parts[3]) : 0
			root.networkKind = (type === "wifi" || type === "ethernet") ? type : "offline"
			root.networkName = name
			root.networkSignal = isNaN(signal) ? 0 : signal
		}
	}

	Process {
		id: networkProbe
		stdout: networkOut
	}

	Timer {
		interval: 5000
		running: true
		repeat: true
		onTriggered: {
			networkProbe.exec(["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION,SIGNAL device status 2>/dev/null || true"])
		}
	}

	Component.onCompleted: networkProbe.exec(["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION,SIGNAL device status 2>/dev/null || true"])
}

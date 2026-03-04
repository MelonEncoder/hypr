import QtQuick
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import ".."
import "../../constants"

Rectangle {
	id: root
	property bool hovered: clickArea.containsMouse
	property bool pressed: clickArea.pressed
	property var iconKeys: ["wifi", "bluetooth", "volume"]
	property string networkKind: "offline"
	property int networkSignal: 0
	readonly property int iconCount: iconKeys ? iconKeys.length : 0
	readonly property int iconSpacing: 4
	readonly property int slotSize: Math.max(1, BarTheme.widget_height - 8)
	readonly property var sink: Pipewire.defaultAudioSink
	readonly property var btAdapter: Bluetooth.defaultAdapter
	readonly property int speakerVolume: toPercent(sink)
	readonly property bool speakerMuted: !!sink && !!sink.audio && sink.audio.muted

	signal clicked()

	function toPercent(node: var): int {
		if (!node || !node.audio) return 0
		var v = node.audio.volume
		if (isNaN(v)) return 0
		return Math.max(0, Math.min(150, Math.round(v * 100)))
	}

	function wifiIcon(): string {
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

	function bluetoothIcon(): string {
		if (!btAdapter || !btAdapter.enabled) return "󰂲"
		var devices = btAdapter.devices && btAdapter.devices.values ? btAdapter.devices.values : []
		for (var i = 0; i < devices.length; i++) {
			if (devices[i].connected) return "󰂯"
		}
		return "󰂯"
	}

	function volumeIcon(): string {
		if (speakerMuted || speakerVolume <= 0) return "󰖁"
		if (speakerVolume < 35) return "󰕿"
		if (speakerVolume < 70) return "󰖀"
		return "󰕾"
	}

	function iconForKey(key: string): string {
		if (key === "wifi") return wifiIcon()
		if (key === "bluetooth") return bluetoothIcon()
		if (key === "volume") return volumeIcon()
		return "?"
	}

	implicitWidth: (iconCount * slotSize) + (Math.max(0, iconCount - 1) * iconSpacing) + (BarTheme.widget_padding * 2)
	implicitHeight: BarTheme.widget_height
	radius: Theme.radius_normal
	color: root.pressed ? Theme.color_surface_pressed : (root.hovered ? Theme.color_surface_hover : Theme.color_surface)
	border.width: Theme.border_width
	border.color: Theme.color_border

	Row {
		id: iconRow
		anchors.centerIn: parent
		spacing: root.iconSpacing

		Repeater {
			model: root.iconKeys

			Item {
				required property var modelData
				width: root.slotSize
				height: root.slotSize

				Text {
					anchors.centerIn: parent
					text: root.iconForKey(modelData)
					color: Theme.color_text
					font.pixelSize: Theme.font_size + 2
					font.family: Theme.font_family
				}
			}
		}
	}

	MouseArea {
		id: clickArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: root.clicked()
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
				root.networkSignal = 0
				return
			}

			var parts = connected.split(":")
			var type = parts.length > 0 ? parts[0] : ""
			var signal = parts.length > 3 ? parseInt(parts[3]) : 0
			root.networkKind = (type === "wifi" || type === "ethernet") ? type : "offline"
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
		onTriggered: networkProbe.exec(["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION,SIGNAL device status 2>/dev/null || true"])
	}

	Component.onCompleted: networkProbe.exec(["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION,SIGNAL device status 2>/dev/null || true"])
}

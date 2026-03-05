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
	property int currentVolume: 0
	property bool currentMuted: false

	signal clicked()

	function openMixer(): void {
		launchCtl.exec([
			"sh",
			"-c",
			"pavucontrol >/dev/null 2>&1 &"
		])
	}

	function adjustVolume(step: int): void {
		var dir = step >= 0 ? "+" : "-"
		var next = root.currentVolume + (step * 2)
		if (next < 0) next = 0
		if (next > 150) next = 150
		root.currentVolume = next
		if (step > 0 && root.currentMuted) root.currentMuted = false

		volumeCtl.exec([
			"sh",
			"-c",
			"if command -v wpctl >/dev/null 2>&1; then " +
			"wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%" + dir + "; " +
			"elif command -v pactl >/dev/null 2>&1; then " +
			"pactl set-sink-volume @DEFAULT_SINK@ 2%" + dir + "; " +
			"fi"
		])
		syncTimer.restart()
	}

	function toPercent(node: var): int {
		if (!node || !node.audio) return 0
		var v = node.audio.volume
		if (isNaN(v)) return 0
		return Math.max(0, Math.min(150, Math.round(v * 100)))
	}

	function connectedBtDevice(): var {
		if (!btAdapter || !btAdapter.enabled) return null
		var devices = btAdapter.devices && btAdapter.devices.values ? btAdapter.devices.values : []
		for (var i = 0; i < devices.length; i++) {
			if (devices[i].connected) return devices[i]
		}
		return null
	}

	function bluetoothIconFor(device: var): string {
		var key = ((device.icon || "") + " " + (device.deviceName || "") + " " + (device.name || "")).toLowerCase()
		if (key.indexOf("headset") >= 0 || key.indexOf("headphone") >= 0 || key.indexOf("earbud") >= 0) return "󰥰"
		return "󰂯"
	}

	function outputDeviceIcon(): string {
		var bt = connectedBtDevice()
		if (bt) return bluetoothIconFor(bt)

		var key = (sinkName + " " + sinkNick + " " + sinkDescription).toLowerCase()
		if (key.indexOf("headset") >= 0 || key.indexOf("headphone") >= 0 || key.indexOf("earbud") >= 0) return "󰋎"
		return "󰂯"
	}

	function refreshVolume(): void {
		volumeProbe.exec([
			"sh",
			"-c",
			"if command -v wpctl >/dev/null 2>&1; then " +
			"line=\"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)\"; " +
			"vol=\"$(printf '%s\\n' \"$line\" | sed -n 's/.*Volume:[[:space:]]*\\([0-9.]*\\).*/\\1/p' | head -n 1)\"; " +
			"muted=0; printf '%s' \"$line\" | grep -qi 'MUTED' && muted=1; " +
			"if [ -n \"$vol\" ]; then " +
			"pct=\"$(awk -v v=\"$vol\" 'BEGIN { p=int((v*100)+0.5); if (p < 0) p=0; if (p > 150) p=150; print p }')\"; " +
			"printf '%s:%s\\n' \"$pct\" \"$muted\"; " +
			"exit 0; " +
			"fi; " +
			"fi; " +
			"printf 'x:x\\n'"
		])
	}

	readonly property var sink: Pipewire.defaultAudioSink
	readonly property var btAdapter: Bluetooth.defaultAdapter
	readonly property int speakerVolume: toPercent(sink)
	readonly property bool speakerMuted: !!sink && !!sink.audio && sink.audio.muted
	readonly property string sinkName: !!sink && !!sink.name ? sink.name : ""
	readonly property string sinkNick: !!sink && !!sink.nick ? sink.nick : ""
	readonly property string sinkDescription: !!sink && !!sink.description ? sink.description : ""

	Process {
		id: volumeCtl
	}

	Process {
		id: launchCtl
	}

	StdioCollector {
		id: volumeProbeOut
		waitForEnd: true
		onStreamFinished: {
			var parts = text.trim().split(":")
			if (parts.length === 2 && parts[0] !== "x" && parts[1] !== "x") {
				var vol = parseInt(parts[0])
				var muted = parseInt(parts[1])
				if (!isNaN(vol)) root.currentVolume = vol
				if (!isNaN(muted)) root.currentMuted = (muted === 1)
				return
			}

			root.currentVolume = root.speakerVolume
			root.currentMuted = root.speakerMuted
		}
	}

	Process {
		id: volumeProbe
		stdout: volumeProbeOut
	}

	Timer {
		id: volumeProbeTimer
		interval: 1200
		running: true
		repeat: true
		onTriggered: root.refreshVolume()
	}

	Timer {
		id: syncTimer
		interval: 120
		running: false
		repeat: false
		onTriggered: root.refreshVolume()
	}

	implicitWidth: content.implicitWidth + (BarTheme.widget_padding * 2)
	implicitHeight: BarTheme.widget_height
	radius: Theme.radius_normal
	color: root.pressed ? Theme.color_surface_pressed : (root.hovered ? Theme.color_surface_hover : Theme.color_surface)
	border.width: Theme.border_width
	border.color: Theme.color_border

	Item {
		id: content
		anchors.centerIn: parent
		implicitWidth: iconText.implicitWidth + 6 + valueText.implicitWidth
		implicitHeight: Math.max(iconText.implicitHeight, valueText.implicitHeight)

		Text {
			id: iconText
			anchors.left: parent.left
			anchors.verticalCenter: parent.verticalCenter
			text: root.outputDeviceIcon()
			color: Theme.color_text
			font.pixelSize: Theme.font_size + 4
			font.family: Theme.font_family_icon
			verticalAlignment: Text.AlignVCenter
		}

		Text {
			id: valueText
			anchors.left: iconText.right
			anchors.leftMargin: 6
			anchors.verticalCenter: parent.verticalCenter
			text: root.currentMuted ? "Muted" : (root.currentVolume + "%")
			color: Theme.color_text
			font.pixelSize: Theme.font_size
			font.family: Theme.font_family
			verticalAlignment: Text.AlignVCenter
		}
	}

	MouseArea {
		id: clickArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: {
			root.clicked()
			root.openMixer()
		}
		onWheel: function(wheel) {
			if (wheel.angleDelta.y > 0) root.adjustVolume(1)
			else if (wheel.angleDelta.y < 0) root.adjustVolume(-1)
			wheel.accepted = true
		}
	}

	Component.onCompleted: {
		root.currentVolume = root.speakerVolume
		root.currentMuted = root.speakerMuted
		root.refreshVolume()
	}
}

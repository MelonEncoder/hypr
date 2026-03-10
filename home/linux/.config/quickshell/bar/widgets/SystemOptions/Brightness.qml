import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../../constants" as Constants
import "../../" as Bar

Rectangle {
	id: root
	property string panelScreenName: ""
	property int ddcDisplay: 1
	property int brightnessPercent: 50
	property int brightnessMax: 100
	property int pendingBrightnessRaw: -1
	property int pendingBrightnessPercent: -1
	property string brightnessBackend: "ddcutil"
	property string brightnessCtlDevice: ""

	function clampPercent(value: int): int {
		return Math.max(0, Math.min(100, value))
	}

	function shellQuote(value: string): string {
		if (!value) return "''"
		return "'" + value.replace(/'/g, "'\"'\"'") + "'"
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

	function updateBrightnessFromTrack(mouseX: real, trackWidth: real): void {
		var width = Math.max(1, trackWidth)
		var ratio = Math.max(0, Math.min(1, mouseX / width))
		setBrightness(Math.round(ratio * 100))
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

	implicitWidth: 280
	implicitHeight: brightnessFrame.implicitHeight + (Bar.BarTheme.widget_padding * 2)
	width: implicitWidth
	height: implicitHeight
	Layout.fillWidth: true
	Layout.preferredWidth: implicitWidth
	Layout.preferredHeight: implicitHeight
	radius: Constants.Theme.radius_normal
	color: Constants.Theme.color_surface

	Item {
		id: brightnessFrame
		x: Bar.BarTheme.widget_padding
		y: Bar.BarTheme.widget_padding
		width: parent.width - (Bar.BarTheme.widget_padding * 2)
		implicitHeight: brightnessContent.implicitHeight

		ColumnLayout {
			id: brightnessContent
			width: parent.width
			spacing: Bar.BarTheme.inner_spacing

			Text {
				text: "Brightness " + root.brightnessPercent + "%"
				color: Constants.Theme.color_text
				font.pixelSize: Constants.Theme.font_size
				font.family: Constants.Theme.font_family
				Layout.fillWidth: true
			}

			Rectangle {
				id: brightnessTrack
				Layout.fillWidth: true
				Layout.preferredHeight: 8
				radius: 4
				color: Constants.Theme.color_surface_hover

				Rectangle {
					width: Math.round((brightnessTrack.width * root.brightnessPercent) / 100)
					height: parent.height
					radius: parent.radius
					color: Constants.Theme.color_text
				}

				MouseArea {
					anchors.fill: parent
					hoverEnabled: true
					onPressed: function(mouse) {
						root.updateBrightnessFromTrack(mouse.x, brightnessTrack.width)
					}
					onPositionChanged: function(mouse) {
						if (!pressed) return
						root.updateBrightnessFromTrack(mouse.x, brightnessTrack.width)
					}
				}
			}
		}
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

	onPanelScreenNameChanged: detectBrightnessBackend()
	Component.onCompleted: detectBrightnessBackend()
}

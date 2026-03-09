import QtQuick
import Quickshell.Io
import ".."
import "../../constants"

Rectangle {
	id: root
	property bool hasBattery: false
	property int batteryPercent: 0
	property bool charging: false

	visible: root.hasBattery
	implicitWidth: content.implicitWidth + (BarTheme.widget_padding * 2)
	implicitHeight: BarTheme.widget_height
	radius: Theme.radius_normal
	color: Theme.color_surface
	border.width: Theme.border_width
	border.color: Theme.color_border

	function clampPercent(value: int): int {
		return Math.max(0, Math.min(100, value))
	}

	function levelIcon(percent: int): string {
		var p = clampPercent(percent)
		if (p <= 20) return ""
		if (p <= 40) return ""
		if (p <= 60) return ""
		if (p <= 80) return ""
		return ""
	}

	function batteryIcon(percent: int, isCharging: bool): string {
		if (isCharging) return ""
		return levelIcon(percent)
	}

	function refresh(): void {
		probe.exec([
			"sh",
			"-c",
			"if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then " +
			"bat=\"$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)\"; " +
			"cap=\"$(cat \"$bat/capacity\" 2>/dev/null)\"; " +
			"stat=\"$(cat \"$bat/status\" 2>/dev/null)\"; " +
			"[ -n \"$cap\" ] || cap=0; " +
			"case \"$stat\" in Charging|Full) ch=1 ;; *) ch=0 ;; esac; " +
			"printf '%s:%s:1\\n' \"$cap\" \"$ch\"; " +
			"else printf '0:0:0\\n'; fi"
		])
	}

	Item {
		id: content
		anchors.centerIn: parent
		implicitWidth: iconLabel.implicitWidth + 6 + valueLabel.implicitWidth
		implicitHeight: Math.max(iconLabel.implicitHeight, valueLabel.implicitHeight)

		Text {
			id: iconLabel
			anchors.left: parent.left
			anchors.verticalCenter: parent.verticalCenter
			text: root.batteryIcon(root.batteryPercent, root.charging)
			color: root.batteryPercent <= 15 ? Theme.color_privacy : Theme.color_text
			font.pixelSize: Theme.font_size
			font.family: Theme.font_family_icon
		}

		Text {
			id: valueLabel
			anchors.left: iconLabel.right
			anchors.leftMargin: 6
			anchors.verticalCenter: parent.verticalCenter
			text: root.batteryPercent + "%"
			color: root.batteryPercent <= 15 ? Theme.color_privacy : Theme.color_text
			font.pixelSize: Theme.font_size
			font.family: Theme.font_family
		}
	}

	StdioCollector {
		id: probeOut
		waitForEnd: true
		onStreamFinished: {
			var raw = text.trim()
			if (raw.length === 0) {
				root.hasBattery = false
				return
			}

			var parts = raw.split(":")
			if (parts.length !== 3) return
			var cap = parseInt(parts[0])
			var ch = parseInt(parts[1])
			var exists = parseInt(parts[2])
			root.hasBattery = exists === 1
			if (!isNaN(cap)) root.batteryPercent = root.clampPercent(cap)
			root.charging = ch === 1
		}
	}

	Process {
		id: probe
		stdout: probeOut
	}

	Timer {
		interval: 5000
		running: true
		repeat: true
		onTriggered: root.refresh()
	}

	Component.onCompleted: root.refresh()
}

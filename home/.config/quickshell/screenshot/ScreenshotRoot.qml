pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Hyprland._GlobalShortcuts
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
	id: root

	readonly property string screenshotDir: Quickshell.env("HOME") + "/Pictures/Screenshots"
	property string pendingMode: ""
	property string lastSavedPath: ""
	property var pendingScreen: null

	GlobalShortcut {
		appid: "quickshell"
		name: "screenshot-fullscreen"
		description: "Take a fullscreen screenshot"
		triggerDescription: "SUPER+PRINT"
		onPressed: root.takeFullscreen()
	}

	GlobalShortcut {
		appid: "quickshell"
		name: "screenshot-selection"
		description: "Take a selected-area screenshot"
		triggerDescription: "SUPER+SHIFT+S"
		onPressed: root.takeSelection()
	}

	function takeFullscreen(): void {
		if (captureProc.running) return
		pendingMode = "fullscreen"
		pendingScreen = Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
		if (!pendingScreen) {
			root.notifyFailure("No screen available for capture")
			return
		}
		fullscreenCapture.captureFrame()
		captureProc.exec(buildCaptureCommand("fullscreen"))
	}

	function takeSelection(): void {
		if (captureProc.running) return
		pendingMode = "selection"
		captureProc.exec(buildCaptureCommand("selection"))
	}

	function buildCaptureCommand(mode: string): list<string> {
		var filePrefix = mode === "selection" ? "Selection" : "Fullscreen"
		return [
			"bash",
			"-lc",
			"set -euo pipefail\n"
			+ "dir=\"$HOME/Pictures/Screenshots\"\n"
			+ "mkdir -p \"$dir\"\n"
			+ "timestamp=\"$(date +%Y-%m-%d_%H-%M-%S)\"\n"
			+ "file=\"$dir/Screenshot_" + filePrefix + "_$timestamp.png\"\n"
			+ (mode === "selection"
				? "region=\"$(slurp)\"\n[ -n \"$region\" ] || exit 130\ngrim -g \"$region\" \"$file\"\n"
				: "grim \"$file\"\n")
			+ "if command -v wl-copy >/dev/null 2>&1; then wl-copy < \"$file\"; fi\n"
			+ "printf '%s\\n' \"$file\"\n"
		]
	}

	function notifySuccess(path: string): void {
		notifyProc.exec([
			"bash",
			"-lc",
			"notify-send -i \"" + path + "\" 'Screenshot captured' '" + (pendingMode === "selection" ? "Selected area" : "Fullscreen") + " saved to " + path.replace(/'/g, "'\\''") + "'"
		])
	}

	function notifyFailure(message: string): void {
		notifyProc.exec([
			"bash",
			"-lc",
			"notify-send -u critical 'Screenshot failed' '" + message.replace(/'/g, "'\\''") + "'"
		])
	}

	Process {
		id: captureProc
		stdout: captureOut
		onExited: function(exitCode, exitStatus) {
			if (exitCode === 0) return
			if (exitCode === 130) {
				root.notifyFailure("Selection cancelled")
				return
			}
			root.notifyFailure("Capture command exited with code " + exitCode)
		}
	}

	StdioCollector {
		id: captureOut
		waitForEnd: true
		onStreamFinished: {
			var path = text.trim()
			if (!path.length) return
			root.lastSavedPath = path
			root.notifySuccess(path)
		}
	}

	Process {
		id: notifyProc
	}

	ScreencopyView {
		id: fullscreenCapture
		captureSource: root.pendingScreen
		visible: false
	}

	IpcHandler {
		target: "screenshot"

		function fullscreen(): void {
			root.takeFullscreen()
		}

		function selection(): void {
			root.takeSelection()
		}
	}
}

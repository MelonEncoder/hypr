import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import Quickshell.Widgets
import ".."
import "../../constants"

Rectangle {
	id: root
	property bool expanded: false
	property bool hovered: clickArea.containsMouse
	property bool pressed: clickArea.pressed
	property string osInfo: "Arch Linux"
	property string osId: "arch"
	property string osLike: ""
	property string kernelInfo: ""
	property string osVersionRaw: ""
	property var distroMeta: resolveDistro(root.osId, root.osLike, root.osInfo)
	property string distroDisplay: root.distroMeta.name
	property string distroIcon: root.distroMeta.icon
	property string kernelDisplay: formatKernel(root.kernelInfo)
	property string versionDisplay: formatVersion(root.osVersionRaw)
	readonly property int popupWidth: 240
	readonly property var powerActions: [
		{ action: "lock", icon: "", label: "Lock Screen" },
		{ action: "logout", icon: "󰍃", label: "Log Out" },
		{ action: "suspend", icon: "", label: "Sleep" },
		{ action: "reboot", icon: "", label: "Restart" },
		{ action: "poweroff", icon: "", label: "Shut Down" }
	]

	function formatDistro(value: string): string {
		var text = value.trim()
		if (text.length === 0) return "Linux"
		return text.replace(/\s+/g, " ")
	}

	function formatKernel(value: string): string {
		var text = value.trim()
		if (text.length === 0) return ""
		var dash = text.indexOf("-")
		if (dash > 0) text = text.slice(0, dash)
		return text
	}

	function formatVersion(value: string): string {
		var text = value.trim()
		if (text.length === 0) return ""
		return text.replace(/\s+/g, " ")
	}

	function resolveDistro(id: string, like: string, pretty: string): var {
		var key = (id || "").toLowerCase().trim()
		var likeTokens = (like || "").toLowerCase().split(/\s+/)
		var map = {
			"arch": { icon: "", name: "Arch Linux" },
			"nixos": { icon: "", name: "NixOS" },
			"ubuntu": { icon: "", name: "Ubuntu" },
			"debian": { icon: "", name: "Debian" },
			"fedora": { icon: "", name: "Fedora" },
			"opensuse": { icon: "", name: "openSUSE" },
			"manjaro": { icon: "", name: "Manjaro" },
			"gentoo": { icon: "", name: "Gentoo" },
		}

		if (map[key]) return map[key]
		for (var i = 0; i < likeTokens.length; i++) {
			var token = likeTokens[i]
			if (map[token]) return map[token]
		}
		return { icon: "", name: formatDistro(pretty) }
	}

	function runPowerAction(action: string): void {
		var args = []
		if (action === "poweroff") args = ["systemctl", "poweroff"]
		else if (action === "reboot") args = ["systemctl", "reboot"]
		else if (action === "suspend") args = ["systemctl", "suspend"]
		else if (action === "logout") args = ["hyprctl", "dispatch", "exit"]
		else if (action === "lock") args = ["qs", "ipc", "call", "lock", "lock"]
		if (args.length === 0) return

		root.expanded = false
		powerControl.exec(args)
	}

	implicitWidth: osIcon.implicitWidth + (BarTheme.widget_padding * 2)
	implicitHeight: BarTheme.widget_height
	radius: Theme.radius_normal
	color: root.pressed
		? Theme.color_surface_pressed
		: (root.hovered ? Theme.color_surface_hover : Theme.color_surface)
	border.width: Theme.border_width
	border.color: Theme.color_border

	Behavior on color {
		ColorAnimation {
			duration: Animations.duration_hover
			easing.type: Animations.easing_standard
		}
	}

	Text {
		id: osIcon
		anchors.centerIn: parent
		text: root.distroIcon
		color: Theme.color_text
		font.pixelSize: Theme.font_size + 2
		font.family: Theme.font_family_icon
	}

	MouseArea {
		id: clickArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: root.expanded = !root.expanded
	}

	PopupWindow {
		id: dropdown
		anchor.item: root
		visible: root.expanded || dropdownPanel.opacity > 0.01
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
					id: aboutItem
					Layout.fillWidth: true
					Layout.preferredHeight: aboutContent.implicitHeight + (BarTheme.widget_padding * 2)
					radius: Theme.radius_normal
					color: Theme.color_surface

					ColumnLayout {
						id: aboutContent
						anchors.fill: parent
						anchors.margins: BarTheme.widget_padding
						spacing: 2

						RowLayout {
							Layout.fillWidth: true
							spacing: 6

							ColumnLayout {
								Layout.fillWidth: true
								spacing: 2

								Text {
									Layout.fillWidth: true
									text: root.distroDisplay
									elide: Text.ElideRight
									color: Theme.color_text
									font.pixelSize: Theme.font_size
									font.family: Theme.font_family
								}

								Text {
									Layout.fillWidth: true
									text: root.kernelDisplay.length > 0 ? ("Kernel " + root.kernelDisplay) : ""
									visible: text.length > 0
									color: Theme.color_text_subtle
									font.pixelSize: Theme.font_size - 1
									font.family: Theme.font_family
								}

								Text {
									Layout.fillWidth: true
									text: root.versionDisplay.length > 0 ? ("Version " + root.versionDisplay) : ""
									visible: text.length > 0
									color: Theme.color_text_subtle
									font.pixelSize: Theme.font_size - 1
									font.family: Theme.font_family
								}
							}

								Text {
									text: root.distroIcon
									color: Theme.color_text
									font.pixelSize: Theme.font_size + 4
									font.family: Theme.font_family_icon
							}
						}
					}
				}

				Rectangle {
					Layout.fillWidth: true
					Layout.preferredHeight: 1
					color: Theme.color_border
					opacity: 0.5
				}

				Repeater {
					model: root.powerActions

					Rectangle {
						id: option
						required property var modelData
						property bool hovered: optionArea.containsMouse
						property bool pressed: optionArea.pressed
						Layout.fillWidth: true
						Layout.preferredHeight: BarTheme.widget_height
						radius: Theme.radius_normal
						color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")

						RowLayout {
							anchors.fill: parent
							anchors.leftMargin: BarTheme.widget_padding
							anchors.rightMargin: BarTheme.widget_padding
							spacing: 8

							Text {
								text: option.modelData.icon
								color: Theme.color_text
								font.pixelSize: Theme.font_size + 2
								font.family: Theme.font_family_icon
							}

							Text {
								Layout.fillWidth: true
								text: option.modelData.label
								color: Theme.color_text
								font.pixelSize: Theme.font_size
								font.family: Theme.font_family
							}
						}

						MouseArea {
							id: optionArea
							anchors.fill: parent
							hoverEnabled: true
							cursorShape: Qt.PointingHandCursor
							onClicked: root.runPowerAction(option.modelData.action)
						}
					}
				}
			}
		}
	}

	Process {
		id: powerControl
	}

	StdioCollector {
		id: osProbeOut
		waitForEnd: true
		onStreamFinished: {
			var lines = text.trim().split("\n")
			if (lines.length > 0 && lines[0].length > 0) root.osInfo = lines[0]
			if (lines.length > 1 && lines[1].length > 0) root.osId = lines[1]
			if (lines.length > 2) root.osLike = lines[2]
			if (lines.length > 3) root.osVersionRaw = lines[3]
			if (lines.length > 4 && lines[4].length > 0) root.kernelInfo = lines[4]
		}
	}

	Process {
		id: osProbe
		stdout: osProbeOut
		command: [
			"sh",
			"-c",
			". /etc/os-release 2>/dev/null; printf '%s\\n' \"${PRETTY_NAME:-Linux}\" \"${ID:-linux}\" \"${ID_LIKE:-}\" \"${VERSION_ID:-${VERSION:-}}\"; uname -r"
		]
	}

	Component.onCompleted: osProbe.running = true
}

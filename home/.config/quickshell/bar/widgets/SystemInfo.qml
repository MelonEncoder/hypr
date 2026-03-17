import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import Quickshell.Widgets
import ".." as Bar
import "../../constants" as Constants

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

	implicitWidth: osIcon.implicitWidth + (Bar.BarTheme.widget_padding * 2)
	implicitHeight: Bar.BarTheme.widget_height
	radius: Constants.Theme.radius_normal
	color: root.pressed
		? Constants.Theme.color_surface_pressed
		: (root.hovered ? Constants.Theme.color_surface_hover : Constants.Theme.color_surface)
	border.width: Constants.Theme.border_width
	border.color: Constants.Theme.color_border

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
		color: Constants.Theme.color_text
		font.pixelSize: Constants.Theme.font_size + 2
		font.family: Constants.Theme.font_family_icon
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
		visible: root.expanded
		implicitWidth: dropdown.screen.width
		implicitHeight: dropdown.screen.height
		color: "transparent"

		Rectangle {
			anchors.fill: parent
			color: "transparent"
			MouseArea {
				anchors.fill: parent
				enabled: root.expanded
				onClicked: root.expanded = false
			}
		}

		Rectangle {
			id: dropdownPanel
			y: Bar.BarTheme.popup_offset_y
			width: root.popupWidth + (Bar.BarTheme.widget_padding * 2)
			height: popupContent.implicitHeight + (Bar.BarTheme.widget_padding * 2)
			radius: Constants.Theme.radius_background
			color: Constants.Theme.color_background
			border.width: Constants.Theme.border_width
			border.color: Constants.Theme.color_border
			clip: true
			opacity: root.expanded ? 1 : 0
			scale: root.expanded ? 1 : Animations.dropdown_scale_closed
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

			MouseArea { anchors.fill: parent }

			ColumnLayout {
				id: popupContent
				anchors.fill: parent
				anchors.margins: Bar.BarTheme.widget_padding
				spacing: Bar.BarTheme.inner_spacing
				width: root.popupWidth

				Rectangle {
					id: aboutItem
					Layout.fillWidth: true
					Layout.preferredHeight: aboutContent.implicitHeight + (Bar.BarTheme.widget_padding * 2)
					radius: Constants.Theme.radius_normal
					color: Constants.Theme.color_surface

					ColumnLayout {
						id: aboutContent
						anchors.fill: parent
						anchors.margins: Bar.BarTheme.widget_padding
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
									color: Constants.Theme.color_text
									font.pixelSize: Constants.Theme.font_size
									font.family: Constants.Theme.font_family
								}

								Text {
									Layout.fillWidth: true
									text: root.kernelDisplay.length > 0 ? ("Kernel " + root.kernelDisplay) : ""
									visible: text.length > 0
									color: Constants.Theme.color_text_subtle
									font.pixelSize: Constants.Theme.font_size - 1
									font.family: Constants.Theme.font_family
								}

								Text {
									Layout.fillWidth: true
									text: root.versionDisplay.length > 0 ? ("Version " + root.versionDisplay) : ""
									visible: text.length > 0
									color: Constants.Theme.color_text_subtle
									font.pixelSize: Constants.Theme.font_size - 1
									font.family: Constants.Theme.font_family
								}
							}

								Text {
									text: root.distroIcon
									color: Constants.Theme.color_text
									font.pixelSize: Constants.Theme.font_size + 4
									font.family: Constants.Theme.font_family_icon
							}
						}
					}
				}

				Rectangle {
					Layout.fillWidth: true
					Layout.preferredHeight: 1
					color: Constants.Theme.color_border
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
						Layout.preferredHeight: Bar.BarTheme.widget_height
						radius: Constants.Theme.radius_normal
						color: pressed ? Constants.Theme.color_surface_pressed : (hovered ? Constants.Theme.color_surface_hover : "transparent")

						RowLayout {
							anchors.fill: parent
							anchors.leftMargin: Bar.BarTheme.widget_padding
							anchors.rightMargin: Bar.BarTheme.widget_padding
							spacing: 8

							Text {
								text: option.modelData.icon
								color: Constants.Theme.color_text
								font.pixelSize: Constants.Theme.font_size + 2
								font.family: Constants.Theme.font_family_icon
							}

							Text {
								Layout.fillWidth: true
								text: option.modelData.label
								color: Constants.Theme.color_text
								font.pixelSize: Constants.Theme.font_size
								font.family: Constants.Theme.font_family
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

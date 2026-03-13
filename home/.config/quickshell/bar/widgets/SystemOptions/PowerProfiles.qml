import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower as UPower
import Quickshell.Io
import "../../../constants" as Constants
import "../../" as Bar

Rectangle {
	id: root
	property bool expanded: false
	property bool daemonKnown: false
	property bool daemonRunning: false
	property bool profilesKnown: false
	property string currentProfileId: ""
	property var supportedProfileIds: []
	readonly property int sectionMargin: Math.round(Bar.BarTheme.widget_padding / 2)
	readonly property int expandedContentHeight: powerProfilesExpandedContent.implicitHeight
	readonly property var availableProfiles: getAvailableProfiles()

	function hasProfile(profileId: string): bool {
		return root.supportedProfileIds.indexOf(profileId) !== -1
	}

	function getAvailableProfiles(): var {
		return [
			{
				value: UPower.PowerProfile.PowerSaver,
				id: "power-saver",
				label: root.daemonRunning && !root.hasProfile("power-saver")
					? "Power Saver - unavailable"
					: "Power Saver",
				enabled: root.hasProfile("power-saver")
			},
			{
				value: UPower.PowerProfile.Balanced,
				id: "balanced",
				label: root.daemonRunning && !root.hasProfile("balanced")
					? "Balanced - unavailable"
					: "Balanced",
				enabled: root.hasProfile("balanced")
			},
			{
				value: UPower.PowerProfile.Performance,
				label: root.daemonRunning && !root.hasProfile("performance")
					? "Performance - unavailable"
					: "Performance",
				id: "performance",
				enabled: root.hasProfile("performance")
			}
		]
	}

	function profileLabel(profileId: string): string {
		switch (profileId) {
		case "power-saver":
			return "Power Saver"
		case "performance":
			return "Performance"
		case "balanced":
			return "Balanced"
		default:
			return "Balanced"
		}
	}

	function subtitleText(): string {
		if (!root.daemonKnown) return "Checking..."
		if (!root.daemonRunning) return "Enable power-profiles-daemon"
		if (!root.profilesKnown) return "Checking profiles..."
		if (root.supportedProfileIds.length <= 1) return "No power profiles available"
		if (root.currentProfileId.length > 0) return root.profileLabel(root.currentProfileId)
		return "Balanced"
	}

	function setProfile(profileId: string): void {
		if (!root.daemonRunning) return
		if (root.supportedProfileIds.indexOf(profileId) === -1) return
		if (root.currentProfileId === profileId) return
		profileSet.exec(["powerprofilesctl", "set", profileId])
		profilesRefresh.restart()
	}

	implicitWidth: 280
	implicitHeight: powerProfilesFrame.implicitHeight + (root.sectionMargin * 2)
	width: implicitWidth
	height: implicitHeight
	Layout.fillWidth: true
	Layout.preferredWidth: implicitWidth
	Layout.preferredHeight: implicitHeight
	radius: Constants.Theme.radius_normal
	color: Constants.Theme.color_surface

	Item {
		id: powerProfilesFrame
		x: root.sectionMargin
		y: root.sectionMargin
		width: parent.width - (root.sectionMargin * 2)
		implicitHeight: powerProfilesMenu.implicitHeight

		ColumnLayout {
			id: powerProfilesMenu
			width: parent.width
			spacing: 4

			Rectangle {
				id: powerProfilesDropdown
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
						text: "Power Profiles"
						color: Constants.Theme.color_text
						font.pixelSize: Constants.Theme.font_size
						font.family: Constants.Theme.font_family
					}

					Text {
						id: currentProfile
						text: root.subtitleText()
						color: Constants.Theme.color_text_subtle
						font.pixelSize: Constants.Theme.font_size - 1
						font.family: Constants.Theme.font_family
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
					onClicked: root.expanded = !root.expanded
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
					id: powerProfilesExpandedContent
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: 3

					Repeater {
						model: root.availableProfiles

						Rectangle {
							id: profileItem
							required property var modelData
							property bool hovered: profileMouse.containsMouse
							property bool pressed: profileMouse.pressed
							readonly property bool selectable: root.daemonRunning && modelData.enabled !== false
							Layout.fillWidth: true
							Layout.preferredHeight: 24
							radius: Constants.Theme.radius_normal
							color: profileItem.selectable && root.currentProfileId === modelData.id
								? Constants.Theme.color_surface_hover
								: (pressed ? Constants.Theme.color_surface_pressed : (hovered ? Constants.Theme.color_surface_hover : "transparent"))

							Text {
								anchors.left: parent.left
								anchors.leftMargin: 8
								anchors.verticalCenter: parent.verticalCenter
								text: profileItem.modelData.label
								color: profileItem.selectable ? Constants.Theme.color_text : Constants.Theme.color_text_subtle
								font.pixelSize: Constants.Theme.font_size
								font.family: Constants.Theme.font_family
								elide: Text.ElideRight
								width: parent.width - 32
							}

							Text {
								anchors.right: parent.right
								anchors.rightMargin: 8
								anchors.verticalCenter: parent.verticalCenter
								visible: profileItem.selectable && root.currentProfileId === profileItem.modelData.id
								text: "󰄬"
								color: Constants.Theme.color_text
								font.pixelSize: Constants.Theme.font_size - 1
								font.family: Constants.Theme.font_family_icon
							}

							MouseArea {
								id: profileMouse
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: profileItem.selectable ? Qt.PointingHandCursor : Qt.ArrowCursor
								enabled: profileItem.selectable
								onClicked: root.setProfile(profileItem.modelData.id)
							}
						}
					}
				}
			}
		}
	}

	StdioCollector {
		id: daemonProbeOut
		waitForEnd: true
		onStreamFinished: {
			root.daemonKnown = true
			root.daemonRunning = text.trim() === "1"
			if (root.daemonRunning) {
				root.profilesKnown = false
				profilesProbe.exec(["powerprofilesctl", "list"])
			} else {
				root.profilesKnown = true
				root.currentProfileId = ""
				root.supportedProfileIds = []
			}
		}
	}

	Process {
		id: daemonProbe
		stdout: daemonProbeOut
	}

	StdioCollector {
		id: profilesProbeOut
		waitForEnd: true
		onStreamFinished: {
			var ids = []
			var current = ""
			var lines = text.split("\n")

			for (var i = 0; i < lines.length; i++) {
				var match = lines[i].match(/^(\*?\s*)(power-saver|balanced|performance):\s*$/)
				if (!match) continue
				var id = match[2]
				if (ids.indexOf(id) === -1) ids.push(id)
				if (match[1].indexOf("*") !== -1) current = id
			}

			root.supportedProfileIds = ids
			root.currentProfileId = current
			root.profilesKnown = true
		}
	}

	Process {
		id: profilesProbe
		stdout: profilesProbeOut
	}

	Process {
		id: profileSet
	}

	Timer {
		id: profilesRefresh
		interval: 400
		running: false
		repeat: false
		onTriggered: {
			if (root.daemonRunning) {
				root.profilesKnown = false
				profilesProbe.exec(["powerprofilesctl", "list"])
			}
		}
	}

	Component.onCompleted: {
		daemonProbe.exec([
			"sh",
			"-c",
			"if pgrep -f '/power-profiles-daemon( |$)' >/dev/null 2>&1; then printf '1\\n'; else printf '0\\n'; fi"
		])
	}
}

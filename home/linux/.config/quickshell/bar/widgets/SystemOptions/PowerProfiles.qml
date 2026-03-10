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
	property bool daemonInstalled: false
	readonly property int sectionMargin: Math.round(Bar.BarTheme.widget_padding / 2)
	readonly property int expandedContentHeight: powerProfilesExpandedContent.implicitHeight
	readonly property var availableProfiles: getAvailableProfiles()

	function getAvailableProfiles(): var {
		return [
			{ value: UPower.PowerProfile.PowerSaver, label: "Power Saver" },
			{ value: UPower.PowerProfile.Balanced, label: "Balanced" },
			{
				value: UPower.PowerProfile.Performance,
				label: root.daemonInstalled && !UPower.PowerProfiles.hasPerformanceProfile
					? "Performance - unavailable"
					: "Performance",
				enabled: UPower.PowerProfiles.hasPerformanceProfile
			}
		]
	}

	function profileLabel(profile: int): string {
		var label = UPower.PowerProfile.toString(profile)
		if (label && label.length > 0) return label
		return "Balanced"
	}

	function subtitleText(): string {
		if (!root.daemonKnown) return "Checking..."
		if (!root.daemonInstalled) return "Install power-profiles-daemon"
		return root.profileLabel(UPower.PowerProfiles.profile)
	}

	function setProfile(profile: int): void {
		if (!root.daemonInstalled) return
		if (profile === UPower.PowerProfile.Performance && !UPower.PowerProfiles.hasPerformanceProfile) return
		if (UPower.PowerProfiles.profile === profile) return
		UPower.PowerProfiles.profile = profile
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
							readonly property bool selectable: root.daemonInstalled && modelData.enabled !== false
							Layout.fillWidth: true
							Layout.preferredHeight: 24
							radius: Constants.Theme.radius_normal
							color: profileItem.selectable && UPower.PowerProfiles.profile === modelData.value
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
								visible: profileItem.selectable && UPower.PowerProfiles.profile === profileItem.modelData.value
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
								onClicked: root.setProfile(profileItem.modelData.value)
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
			root.daemonInstalled = text.trim() === "1"
		}
	}

	Process {
		id: daemonProbe
		stdout: daemonProbeOut
	}

	Component.onCompleted: {
		daemonProbe.exec([
			"sh",
			"-c",
			"if command -v powerprofilesctl >/dev/null 2>&1 || command -v powerprofilesd >/dev/null 2>&1; then printf '1\\n'; else printf '0\\n'; fi"
		])
	}
}

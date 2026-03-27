import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../../"

Rectangle {
	id: root
	property bool expanded: false
	readonly property int sectionMargin: Math.round(Theme.bar_widget_padding / 2)
	readonly property int expandedContentHeight: powerProfilesExpandedContent.implicitHeight

	readonly property var profiles: [
		{ label: "Power Saver", profile: PowerProfile.PowerSaver, available: true },
		{ label: "Balanced",    profile: PowerProfile.Balanced,   available: true },
		{ label: "Performance", profile: PowerProfile.Performance, available: PowerProfiles.hasPerformanceProfile }
	]

	function profileLabel(profile): string {
		switch (profile) {
		case PowerProfile.PowerSaver:   return "Power Saver"
		case PowerProfile.Balanced:     return "Balanced"
		case PowerProfile.Performance:  return "Performance"
		default:                        return "Unknown"
		}
	}

	implicitWidth: 280
	implicitHeight: powerProfilesFrame.implicitHeight + (root.sectionMargin * 2)
	width: implicitWidth
	height: implicitHeight
	Layout.fillWidth: true
	Layout.preferredWidth: implicitWidth
	Layout.preferredHeight: implicitHeight
	radius: Theme.radius_normal
	color: Theme.color_surface

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
				id: powerProfilesHeader
				property bool hovered: powerProfilesHeaderMouse.containsMouse
				property bool pressed: powerProfilesHeaderMouse.pressed
				Layout.fillWidth: true
				Layout.preferredHeight: Theme.bar_widget_height * 1.5
				radius: Theme.radius_normal
				color: pressed ? Theme.color_surface_pressed : Theme.color_surface_hover

				Behavior on color {
					ColorAnimation {
						duration: Animations.duration_hover
						easing.type: Animations.easing_standard
					}
				}

				RowLayout {
					anchors {
						left: parent.left
						right: parent.right
						verticalCenter: parent.verticalCenter
						leftMargin: 10
						rightMargin: 10
					}
					spacing: 12

					Text {
						text: "󰔐"
						color: Theme.color_text
						font.pixelSize: Theme.font_size + 2
						font.family: Theme.font_family_icon
						Layout.alignment: Qt.AlignVCenter
					}

					Column {
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignVCenter
						spacing: 1

						Text {
							text: "Power Profiles"
							color: Theme.color_text
							font.pixelSize: Theme.font_size
							font.family: Theme.font_family
						}

						Text {
							text: root.profileLabel(PowerProfiles.profile)
							color: Theme.color_text_subtle
							font.pixelSize: Theme.font_size
							font.family: Theme.font_family
						}
					}

					Text {
						text: root.expanded ? "" : ""
						color: Theme.color_text_subtle
						font.pixelSize: Theme.font_size - 2
						font.family: Theme.font_family_icon
						Layout.alignment: Qt.AlignVCenter
					}
				}

				MouseArea {
					id: powerProfilesHeaderMouse
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

				Behavior on Layout.preferredHeight {
					NumberAnimation {
						duration: Animations.duration_dropdown_section
						easing.type: Animations.easing_emphasized
					}
				}

				Behavior on opacity {
					NumberAnimation {
						duration: Animations.duration_dropdown_section
						easing.type: Animations.easing_emphasized
					}
				}

				ColumnLayout {
					id: powerProfilesExpandedContent
					anchors.left: parent.left
					anchors.right: parent.right
					spacing: 3

					Repeater {
						model: root.profiles

						Rectangle {
							required property var modelData
							required property int index
							property bool hovered: profileMouse.containsMouse
							property bool pressed: profileMouse.pressed
							readonly property bool active: PowerProfiles.profile === modelData.profile
							Layout.fillWidth: true
							Layout.preferredHeight: Theme.bar_widget_height
							Layout.topMargin: index === 0 ? 4 : 0
							radius: Theme.radius_normal
							color: active
								? Theme.color_surface_hover
								: (pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent"))

							Behavior on color {
								ColorAnimation {
									duration: Animations.duration_hover
									easing.type: Animations.easing_standard
								}
							}

							Text {
								anchors.left: parent.left
								anchors.leftMargin: 10
								anchors.verticalCenter: parent.verticalCenter
								text: modelData.available ? modelData.label : modelData.label + " - unavailable"
								color: modelData.available ? Theme.color_text : Theme.color_text_subtle
								font.pixelSize: Theme.font_size
								font.family: Theme.font_family
								elide: Text.ElideRight
								width: parent.width - 36
							}

							Text {
								anchors.right: parent.right
								anchors.rightMargin: 10
								anchors.verticalCenter: parent.verticalCenter
								visible: active
								text: "󰄬"
								color: Theme.color_text
								font.pixelSize: Theme.font_size
								font.family: Theme.font_family_icon
							}

							MouseArea {
								id: profileMouse
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: modelData.available ? Qt.PointingHandCursor : Qt.ArrowCursor
								enabled: modelData.available
								onClicked: PowerProfiles.profile = modelData.profile
							}
						}
					}
				}
			}
		}
	}
}

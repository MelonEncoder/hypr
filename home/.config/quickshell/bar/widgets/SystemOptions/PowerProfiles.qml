import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../../../constants" as Constants
import "../../" as Bar

Rectangle {
	id: root
	property bool expanded: false
	readonly property int sectionMargin: Math.round(Bar.BarTheme.widget_padding / 2)
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
				id: powerProfilesHeader
				property bool hovered: powerProfilesHeaderMouse.containsMouse
				property bool pressed: powerProfilesHeaderMouse.pressed
				Layout.fillWidth: true
				Layout.preferredHeight: Bar.BarTheme.widget_height * 1.5
				radius: Constants.Theme.radius_normal
				color: pressed ? Constants.Theme.color_surface_pressed : Constants.Theme.color_surface_hover

				Behavior on color {
					ColorAnimation {
						duration: Constants.Animations.duration_hover
						easing.type: Constants.Animations.easing_standard
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
						color: Constants.Theme.color_text
						font.pixelSize: Constants.Theme.font_size + 2
						font.family: Constants.Theme.font_family_icon
						Layout.alignment: Qt.AlignVCenter
					}

					Column {
						Layout.fillWidth: true
						Layout.alignment: Qt.AlignVCenter
						spacing: 1

						Text {
							text: "Power Profiles"
							color: Constants.Theme.color_text
							font.pixelSize: Constants.Theme.font_size
							font.family: Constants.Theme.font_family
						}

						Text {
							text: root.profileLabel(PowerProfiles.profile)
							color: Constants.Theme.color_text_subtle
							font.pixelSize: Constants.Theme.font_size
							font.family: Constants.Theme.font_family
						}
					}

					Text {
						text: root.expanded ? "" : ""
						color: Constants.Theme.color_text_subtle
						font.pixelSize: Constants.Theme.font_size - 2
						font.family: Constants.Theme.font_family_icon
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
						duration: Constants.Animations.duration_dropdown_section
						easing.type: Constants.Animations.easing_emphasized
					}
				}

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
						model: root.profiles

						Rectangle {
							required property var modelData
							required property int index
							property bool hovered: profileMouse.containsMouse
							property bool pressed: profileMouse.pressed
							readonly property bool active: PowerProfiles.profile === modelData.profile
							Layout.fillWidth: true
							Layout.preferredHeight: Bar.BarTheme.widget_height
							Layout.topMargin: index === 0 ? 4 : 0
							radius: Constants.Theme.radius_normal
							color: active
								? Constants.Theme.color_surface_hover
								: (pressed ? Constants.Theme.color_surface_pressed : (hovered ? Constants.Theme.color_surface_hover : "transparent"))

							Behavior on color {
								ColorAnimation {
									duration: Constants.Animations.duration_hover
									easing.type: Constants.Animations.easing_standard
								}
							}

							Text {
								anchors.left: parent.left
								anchors.leftMargin: 10
								anchors.verticalCenter: parent.verticalCenter
								text: modelData.available ? modelData.label : modelData.label + " - unavailable"
								color: modelData.available ? Constants.Theme.color_text : Constants.Theme.color_text_subtle
								font.pixelSize: Constants.Theme.font_size
								font.family: Constants.Theme.font_family
								elide: Text.ElideRight
								width: parent.width - 36
							}

							Text {
								anchors.right: parent.right
								anchors.rightMargin: 10
								anchors.verticalCenter: parent.verticalCenter
								visible: active
								text: "󰄬"
								color: Constants.Theme.color_text
								font.pixelSize: Constants.Theme.font_size
								font.family: Constants.Theme.font_family_icon
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

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "."
import "bar_widgets"

Scope {
	Variants {
		model: Quickshell.screens;

		PanelWindow {
			id: root
			required property var modelData

			readonly property int section_margin: 12
			readonly property int widget_spacing: 8
			readonly property int inner_spacing: 6
			readonly property int popup_offset_y: Theme.bar_widget_height + (Theme.bar_padding * 2)
			readonly property int tray_item_size: 22
			readonly property int tray_icon_size: 16

			anchors {
				top: true
				left: true
				right: true
			}

			screen: modelData
			color: Theme.color_background
			implicitHeight: barContent.implicitHeight + (Theme.bar_padding * 2)

			Item {
				id: barContent
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.topMargin: Theme.bar_padding
				anchors.leftMargin: Theme.bar_padding
				anchors.rightMargin: Theme.bar_padding
				implicitHeight: Math.max(leftRow.implicitHeight, centerRow.implicitHeight, rightRow.implicitHeight)

				Item {
					id: leftSection
					anchors.left: parent.left
					anchors.verticalCenter: parent.verticalCenter
					width: parent.width / 3
					height: leftRow.implicitHeight
					RowLayout {
						id: leftRow
						anchors.left: parent.left
						anchors.verticalCenter: parent.verticalCenter
						spacing: root.widget_spacing
						SystemInfo { Layout.alignment: Qt.AlignVCenter }
						Workspaces { Layout.alignment: Qt.AlignVCenter }
						CurrentWindow { Layout.alignment: Qt.AlignVCenter }
					}
				}

				Item {
					id: centerSection
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.verticalCenter: parent.verticalCenter
					width: parent.width / 3
					height: centerRow.implicitHeight
					RowLayout {
						id: centerRow
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.verticalCenter: parent.verticalCenter
						spacing: root.widget_spacing
						Clock { Layout.alignment: Qt.AlignVCenter }
					}
				}

				Item {
					id: rightSection
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					width: parent.width / 3
					height: rightRow.implicitHeight
					RowLayout {
						id: rightRow
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						spacing: root.widget_spacing
						Media { Layout.alignment: Qt.AlignVCenter }
						PrivacyIndicator { Layout.alignment: Qt.AlignVCenter }
						IdleInhibitor { Layout.alignment: Qt.AlignVCenter }
						SystemTray { Layout.alignment: Qt.AlignVCenter }
						BatteryStatus { Layout.alignment: Qt.AlignVCenter }
						SystemOptions {
							Layout.alignment: Qt.AlignVCenter
							panelScreenName: modelData && modelData.name ? modelData.name : ""
						}
					}
				}
			}
		}
	}
}

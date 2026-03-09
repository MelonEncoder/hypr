import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "."
import "../constants"
import "widgets"

Scope {
	Variants {
		model: Quickshell.screens;

		PanelWindow {
			id: root
			required property var modelData

			anchors {
				top: true
				left: true
				right: true
			}

			screen: modelData
			color: Theme.color_background
			implicitHeight: barContent.implicitHeight + (BarTheme.bar_padding * 2)

			Item {
				id: barContent
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.topMargin: BarTheme.bar_padding
				anchors.leftMargin: BarTheme.bar_padding
				anchors.rightMargin: BarTheme.bar_padding
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
						spacing: BarTheme.widget_spacing
						SystemInfo { Layout.alignment: Qt.AlignVCenter }
						Workspaces { Layout.alignment: Qt.AlignVCenter }
						Media { Layout.alignment: Qt.AlignVCenter }
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
						spacing: BarTheme.widget_spacing
						CurrentWindow { Layout.alignment: Qt.AlignVCenter }
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
						spacing: BarTheme.widget_spacing
						PrivacyIndicator { Layout.alignment: Qt.AlignVCenter }
						IdleInhibitor { Layout.alignment: Qt.AlignVCenter }
						SystemTray { Layout.alignment: Qt.AlignVCenter }
						Audio { Layout.alignment: Qt.AlignVCenter }
						BatteryStatus { Layout.alignment: Qt.AlignVCenter }
						Date { Layout.alignment: Qt.AlignVCenter }
						Time { Layout.alignment: Qt.AlignVCenter }
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

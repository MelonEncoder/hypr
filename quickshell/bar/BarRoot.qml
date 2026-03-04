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
			color: Theme.colors.background
			implicitHeight: barContent.implicitHeight + (BarTheme.contentMargin * 2)
			
			Item {
				id: barContent
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.topMargin: BarTheme.contentMargin
				anchors.leftMargin: BarTheme.contentMargin
				anchors.rightMargin: BarTheme.contentMargin
				implicitHeight: Math.max(leftRow.implicitHeight, centerRow.implicitHeight, rightRow.implicitHeight)

				// LEFT SECTION
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
						spacing: BarTheme.widgetSpacing
						SystemInfo { Layout.alignment: Qt.AlignVCenter }
						Workspaces { Layout.alignment: Qt.AlignVCenter }
						Media { Layout.alignment: Qt.AlignVCenter }
					}
				}
				
				// CENTER SECTION
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
						CurrentWindow { Layout.alignment: Qt.AlignVCenter }
					}
				}
				
				// RIGHT SECTION
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
						spacing: BarTheme.widgetSpacing
						IdleInhibitor { Layout.alignment: Qt.AlignVCenter }
						SystemTray { Layout.alignment: Qt.AlignVCenter }
						QuickSettings { Layout.alignment: Qt.AlignVCenter }
						Date { Layout.alignment: Qt.AlignVCenter }
						Time { Layout.alignment: Qt.AlignVCenter }
						PowerOptions { Layout.alignment: Qt.AlignVCenter }
					}
				}
			}
		}
	}
}

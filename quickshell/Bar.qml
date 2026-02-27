import Quickshell
import QtQuick
import QtQuick.Layouts
	
Scope {
	Variants {
		model: Quickshell.screens;

		PanelWindow {
			required property var modelData

			screen: modelData
			color: Theme.barBackground

			anchors {
				top: true
				left: true
				right: true
			}

			implicitHeight: Theme.barHeight
	
			// LEFT SECTIOn
			Item {
				id: leftSection
				anchors.left: parent.left
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				width: parent.width / 3
				RowLayout {
					anchors.left: parent.left
					anchors.verticalCenter: parent.verticalCenter
					anchors.leftMargin: Theme.edgeMarginX
					height: parent.height
					spacing: Theme.widgetSpacing
					SystemInfoWidget { Layout.alignment: Qt.AlignVCenter }
					CurrentWindowWidget { Layout.alignment: Qt.AlignVCenter }
					MediaWidget { Layout.alignment: Qt.AlignVCenter }
				}
			}
			
			// CENTER SECTION
			Item {
				id: centerSection
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				width: parent.width / 3
				RowLayout {
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.verticalCenter: parent.verticalCenter
					height: parent.height
					WorkspacesWidget { Layout.alignment: Qt.AlignVCenter }
				}
			}
			
			// RIGHT SECTION
			Item {
				id: rightSection
				anchors.right: parent.right
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				width: parent.width / 3
				RowLayout {		
					anchors.right: parent.right
					anchors.verticalCenter: parent.verticalCenter
					anchors.rightMargin: Theme.edgeMarginX
					height: parent.height
					spacing: Theme.widgetSpacing
					IdleInhibitorWidget { Layout.alignment: Qt.AlignVCenter }
					TrayWidget { Layout.alignment: Qt.AlignVCenter }
					QuickSettingsWidget { Layout.alignment: Qt.AlignVCenter }
					DateWidget { Layout.alignment: Qt.AlignVCenter }
					TimeWidget { Layout.alignment: Qt.AlignVCenter }
					PowerWidget { Layout.alignment: Qt.AlignVCenter }
				}
			}
		}
	}
}

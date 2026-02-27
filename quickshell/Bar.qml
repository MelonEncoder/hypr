import Quickshell
import QtQuick
import QtQuick.Layouts
	
Scope {
	Variants {
		model: Quickshell.screens;

		PanelWindow {
			required property var modelData

			screen: modelData
			color: Colors.barBackground

			anchors {
				top: true
				left: true
				right: true
			}

			implicitHeight: 30
	
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
					anchors.leftMargin: 12
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
					WorkspacesWidget {}
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
					anchors.rightMargin: 12
					spacing: 10
					IdleInhibitorWidget {}
					TrayWidget {}
					DateWidget {}
					TimeWidget {}
				}
			}
		}
	}
}

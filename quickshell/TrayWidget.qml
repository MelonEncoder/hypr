import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Rectangle {
	id: root
	radius: 5
	color: Colors.surfaceBackground
	border.width: 1
	border.color: Colors.surfaceBorder
	implicitWidth: trayRow.implicitWidth + 12
	implicitHeight: trayRow.implicitHeight + 8

	RowLayout {
		id: trayRow
		anchors.centerIn: parent
		spacing: 6

		Repeater {
			model: SystemTray.items

			Rectangle {
				id: trayItem
				required property var modelData
				radius: 4
				color: "transparent"
				implicitWidth: 22
				implicitHeight: 22

				IconImage {
					id: trayIcon
					anchors.centerIn: parent
					source: trayItem.modelData.icon
					implicitSize: 16
				}

				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.LeftButton | Qt.RightButton
					onClicked: function(mouse) {
						if (!trayItem.modelData) return

						if (mouse.button == Qt.LeftButton) {
							if (!trayItem.modelData.onlyMenu) {
								trayItem.modelData.activate()
							}
						}

						if (mouse.button == Qt.RightButton && trayItem.modelData.hasMenu && QsWindow.window) {
							var point = trayItem.mapToItem(null, Math.round(trayItem.width / 2), trayItem.height)
							trayItem.modelData.display(
								QsWindow.window,
								Math.round(point.x),
								Math.round(point.y)
							)
						}
					}
				}
			}
		}
	}
}

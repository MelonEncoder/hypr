import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Button {
	id: root
	property bool expanded: false
	hoverEnabled: true

	implicitWidth: label.implicitWidth + Theme.widgetPaddingX
	implicitHeight: Theme.widgetHeight
	onClicked: expanded = !expanded

	contentItem: Text {
		id: label
		text: root.expanded ?  "" : ""
		color: root.expanded ? Theme.textOnActive : Theme.textPrimary
		font.pixelSize: Theme.fontIconSize
		font.family: Theme.fontFamily
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
	}

	background: Rectangle {
		radius: Theme.radius
		color: root.expanded
			? Theme.widgetBackgroundActive
			: (root.hovered ? Theme.widgetBackgroundHover : Theme.widgetBackgroundIdle)
		border.width: Theme.borderWidth
		border.color: Theme.surfaceBorder
	}

	PopupWindow {
		id: dropdown
		anchor.window: QsWindow.window
		visible: root.expanded
		anchor.rect.x: root.mapToItem(QsWindow.window ? QsWindow.window.contentItem : null, 0, 0).x
			+ Math.round((root.width - width) / 2)
		anchor.rect.y: root.mapToItem(QsWindow.window ? QsWindow.window.contentItem : null, 0, 0).y
			+ root.height + Theme.popupOffset
		implicitWidth: trayRow.implicitWidth + Theme.widgetPaddingX
		implicitHeight: trayRow.implicitHeight + Theme.widgetPaddingY
		color: "transparent"

		Rectangle {
			anchors.fill: parent
			radius: Theme.radius
			color: Theme.widgetBackgroundIdle
			border.width: Theme.borderWidth
			border.color: Theme.surfaceBorder
			clip: true

			RowLayout {
				id: trayRow
				anchors.centerIn: parent
				spacing: Theme.innerSpacing

				Repeater {
					model: SystemTray.items

					Rectangle {
						id: trayItem
						required property var modelData
						property bool hovered: trayHover.containsMouse
						radius: Theme.radiusBg
						color: hovered ? Theme.widgetBackgroundHover : "transparent"
						implicitWidth: Theme.trayItemSize
						implicitHeight: Theme.trayItemSize

						IconImage {
							id: trayIcon
							anchors.centerIn: parent
							source: trayItem.modelData.icon
							implicitSize: Theme.trayIconSize
						}

						MouseArea {
							id: trayHover
							anchors.fill: parent
							hoverEnabled: true
							acceptedButtons: Qt.LeftButton | Qt.RightButton
							onClicked: function(mouse) {
								if (!trayItem.modelData) return

								if (mouse.button == Qt.LeftButton) {
									if (!trayItem.modelData.onlyMenu) {
										trayItem.modelData.activate()
									}
								}

								if (mouse.button == Qt.RightButton && trayItem.modelData.hasMenu) {
									var point = trayItem.mapToItem(null, Math.round(trayItem.width / 2), trayItem.height)
									trayItem.modelData.display(dropdown, Math.round(point.x), Math.round(point.y))
								}
							}
						}
					}
				}
			}
		}
	}
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import ".."
import "../../constants"

Rectangle {
	id: root
	property bool expanded: false
	property bool hovered: clickArea.containsMouse

	implicitWidth: label.implicitWidth + (BarTheme.widgetPadding * 2)
	implicitHeight: BarTheme.widgetHeight
	radius: Theme.radius
	color: root.expanded
		? Theme.colors.surfaceActive
		: (root.hovered ? Theme.colors.surfaceHover : Theme.colors.surface)
	border.width: Theme.borderSize
	border.color: Theme.colors.border

	Text {
		id: label
		anchors.centerIn: parent
		text: root.expanded ?  "" : ""
		color: root.expanded ? Theme.colors.textOnActive : Theme.colors.text
		font.pixelSize: Theme.font.size
		font.family: Theme.font.family
	}
	MouseArea {
		id: clickArea
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: root.expanded = !root.expanded
	}

	PopupWindow {
		id: dropdown
		anchor.window: QsWindow.window
		visible: root.expanded
		anchor.rect.x: root.mapToItem(QsWindow.window ? QsWindow.window.contentItem : null, 0, 0).x
			+ Math.round((root.width - width) / 2)
		anchor.rect.y: root.mapToItem(QsWindow.window ? QsWindow.window.contentItem : null, 0, 0).y
			+ root.height + BarTheme.popupOffset
		implicitWidth: trayRow.implicitWidth + (BarTheme.widgetPadding * 2)
		implicitHeight: trayRow.implicitHeight + (BarTheme.widgetPadding * 2)
		color: "transparent"

		Rectangle {
			anchors.fill: parent
			radius: Theme.radius
			color: Theme.colors.surface
			border.width: Theme.borderSize
			border.color: Theme.colors.border
			clip: true

			RowLayout {
				id: trayRow
				anchors.centerIn: parent
				spacing: BarTheme.innerSpacing

				Repeater {
					model: SystemTray.items

					Rectangle {
						id: trayItem
						required property var modelData
						property bool hovered: trayHover.containsMouse
						radius: Theme.radiusBg
						color: hovered ? Theme.colors.surfaceHover : "transparent"
						implicitWidth: BarTheme.trayItemSize
						implicitHeight: BarTheme.trayItemSize

						IconImage {
							id: trayIcon
							anchors.centerIn: parent
							source: trayItem.modelData.icon
							implicitSize: BarTheme.trayIconSize
						}

						MouseArea {
							id: trayHover
							anchors.fill: parent
							hoverEnabled: true
							cursorShape: Qt.PointingHandCursor
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

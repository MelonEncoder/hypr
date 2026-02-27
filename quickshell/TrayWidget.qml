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

	function isDirectIconSource(icon: string): bool {
		return icon.indexOf("/") !== -1
			|| icon.indexOf("file:") === 0
			|| icon.indexOf("qrc:") === 0
			|| icon.indexOf("image:") === 0
	}

	function sanitizeIconName(icon: string): string {
		if (!icon) return ""
		var cleaned = icon
		var queryIndex = cleaned.indexOf("?")
		if (queryIndex !== -1) cleaned = cleaned.slice(0, queryIndex)
		if (cleaned === "spotify-linux-32") return "spotify-client"
		if (cleaned === "input-keyboard-symbolic") return "input-keyboard"
		return cleaned
	}

	function iconNameForItem(item: var): string {
		if (!item) return ""
		if (item.icon && item.icon.length > 0) return sanitizeIconName(item.icon)

		var byId = DesktopEntries.byId(item.id || "")
		if (byId && byId.icon && byId.icon.length > 0) return byId.icon
		var byDesktopId = DesktopEntries.byId((item.id || "") + ".desktop")
		if (byDesktopId && byDesktopId.icon && byDesktopId.icon.length > 0) return byDesktopId.icon

		var lookupKey = item.tooltipTitle || item.title || item.id || ""
		var byName = DesktopEntries.heuristicLookup(lookupKey)
		if (byName && byName.icon && byName.icon.length > 0) return byName.icon

		if (item.id && item.id.indexOf(".") !== -1) {
			var shortId = item.id.split(".").pop()
			var byShortId = DesktopEntries.byId(shortId)
			if (byShortId && byShortId.icon && byShortId.icon.length > 0) return byShortId.icon
			var byShortName = DesktopEntries.heuristicLookup(shortId)
			if (byShortName && byShortName.icon && byShortName.icon.length > 0) return byShortName.icon
		}

		var lowered = ((item.id || "") + " " + (item.icon || "")).toLowerCase()
		if (lowered.indexOf("spotify") !== -1) return "spotify-client"

		return ""
	}

	function iconSourceForItem(item: var): string {
		var iconName = sanitizeIconName(iconNameForItem(item))
		if (!iconName || iconName.length === 0) {
			return Quickshell.iconPath("application-x-executable")
		}

		if (isDirectIconSource(iconName)) return iconName

		var resolved = Quickshell.iconPath(iconName, true)
		if (resolved && resolved.length > 0) return resolved

		if (iconName.endsWith("-symbolic")) {
			var nonSymbolic = iconName.slice(0, iconName.length - "-symbolic".length)
			var fallbackResolved = Quickshell.iconPath(nonSymbolic, true)
			if (fallbackResolved && fallbackResolved.length > 0) return fallbackResolved
		}

		return Quickshell.iconPath(iconName, "application-x-executable")
	}

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
					source: root.iconSourceForItem(trayItem.modelData)
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

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Rectangle {
	id: root
	radius: Theme.radius
	color: Theme.widgetBackgroundIdle
	border.width: Theme.borderWidth
	border.color: Theme.surfaceBorder
	implicitWidth: workspaceRow.implicitWidth + Theme.widgetPaddingX
	implicitHeight: Theme.widgetHeight

	function toJapaneseNumber(n: int): string {
		var digits = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
		if (n <= 0) return n.toString()
		if (n <= 10) return digits[n]
		return n.toString()
	}

	function workspaceForId(id: int): var {
		var values = Hyprland.workspaces.values
		for (var i = 0; i < values.length; i++) {
			if (values[i].id === id) return values[i]
		}
		return null
	}

	function focusWorkspace(workspaceId: int): void {
		if (workspaceId <= 0) return
		if (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === workspaceId) return
		Hyprland.dispatch("workspace " + workspaceId)
	}

	RowLayout {
		id: workspaceRow
		anchors.centerIn: parent
		spacing: Theme.innerSpacing
	

		// persistant workspaces
		Repeater {
			model: 5

			Item {
				required property int index
				readonly property int workspaceId: index + 1
				readonly property var workspace: root.workspaceForId(workspaceId)
				readonly property bool hovered: workspaceMouse.containsMouse
				readonly property bool isActive: Hyprland.focusedWorkspace
					&& Hyprland.focusedWorkspace.id === workspaceId
				readonly property bool hasWindows: workspace
					&& workspace.toplevels
					&& workspace.toplevels.values.length > 0

				implicitWidth: label.implicitWidth + Theme.workspaceItemPaddingX
				implicitHeight: Theme.workspaceItemHeight

				Rectangle {
					id: itemBackground
					anchors.fill: parent
					radius: Theme.radiusBg
					color: parent.isActive
						? Theme.widgetBackgroundActive
						: (parent.hovered ? Theme.widgetBackgroundHover : "transparent")
				}

				Text {
					id: label
					anchors.centerIn: parent
					text: root.toJapaneseNumber(parent.workspaceId)
					color: parent.isActive ? Theme.textOnActive : (parent.hasWindows ? Theme.textPrimary : "#7a7a7a")
					font.pixelSize: Theme.fontSize
					font.family: Theme.fontFamily
				}

				MouseArea {
					id: workspaceMouse
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: root.focusWorkspace(parent.workspaceId)
				}
			}
		}
	
		// extra workspaces when active
		Repeater {
			model: Hyprland.workspaces

			Item {
				required property var modelData
				readonly property int workspaceId: modelData ? modelData.id : -1
				readonly property bool hovered: workspaceMouseExtra.containsMouse
				visible: workspaceId > 5 && workspaceId <= 10
				readonly property bool isActive: Hyprland.focusedWorkspace
					&& Hyprland.focusedWorkspace.id === workspaceId
				readonly property bool hasWindows: modelData
					&& modelData.toplevels
					&& modelData.toplevels.values.length > 0

				implicitWidth: label.implicitWidth + Theme.workspaceItemPaddingX
				implicitHeight: Theme.workspaceItemHeight

				Rectangle {
					anchors.fill: parent
					radius: Theme.radiusBg
					color: parent.isActive
						? Theme.widgetBackgroundActive
						: (parent.hovered ? Theme.widgetBackgroundHover : "transparent")
				}

				Text {
					id: label
					anchors.centerIn: parent
					text: root.toJapaneseNumber(parent.workspaceId)
					color: parent.isActive ? Theme.textOnActive : (parent.hasWindows ? Theme.textPrimary : "#7a7a7a")
					font.pixelSize: Theme.fontSize
					font.family: Theme.fontFamily
				}

				MouseArea {
					id: workspaceMouseExtra
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: root.focusWorkspace(parent.workspaceId)
				}
			}
		}
	}
}

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."
import "../../constants"

Rectangle {
	id: root
	radius: Theme.radius
	color: Theme.colors.surface
	border.width: Theme.borderSize
	border.color: Theme.colors.border
	implicitWidth: workspaceRow.implicitWidth
	implicitHeight: BarTheme.widgetHeight

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
		spacing: BarTheme.innerSpacing
	

		// persistant workspaces
		Repeater {
			model: 5

			Item {
				required property int index
				readonly property int workspaceId: index + 1
				readonly property var workspace: root.workspaceForId(workspaceId)
				readonly property bool isActive: Hyprland.focusedWorkspace
					&& Hyprland.focusedWorkspace.id === workspaceId
				readonly property bool hasWindows: workspace
					&& workspace.toplevels
					&& workspace.toplevels.values.length > 0
				readonly property real slotSize: BarTheme.widgetHeight
				readonly property real indicatorHeight: isActive ? slotSize : (hasWindows ? 10 : 4)
				readonly property real indicatorWidth: isActive ? slotSize : indicatorHeight

				implicitWidth: slotSize
				implicitHeight: slotSize

				Rectangle {
					id: itemBackground
					anchors.centerIn: parent
					width: parent.indicatorWidth
					height: parent.indicatorHeight
					radius: parent.isActive ? root.radius : height / 4
	 				color: parent.isActive ? "#ffffff" : (parent.hasWindows ? "#b0b0b0" : "#7a7a7a")
					opacity: 1
				}

				Text {
					anchors.centerIn: parent
					text: root.toJapaneseNumber(parent.workspaceId)
					visible: parent.isActive
					color: "#000000"
					font.pixelSize: Theme.font.size
					font.family: Theme.font.family
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
				visible: workspaceId > 5 && workspaceId <= 10
				readonly property bool isActive: Hyprland.focusedWorkspace
					&& Hyprland.focusedWorkspace.id === workspaceId
				readonly property bool hasWindows: modelData
					&& modelData.toplevels
					&& modelData.toplevels.values.length > 0
				readonly property real slotSize: BarTheme.widgetHeight
				readonly property real indicatorHeight: isActive ? slotSize : (hasWindows ? 12 : 6)
				readonly property real indicatorWidth: isActive ? slotSize : indicatorHeight

				implicitWidth: slotSize
				implicitHeight: slotSize

				Rectangle {
					anchors.centerIn: parent
					width: parent.indicatorWidth
					height: parent.indicatorHeight
					radius: parent.isActive ? root.radius : height / 2
					color: parent.isActive ? "#ffffff" : (parent.hasWindows ? "#b0b0b0" : "#7a7a7a")
					opacity: 1
				}

				Text {
					anchors.centerIn: parent
					text: root.toJapaneseNumber(parent.workspaceId)
					visible: parent.isActive
					color: "#000000"
					font.pixelSize: Theme.font.size
					font.family: Theme.font.family
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

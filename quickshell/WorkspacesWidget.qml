import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

Rectangle {
	id: root
	radius: 5
	color: Colors.surfaceBackground
	border.width: 1
	border.color: Colors.surfaceBorder
	implicitWidth: workspaceRow.implicitWidth + 12
	implicitHeight: workspaceRow.implicitHeight + 8

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
		spacing: 6
	

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

				implicitWidth: label.implicitWidth + 12
				implicitHeight: 20

				Rectangle {
					id: itemBackground
					anchors.fill: parent
					radius: 3
					color: parent.isActive ? Colors.activeBackground : "transparent"
				}

				Text {
					id: label
					anchors.centerIn: parent
					text: root.toJapaneseNumber(parent.workspaceId)
					color: parent.isActive ? Colors.textOnActive : (parent.hasWindows ? Colors.textMuted : Colors.textSubtle)
					font.pixelSize: 12
				}

				MouseArea {
					anchors.fill: parent
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

				implicitWidth: label.implicitWidth + 12
				implicitHeight: 20

				Rectangle {
					anchors.fill: parent
					radius: 3
					color: parent.isActive ? Colors.activeBackground : "transparent"
				}

				Text {
					id: label
					anchors.centerIn: parent
					text: root.toJapaneseNumber(parent.workspaceId)
					color: parent.isActive ? Colors.textOnActive : (parent.hasWindows ? Colors.textMuted : Colors.textSubtle)
					font.pixelSize: 12
				}

				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor
					onClicked: root.focusWorkspace(parent.workspaceId)
				}
			}
		}
	}
}

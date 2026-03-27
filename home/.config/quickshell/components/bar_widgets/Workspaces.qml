pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."

Rectangle {
	id: root
	radius: Theme.radius_normal
	color: Theme.color_surface
	border.width: Theme.border_width
	border.color: Theme.color_border
	implicitWidth: workspaceRow.implicitWidth
	implicitHeight: Theme.bar_widget_height

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
		if (Hyprland.focusedWorkspace && (Hyprland.focusedWorkspace.id === workspaceId)) return
		Hyprland.dispatch("workspace " + workspaceId)
	}

	RowLayout {
		id: workspaceRow
		anchors.centerIn: parent
		spacing: 4

		// persistant workspaces
		Repeater {
			model: 10

			Item {
				required property int index
				readonly property int workspaceId: index + 1
				readonly property var workspace: root.workspaceForId(workspaceId)
				readonly property bool isActive: Hyprland.focusedWorkspace
					&& Hyprland.focusedWorkspace.id === workspaceId
				readonly property bool hasWindows: workspace
					&& workspace.toplevels
					&& workspace.toplevels.values.length > 0
				readonly property real slotSize: Theme.bar_widget_height
				readonly property real indicatorHeight: isActive ? slotSize : (hasWindows ? 9 : 4)
				readonly property real indicatorWidth: isActive ? slotSize : indicatorHeight

				implicitWidth: slotSize
				implicitHeight: slotSize

				visible: index < 5 || isActive || hasWindows

				Rectangle {
					id: itemBackground
					anchors.centerIn: parent
					width: parent.indicatorWidth
					height: parent.indicatorHeight
					radius: parent.isActive ? root.radius : height / 4
	 				color: parent.isActive ? Theme.color_text : (parent.hasWindows ? Theme.workspace_dot_occupied : Theme.workspace_dot_empty)
					opacity: 1

					Behavior on width {
						NumberAnimation {
							duration: Animations.duration_fast
							easing.type: Animations.easing_standard
						}
					}

					Behavior on height {
						NumberAnimation {
							duration: Animations.duration_fast
							easing.type: Animations.easing_standard
						}
					}

					Behavior on radius {
						NumberAnimation {
							duration: Animations.duration_fast
							easing.type: Animations.easing_standard
						}
					}

					Behavior on color {
						ColorAnimation {
							duration: Animations.duration_fast
							easing.type: Animations.easing_standard
						}
					}
				}

				Text {
					anchors.centerIn: parent
					text: root.toJapaneseNumber(parent.workspaceId)
					visible: opacity > 0.01
					opacity: parent.isActive ? 1 : 0
					color: Theme.color_background
					font.pixelSize: Theme.font_size
					font.family: Theme.font_family

					Behavior on opacity {
						NumberAnimation {
							duration: Animations.duration_fast
							easing.type: Animations.easing_standard
						}
					}
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
	}
}

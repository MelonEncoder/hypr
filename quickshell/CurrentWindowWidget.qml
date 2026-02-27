import QtQuick
import Quickshell.Hyprland

Rectangle {
	id: root
	readonly property var focusedWorkspace: Hyprland.focusedWorkspace
	readonly property var activeToplevel: Hyprland.activeToplevel
	readonly property bool focusedWorkspaceHasWindows: focusedWorkspace
		&& focusedWorkspace.toplevels
		&& focusedWorkspace.toplevels.values.length > 0
	readonly property bool activeOnFocusedWorkspace: activeToplevel
		&& activeToplevel.workspace
		&& focusedWorkspace
		&& activeToplevel.workspace.id === focusedWorkspace.id
	readonly property string windowTitle: {
		if (!focusedWorkspaceHasWindows || !activeOnFocusedWorkspace) return "[" + (focusedWorkspace ? focusedWorkspace.id : "?") + "]"

		var appId = activeToplevel.wayland && activeToplevel.wayland.appId ? activeToplevel.wayland.appId : ""
		if (appId.length > 0) return simplifyAppId(appId)

		var title = activeToplevel.title ? activeToplevel.title : ""
		if (title.length > 0) return title

		return "[" + (focusedWorkspace ? focusedWorkspace.id : "?") + "]"
	}

	function simplifyAppId(appId: string): string {
		var simple = appId
		var slash = simple.lastIndexOf("/")
		if (slash >= 0 && slash + 1 < simple.length) simple = simple.slice(slash + 1)

		var dot = simple.lastIndexOf(".")
		if (dot >= 0 && dot + 1 < simple.length) simple = simple.slice(dot + 1)

		simple = simple.replace(/[-_]+/g, " ")
		if (simple.length === 0) return "App"
		return simple.charAt(0).toUpperCase() + simple.slice(1)
	}

	radius: Theme.radius
	color: Theme.widgetBackgroundIdle
	border.width: Theme.borderWidth
	border.color: Theme.surfaceBorder
	implicitWidth: Math.min(420, label.implicitWidth + (Theme.widgetPaddingX + 4))
	implicitHeight: Theme.widgetHeight

	Text {
		id: label
		anchors.verticalCenter: parent.verticalCenter
		anchors.left: parent.left
		anchors.leftMargin: Theme.widgetPaddingY
		anchors.right: parent.right
		anchors.rightMargin: Theme.widgetPaddingY
		text: root.windowTitle
		color: Theme.textPrimary
		font.pixelSize: Theme.fontSize
		font.family: Theme.fontFamily
		elide: Text.ElideRight
	}
}

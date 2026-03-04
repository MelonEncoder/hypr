import QtQuick
import Quickshell.Hyprland
import Quickshell.Widgets
import ".."
import "../../constants"

Rectangle {
	id: root
	readonly property var focusedWorkspace: Hyprland.focusedWorkspace;
	readonly property var activeToplevel: Hyprland.activeToplevel;
	readonly property bool focusedWorkspaceHasWindows: focusedWorkspace
		&& focusedWorkspace.toplevels
		&& focusedWorkspace.toplevels.values.length > 0;
	readonly property bool activeOnFocusedWorkspace: focusedWorkspace
		&& activeToplevel
		&& activeToplevel.workspace.id === focusedWorkspace.id;
	readonly property string windowTitle: {
		if (!focusedWorkspaceHasWindows) 
			return "[" + (focusedWorkspace ? focusedWorkspace.id : "?") + "]";
		if (!activeOnFocusedWorkspace) 
			return "[" + (focusedWorkspace ? focusedWorkspace.id : "?") + "]";

		var appId = activeToplevel.wayland && activeToplevel.wayland.appId ? activeToplevel.wayland.appId : "";
		if (appId.length > 0) 
			return simplifyAppId(appId);

		var title = activeToplevel.title ? activeToplevel.title : "";
		if (title.length > 0) 
			return title;

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
	color: Theme.colors.surface
	border.width: Theme.borderSize
	border.color: Theme.colors.border
	implicitHeight: BarTheme.widgetHeight
	implicitWidth: Math.min(420, label.implicitWidth + (BarTheme.widgetPadding * 2))

	Text {
		id: label
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.leftMargin: BarTheme.widgetPadding
		anchors.rightMargin: BarTheme.widgetPadding
		anchors.verticalCenter: parent.verticalCenter
		text: root.windowTitle
		color: Theme.colors.text
		font.pixelSize: Theme.font.size
		font.family: Theme.font.family
		elide: Text.ElideRight
	}
}

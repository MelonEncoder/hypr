import QtQuick
import Quickshell.Hyprland
import ".."

Rectangle {
    id: root
    readonly property var focusedWorkspace: Hyprland.focusedWorkspace
    readonly property var activeToplevel: Hyprland.activeToplevel
    readonly property bool focusedWorkspaceHasWindows: focusedWorkspace && focusedWorkspace.toplevels && focusedWorkspace.toplevels.values.length > 0
    readonly property bool activeOnFocusedWorkspace: focusedWorkspace && activeToplevel && activeToplevel.workspace.id === focusedWorkspace.id
    readonly property string windowTitle: {
        if (!focusedWorkspaceHasWindows)
            return "[" + (focusedWorkspace ? focusedWorkspace.id : "?") + "]";
        if (!activeOnFocusedWorkspace)
            return "[" + (focusedWorkspace ? focusedWorkspace.id : "?") + "]";

        var appId = activeToplevel.wayland && activeToplevel.wayland.appId ? activeToplevel.wayland.appId : "";
        var title = activeToplevel.title ? activeToplevel.title : "";
        var appName = simplifyAppId(appId);
        var dynamicTitle = simplifyWindowTitle(title, appName);

        if (dynamicTitle.length > 0)
            return dynamicTitle;
        if (appId.length > 0)
            return appName;

        return "[" + (focusedWorkspace ? focusedWorkspace.id : "?") + "]";
    }

    function simplifyWindowTitle(title: string, appName: string): string {
        var raw = title.trim();
        if (raw.length === 0)
            return "";

        var parts = raw.split(/\s[-–—|:]\s/);
        for (var i = 0; i < parts.length; i++) {
            var candidate = parts[i].trim();
            if (candidate.length === 0)
                continue;
            if (appName.length > 0 && candidate.toLowerCase() === appName.toLowerCase())
                continue;
            return normalizeDisplayName(candidate);
        }

        return normalizeDisplayName(raw);
    }

    function normalizeDisplayName(name: string): string {
        var cleaned = name.trim().replace(/[_-]+/g, " ").replace(/\s+/g, " ");
        if (cleaned.length === 0)
            return "";
        if (cleaned.toLowerCase() === "youtube" || cleaned.toLowerCase() === "youtube.com")
            return "YouTube";

        var isAllLower = cleaned === cleaned.toLowerCase();
        var isAllUpper = cleaned === cleaned.toUpperCase();
        if (!isAllLower && !isAllUpper)
            return cleaned;

        var words = cleaned.split(" ");
        for (var i = 0; i < words.length; i++) {
            if (words[i].length === 0)
                continue;
            words[i] = words[i].charAt(0).toUpperCase() + words[i].slice(1).toLowerCase();
        }
        return words.join(" ");
    }

    function simplifyAppId(appId: string): string {
        var simple = appId;
        var slash = simple.lastIndexOf("/");
        if (slash >= 0 && slash + 1 < simple.length)
            simple = simple.slice(slash + 1);

        var dot = simple.lastIndexOf(".");
        if (dot >= 0 && dot + 1 < simple.length)
            simple = simple.slice(dot + 1);

        simple = simple.replace(/[-_]+/g, " ");
        if (simple.length === 0)
            return "App";
        return simple.charAt(0).toUpperCase() + simple.slice(1);
    }

    radius: Theme.radius_normal
    color: Theme.color_surface
    border.width: Theme.border_width
    border.color: Theme.color_border
    implicitHeight: Theme.bar_widget_height
    implicitWidth: Math.min(420, label.implicitWidth + (Theme.bar_widget_padding * 2))

    Text {
        id: label
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.bar_widget_padding
        anchors.rightMargin: Theme.bar_widget_padding
        anchors.verticalCenter: parent.verticalCenter
        text: root.windowTitle
        color: Theme.color_text
        font.pixelSize: Theme.font_size
        font.family: Theme.font_family
        elide: Text.ElideRight
    }
}

pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Scope {
    id: root

    readonly property int window_width: 760
    readonly property int window_height: 640
    readonly property int window_margin: 48
    readonly property int content_padding: 22
    readonly property int section_spacing: 16
    readonly property int search_height: 52
    readonly property int search_padding: 16
    readonly property int list_spacing: 8
    readonly property int row_height: 62
    readonly property int row_radius: Theme.radius_lg
    readonly property int icon_size: 28
    readonly property int icon_wrap_size: 40
    readonly property int border_width: 2

    property bool visible: false
    property string query: ""
    property string launchStatus: ""
    property int selectedIndex: 0
    property var searchInputRef: null
    property var listViewRef: null

    function updateFilteredModel(): void {
        var trimmedQuery = root.query.trim().toLowerCase();
        filteredApps.clear();

        var apps = DesktopEntries.applications.values;
        for (var i = 0; i < apps.length; ++i) {
            var app = apps[i];
            if (!app)
                continue;
            var haystack = ((app.name || "") + " " + (app.genericName || "") + " " + (app.comment || "")).toLowerCase();
            if (trimmedQuery.length > 0 && haystack.indexOf(trimmedQuery) === -1)
                continue;
            filteredApps.append({
                name: app.name || "",
                icon: app.icon || "",
                execString: app.execString || "",
                desktopId: app.id || "",
                genericName: app.genericName || "",
                comment: app.comment || ""
            });
        }

        if (filteredApps.count <= 0) {
            selectedIndex = 0;
            return;
        }

        selectedIndex = Math.max(0, Math.min(selectedIndex, filteredApps.count - 1));
    }

    function clearSearch(): void {
        query = "";
        if (searchInputRef)
            searchInputRef.text = "";
    }

    function toggle(): void {
        visible = !visible;
        if (visible) {
            clearSearch();
            selectedIndex = 0;
            launchStatus = "";
            searchFocusTimer.restart();
            updateFilteredModel();
        } else {
            clearSearch();
            selectedIndex = 0;
        }
    }

    function closeLauncher(): void {
        visible = false;
        clearSearch();
        selectedIndex = 0;
    }

    function moveSelection(delta: int): void {
        if (filteredApps.count <= 0)
            return;
        selectedIndex = Math.max(0, Math.min(filteredApps.count - 1, selectedIndex + delta));
        if (listViewRef)
            listViewRef.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function launchSelected(): void {
        if (filteredApps.count <= 0)
            return;
        var app = filteredApps.get(selectedIndex);
        if (!app || !app.desktopId)
            return;
        var entry = DesktopEntries.byId(app.desktopId);
        if (!entry)
            return;
        launchStatus = "Launching " + app.name;
        entry.execute();
        closeLauncher();
    }

    Connections {
        target: DesktopEntries
        function onApplicationsChanged(): void {
            root.updateFilteredModel();
        }
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "app-launcher"
        description: "Open application launcher"
        triggerDescription: "SUPER+SPACE"
        onPressed: root.toggle()
    }

    ListModel {
        id: filteredApps
    }

    HyprlandFocusGrab {
        active: root.visible
        windows: launcherWindows.instances
        onCleared: root.closeLauncher()
    }

    Timer {
        id: searchFocusTimer
        interval: 20
        repeat: false
        onTriggered: {
            if (root.searchInputRef)
                root.searchInputRef.forceActiveFocus();
        }
    }

    Component.onCompleted: {
        updateFilteredModel();
    }

    Variants {
        id: launcherWindows
        model: root.visible ? Quickshell.screens : []

        PanelWindow {
            id: launcherWindow
            required property var modelData

            screen: modelData
            visible: root.visible
            color: "transparent"
            focusable: root.visible
            exclusiveZone: 0
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }

            implicitWidth: modelData.width
            implicitHeight: modelData.height

            Rectangle {
                anchors.fill: parent
                color: Theme.launcher_overlay
                opacity: root.visible ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_normal
                        easing.type: Animations.easing_standard
                    }
                }
            }

            Rectangle {
                id: panel
                anchors.centerIn: parent
                width: Math.min(root.window_width, parent.width - (root.window_margin * 2))
                height: Math.min(root.window_height, parent.height - (root.window_margin * 2))
                radius: 18
                color: Theme.background
                border.width: root.border_width
                border.color: Theme.color_overlay_light
                opacity: root.visible ? 1 : 0
                scale: root.visible ? 1 : Animations.dropdown_scale_closed
                y: root.visible ? 0 : Animations.dropdown_offset
                z: 1
                focus: root.visible
                clip: true

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_normal
                        easing.type: Animations.easing_standard
                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: Animations.duration_slow
                        easing.type: Animations.easing_emphasized
                    }
                }

                Behavior on y {
                    NumberAnimation {
                        duration: Animations.duration_slow
                        easing.type: Animations.easing_emphasized
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.content_padding
                    spacing: root.section_spacing

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.search_height
                        radius: root.row_radius
                        color: Theme.color_surface
                        border.width: root.border_width
                        border.color: searchInput.activeFocus ? Theme.launcher_search_active_border : Theme.color_border_subtle

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: root.search_padding
                            anchors.rightMargin: root.search_padding
                            spacing: 12

                            Text {
                                text: ""
                                color: Theme.color_text_subtle
                                font.pixelSize: Theme.font_size_2xl
                                font.family: Theme.font_family_icon
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                TextInput {
                                    id: searchInput
                                    Component.onCompleted: root.searchInputRef = searchInput
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    height: Math.max(contentHeight, Theme.font_size_jumbo)
                                    color: Theme.color_text
                                    font.pixelSize: Theme.font_size_xl
                                    font.family: Theme.font_family
                                    selectedTextColor: Theme.color_text
                                    selectionColor: Theme.color_overlay_light
                                    clip: true
                                    selectByMouse: true
                                    text: root.query
                                    onTextChanged: {
                                        root.query = text;
                                        root.selectedIndex = 0;
                                        root.updateFilteredModel();
                                    }
                                    Keys.onDownPressed: function (event) {
                                        root.moveSelection(1);
                                        event.accepted = true;
                                    }
                                    Keys.onUpPressed: function (event) {
                                        root.moveSelection(-1);
                                        event.accepted = true;
                                    }
                                    Keys.onEscapePressed: function (event) {
                                        root.closeLauncher();
                                        event.accepted = true;
                                    }
                                    Keys.onPressed: function (event) {
                                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                            root.launchSelected();
                                            event.accepted = true;
                                        }
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: searchInput.text.length === 0
                                    text: "Search apps"
                                    color: Theme.color_text_subtle
                                    font.pixelSize: Theme.font_size_xl
                                    font.family: Theme.font_family
                                }
                            }
                        }
                    }

                    Text {
                        visible: root.launchStatus.length > 0
                        text: root.launchStatus
                        color: Theme.color_text_muted
                        font.pixelSize: Theme.font_size
                        font.family: Theme.font_family
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: root.row_radius
                        color: "transparent"
                        border.width: 0
                        clip: true

                        ListView {
                            id: listView
                            Component.onCompleted: root.listViewRef = listView
                            anchors.fill: parent
                            model: filteredApps
                            spacing: root.list_spacing
                            clip: true
                            currentIndex: root.selectedIndex
                            boundsBehavior: Flickable.StopAtBounds

                            delegate: Rectangle {
                                id: row
                                required property int index
                                required property string name
                                required property string icon
                                required property string execString
                                required property string desktopId
                                required property string genericName
                                required property string comment

                                // Icon name to look up: explicit if set, otherwise try
                                // the desktop ID (strip .desktop) then name as kebab-case.
                                readonly property string effectiveIconName: {
                                    if (icon.length > 0)
                                        return icon;
                                    var idBase = desktopId.replace(/\.desktop$/i, "");
                                    if (idBase.length > 0)
                                        return idBase;
                                    return name.toLowerCase().replace(/\s+/g, "-");
                                }

                                // Full image:// URL. Only explicit icons get the
                                // application-x-executable fallback; derived ones do not
                                // so that the canvas probe can detect a failed lookup.
                                readonly property string iconSource: effectiveIconName.length > 0 ? ("image://icon/" + effectiveIconName + (icon.length > 0 ? "?fallback=application-x-executable" : "")) : ""

                                // Whether the resolved icon is valid (not the checkerboard).
                                // Explicit icons are always valid (fallback guarantees a result).
                                // Derived icons start false and are confirmed by the canvas probe.
                                property bool iconValid: icon.length > 0

                                // Hidden 8×8 probe image — only active for derived icon lookups
                                Image {
                                    id: iconProbe
                                    visible: false
                                    width: 8
                                    height: 8
                                    source: row.icon.length === 0 && row.iconSource.length > 0 ? row.iconSource : ""
                                    onStatusChanged: if (status === Image.Ready)
                                        probeCanvas.requestPaint()
                                }

                                // Sample the four quadrant-centre pixels to detect the
                                // purple (#d900d8) / black checkerboard drawn by Quickshell
                                // when QIcon::fromTheme() returns a null icon.
                                Canvas {
                                    id: probeCanvas
                                    visible: false
                                    width: 8
                                    height: 8
                                    onPaint: {
                                        var ctx = getContext("2d");
                                        ctx.drawImage(row.iconSource, 0, 0, 8, 8);
                                        function isBlack(d) {
                                            return d[0] < 10 && d[1] < 10 && d[2] < 10;
                                        }
                                        function isPurple(d) {
                                            return d[0] > 200 && d[1] < 10 && d[2] > 200;
                                        }
                                        var tl = ctx.getImageData(1, 1, 1, 1).data;
                                        var tr = ctx.getImageData(5, 1, 1, 1).data;
                                        var bl = ctx.getImageData(1, 5, 1, 1).data;
                                        var br = ctx.getImageData(5, 5, 1, 1).data;
                                        var isCheckerboard = (isBlack(tl) && isPurple(tr) && isPurple(bl) && isBlack(br)) || (isPurple(tl) && isBlack(tr) && isBlack(bl) && isPurple(br));
                                        row.iconValid = !isCheckerboard;
                                    }
                                }

                                width: listView.width
                                height: root.row_height
                                radius: root.row_radius
                                color: root.selectedIndex === index ? Theme.launcher_row_selected : (rowMouse.containsMouse ? Theme.launcher_row_hover : Theme.launcher_row)

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Animations.duration_hover
                                        easing.type: Animations.easing_standard
                                    }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    spacing: 14

                                    Rectangle {
                                        Layout.alignment: Qt.AlignVCenter
                                        Layout.preferredWidth: root.icon_wrap_size
                                        Layout.preferredHeight: root.icon_wrap_size
                                        radius: 12
                                        color: Theme.launcher_icon_background

                                        IconImage {
                                            anchors.centerIn: parent
                                            width: root.icon_size
                                            height: root.icon_size
                                            visible: row.iconValid
                                            source: row.iconSource
                                            asynchronous: true
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: !row.iconValid
                                            text: row.name.length > 0 ? row.name.charAt(0).toUpperCase() : "?"
                                            color: Theme.color_text
                                            font.pixelSize: Theme.font_size_xl
                                            font.family: Theme.font_family
                                            font.bold: true
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 2

                                        Text {
                                            text: row.name
                                            color: Theme.color_text
                                            font.pixelSize: Theme.font_size_title
                                            font.family: Theme.font_family
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: row.genericName.length > 0 ? row.genericName : row.comment
                                            visible: text.length > 0
                                            color: Theme.color_text_subtle
                                            font.pixelSize: Theme.font_size
                                            font.family: Theme.font_family
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    Text {
                                        text: row.execString
                                        color: Theme.color_text_muted
                                        font.pixelSize: Theme.font_size_sm
                                        font.family: Theme.font_family
                                        elide: Text.ElideLeft
                                        horizontalAlignment: Text.AlignRight
                                        Layout.preferredWidth: Math.min(220, implicitWidth)
                                    }
                                }

                                MouseArea {
                                    id: rowMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: root.selectedIndex = row.index
                                    onClicked: {
                                        root.selectedIndex = row.index;
                                        root.launchSelected();
                                    }
                                }
                            }

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AsNeeded
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: filteredApps.count === 0
                            text: DesktopEntries.applications.values.length === 0 ? "Loading applications..." : "No matching applications"
                            color: Theme.color_text_subtle
                            font.pixelSize: Theme.font_size_icon
                            font.family: Theme.font_family
                        }
                    }
                }

                Keys.onDownPressed: function (event) {
                    root.moveSelection(1);
                    event.accepted = true;
                }

                Keys.onUpPressed: function (event) {
                    root.moveSelection(-1);
                    event.accepted = true;
                }

                Keys.onPressed: function (event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.launchSelected();
                        event.accepted = true;
                    }
                }

                Keys.onEscapePressed: function (event) {
                    root.closeLauncher();
                    event.accepted = true;
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                z: 0
                onClicked: root.closeLauncher()
            }
        }
    }
}

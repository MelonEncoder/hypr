pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import "."

Scope {
    id: root

    readonly property string wallpaperDirectory: Qt.resolvedUrl("../wallpapers").toString().replace(/^file:\/\//, "")
    readonly property int windowContentWidth: (root.visible_preview_count * root.preview_slot_width) + ((root.visible_preview_count - 1) * root.preview_spacing) + (root.content_padding * 2)
    readonly property int carouselLoopCount: 200
    readonly property int virtualWallpaperCount: wallpaperModel.count > 0 ? wallpaperModel.count * carouselLoopCount : 0
    property string currentWallpaper: Theme.wallpaper === "random" ? "" : Theme.wallpaper
    property bool pendingRandom: Theme.wallpaper === "random"
    property bool selectorVisible: false
    property int selectedIndex: 0
    property int carouselIndex: 0
    property string statusText: ""

    Component.onCompleted: {
        if (pendingRandom)
            refreshWallpapers();
    }

    readonly property int window_margin: 24
    readonly property int content_padding: 8
    readonly property int content_spacing: 10
    readonly property int visible_preview_count: 3
    readonly property int preview_spacing: 12
    readonly property int preview_width: 345
    readonly property int preview_height: 230
    readonly property real selected_preview_scale: 1.16
    readonly property real inactive_preview_scale: 1 / selected_preview_scale
    readonly property int selected_preview_width: Math.round(preview_width * selected_preview_scale)
    readonly property int selected_preview_height: Math.round(preview_height * selected_preview_scale)
    readonly property int preview_slot_width: selected_preview_width
    readonly property int preview_slot_height: selected_preview_height
    readonly property int list_surface_height: preview_slot_height + (content_padding * 2)
    readonly property int preview_margin: 6
    readonly property int caption_height: 28
    readonly property int caption_padding: 8
    readonly property int window_radius: 18
    readonly property int preview_radius: 12
    readonly property int caption_radius: 0
    readonly property int window_border_width: 2
    readonly property int selected_border_width: 2
    readonly property int default_border_width: 0

    function wrappedIndex(index: int): int {
        if (wallpaperModel.count <= 0)
            return 0;
        var wrapped = index % wallpaperModel.count;
        return wrapped < 0 ? wrapped + wallpaperModel.count : wrapped;
    }

    function baseCarouselIndex(): int {
        if (wallpaperModel.count <= 0)
            return 0;
        return Math.floor(carouselLoopCount / 2) * wallpaperModel.count;
    }

    function recenterCarousel(): void {
        if (wallpaperModel.count <= 0) {
            carouselIndex = 0;
            return;
        }

        carouselIndex = baseCarouselIndex() + wrappedIndex(carouselIndex);
    }

    function refreshWallpapers(): void {
        wallpaperScan.running = false;
        wallpaperScan.exec(["bash", "-lc", "find -L \"" + root.wallpaperDirectory + "\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \\) -printf '%f\\n' | sort"]);
    }

    function clampSelection(): void {
        if (wallpaperModel.count <= 0) {
            selectedIndex = 0;
            carouselIndex = 0;
            return;
        }

        selectedIndex = wrappedIndex(selectedIndex);
    }

    function toggleSelector(): void {
        selectorVisible = !selectorVisible;
        statusText = "";
        refreshWallpapers();
        clampSelection();
    }

    function moveSelection(delta: int): void {
        if (wallpaperModel.count <= 0)
            return;
        carouselIndex += delta;
        selectedIndex = wrappedIndex(carouselIndex);
        if (carouselIndex < wallpaperModel.count || carouselIndex >= (virtualWallpaperCount - wallpaperModel.count)) {
            recenterCarousel();
        }
    }

    function closeSelector(): void {
        selectorVisible = false;
        statusText = "";
    }

    function selectedWallpaperName(): string {
        if (wallpaperModel.count <= 0)
            return "";
        var selectedWallpaper = wallpaperModel.get(selectedIndex);
        return selectedWallpaper && selectedWallpaper.fileName ? selectedWallpaper.fileName : "";
    }

    function applySelectedWallpaper(): void {
        var name = selectedWallpaperName();
        if (name.length === 0) {
            statusText = "No wallpaper selected";
            return;
        }

        root.currentWallpaper = name;
        statusText = "Applied " + name;
        selectorVisible = false;
    }

    GlobalShortcut {
        appid: "quickshell"
        name: "wallpaper-selector"
        description: "Open wallpaper selector"
        triggerDescription: "SUPER+SHIFT+W"
        onPressed: root.toggleSelector()
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData

            screen: modelData
            color: Theme.color_background
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Background

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            Image {
                anchors.fill: parent
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                source: root.currentWallpaper.length > 0 ? Qt.resolvedUrl("../wallpapers/" + root.currentWallpaper) : ""
            }
        }
    }

    ListModel {
        id: wallpaperModel
    }

    StdioCollector {
        id: wallpaperScanOut
        waitForEnd: true
        onStreamFinished: {
            wallpaperModel.clear();

            var raw = text.trim();
            if (raw.length === 0) {
                root.statusText = "No wallpapers found in " + root.wallpaperDirectory;
                root.clampSelection();
                return;
            }

            var lines = raw.split("\n");
            for (var i = 0; i < lines.length; i++) {
                var fileName = lines[i].trim();
                if (fileName.length === 0)
                    continue;
                wallpaperModel.append({
                    fileName: fileName
                });
            }

            if (wallpaperModel.count > 0 && root.statusText.indexOf("No wallpapers found") === 0) {
                root.statusText = "";
            }

            if (root.pendingRandom && wallpaperModel.count > 0) {
                root.pendingRandom = false;
                root.currentWallpaper = wallpaperModel.get(Math.floor(Math.random() * wallpaperModel.count)).fileName;
                return;
            }

            root.clampSelection();
            root.recenterCarousel();
        }
    }

    Process {
        id: wallpaperScan
        stdout: wallpaperScanOut
    }

    HyprlandFocusGrab {
        active: root.selectorVisible
        windows: selectorWindows.instances
        onCleared: root.closeSelector()
    }

    Variants {
        id: selectorWindows
        model: root.selectorVisible ? Quickshell.screens : []

        PanelWindow {
            id: selectorWindow
            required property var modelData

            visible: root.selectorVisible
            screen: modelData
            color: "transparent"
            focusable: root.selectorVisible
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
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(root.windowContentWidth, parent.width - (root.window_margin * 2))
                implicitHeight: root.list_surface_height
                radius: root.window_radius
                color: Theme.color_background
                border.width: root.window_border_width
                border.color: Theme.wallpaper_window_border

                Rectangle {
                    id: listSurface
                    anchors.centerIn: parent
                    width: parent.width
                    height: root.list_surface_height
                    radius: root.window_radius
                    color: "transparent"
                    border.width: 0
                    clip: false

                    ListView {
                        id: listView
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: root.content_padding
                        anchors.rightMargin: root.content_padding
                        height: root.preview_slot_height
                        model: root.virtualWallpaperCount
                        orientation: ListView.Horizontal
                        spacing: root.preview_spacing
                        snapMode: ListView.SnapToItem
                        clip: false
                        currentIndex: root.carouselIndex
                        boundsBehavior: Flickable.StopAtBounds

                        onCurrentIndexChanged: {
                            if (currentIndex < 0 || wallpaperModel.count <= 0)
                                return;
                            root.carouselIndex = currentIndex;
                            root.selectedIndex = root.wrappedIndex(currentIndex);
                            if (currentIndex < wallpaperModel.count || currentIndex >= (root.virtualWallpaperCount - wallpaperModel.count)) {
                                root.recenterCarousel();
                                positionViewAtIndex(root.carouselIndex, ListView.Center);
                            }
                        }

                        Component.onCompleted: positionViewAtIndex(root.carouselIndex, ListView.Center)

                        Connections {
                            target: root
                            function onCarouselIndexChanged() {
                                listView.positionViewAtIndex(root.carouselIndex, ListView.Center);
                            }
                        }

                        delegate: Item {
                            id: wallpaper
                            required property int index
                            readonly property int wallpaperIndex: root.wrappedIndex(index)
                            readonly property var wallpaperItem: wallpaperModel.count > 0 ? wallpaperModel.get(wallpaperIndex) : null
                            readonly property string fileName: wallpaperItem && wallpaperItem.fileName ? wallpaperItem.fileName : ""

                            readonly property bool selected: root.selectedIndex === wallpaperIndex

                            width: root.preview_slot_width
                            height: root.preview_slot_height

                            Rectangle {
                                anchors.centerIn: parent
                                width: root.selected_preview_width
                                height: root.selected_preview_height
                                radius: root.preview_radius
                                color: wallpaper.selected ? Theme.color_overlay_light : Theme.color_overlay_dark
                                border.width: wallpaper.selected ? root.selected_border_width : root.default_border_width
                                border.color: wallpaper.selected ? Theme.color_text : Theme.color_border_subtle
                                z: wallpaper.selected ? 1 : 0
                                scale: wallpaper.selected ? 1 : root.inactive_preview_scale
                                transformOrigin: Item.Bottom

                                Behavior on scale {
                                    enabled: !wallpaper.selected
                                    NumberAnimation {
                                        duration: Animations.duration_slow
                                        easing.type: Animations.easing_emphasized
                                    }
                                }

                                Image {
                                    anchors.fill: parent
                                    anchors.margins: root.preview_margin
                                    source: Qt.resolvedUrl("../wallpapers/" + wallpaper.fileName)
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: false
                                    clip: true
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: root.preview_margin
                                    height: root.caption_height
                                    radius: root.caption_radius
                                    color: Theme.wallpaper_caption

                                    Text {
                                        anchors.fill: parent
                                        anchors.leftMargin: root.caption_padding
                                        anchors.rightMargin: root.caption_padding
                                        text: wallpaper.fileName
                                        color: Theme.color_text
                                        font.pixelSize: Theme.font_size
                                        font.family: Theme.font_family
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.carouselIndex = wallpaper.index;
                                    root.selectedIndex = wallpaper.wallpaperIndex;
                                }
                                onDoubleClicked: {
                                    root.carouselIndex = wallpaper.index;
                                    root.selectedIndex = wallpaper.wallpaperIndex;
                                    root.applySelectedWallpaper();
                                }
                            }
                        }
                    }
                }

                Keys.onLeftPressed: function (event) {
                    root.moveSelection(-1);
                    event.accepted = true;
                }

                Keys.onRightPressed: function (event) {
                    root.moveSelection(1);
                    event.accepted = true;
                }

                Keys.onPressed: function (event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.applySelectedWallpaper();
                        event.accepted = true;
                    }
                }

                Keys.onEscapePressed: function (event) {
                    root.closeSelector();
                    event.accepted = true;
                }

                focus: root.selectorVisible
            }
        }
    }
}

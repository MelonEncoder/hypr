import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets
import ".."

Item {
    id: root
    property var currentPlayer: null
    property real displayPosition: 0
    property bool expanded: false
    property bool hovered: headerMouse.containsMouse
    // Modes: "auto" (browser => player name, media apps => track), "player", "media"
    property string label_mode: "auto"
    property var service_map: ({
            youtube: {
                icon: "󰗃",
                name: "YouTube",
                type: "site"
            },
            twitch: {
                icon: "󰕃",
                name: "Twitch",
                type: "site"
            },
            netflix: {
                icon: "󰝆",
                name: "Netflix",
                type: "site"
            },
            nebula: {
                icon: "",
                name: "Nebula",
                type: "site"
            },
            hulu: {
                icon: "󰠩",
                name: "Hulu",
                type: "site"
            },
            disneyplus: {
                icon: "󰨜",
                name: "Disney+",
                type: "site"
            },
            primevideo: {
                icon: "",
                name: "Prime Video",
                type: "site"
            },
            max: {
                icon: "󰨜",
                name: "Max",
                type: "site"
            },
            spotify: {
                icon: "󰓇",
                name: "Spotify",
                type: "media"
            },
            mpv: {
                icon: "󰐹",
                name: "mpv",
                type: "media"
            },
            vlc: {
                icon: "󰕼",
                name: "VLC",
                type: "media"
            },
            steam: {
                icon: "󰓓",
                name: "Steam",
                type: "media"
            },
            firefox: {
                icon: "󰈹",
                name: "Firefox",
                type: "browser"
            },
            zen: {
                icon: "󰈹",
                name: "Zen",
                type: "browser"
            },
            librewolf: {
                icon: "󰈹",
                name: "LibreWolf",
                type: "browser"
            },
            floorp: {
                icon: "󰈹",
                name: "Floorp",
                type: "browser"
            },
            waterfox: {
                icon: "󰈹",
                name: "Waterfox",
                type: "browser"
            },
            chromium: {
                icon: "",
                name: "Chromium",
                type: "browser"
            },
            chrome: {
                icon: "",
                name: "Chrome",
                type: "browser"
            },
            "google chrome": {
                icon: "",
                name: "Chrome",
                type: "browser"
            },
            brave: {
                icon: "",
                name: "Brave",
                type: "browser"
            },
            vivaldi: {
                icon: "",
                name: "Vivaldi",
                type: "browser"
            },
            edge: {
                icon: "󰇩",
                name: "Edge",
                type: "browser"
            },
            "microsoft edge": {
                icon: "󰇩",
                name: "Edge",
                type: "browser"
            },
            opera: {
                icon: "",
                name: "Opera",
                type: "browser"
            },
            epiphany: {
                icon: "󰖟",
                name: "Epiphany",
                type: "browser"
            },
            qutebrowser: {
                icon: "",
                name: "Qutebrowser",
                type: "browser"
            }
        })

    implicitWidth: header.implicitWidth
    implicitHeight: Theme.bar_widget_height
    visible: !!root.currentPlayer

    function normalizeTime(value: real): real {
        // Some backends expose MPRIS time in microseconds.
        return value > 100000 ? value / 1000000 : value;
    }

    function formatTime(seconds: real): string {
        var s = Math.max(0, Math.floor(seconds));
        var m = Math.floor(s / 60);
        var r = s % 60;
        return m.toString() + ":" + (r < 10 ? "0" : "") + r.toString();
    }

    function mediaLabel(player: var): string {
        if (!player)
            return "No media";
        var title = player.trackTitle || "";
        var artist = player.trackArtist || player.trackArtists || "";
        if (title.length > 0 && artist.length > 0)
            return artist + "  -  " + title;
        if (title.length > 0)
            return title;
        if (artist.length > 0)
            return artist;
        return player.identity || "Unknown";
    }

    function serviceForPlayer(player: var): var {
        if (!player)
            return null;

        var key = ((player.desktopEntry || "") + " " + (player.identity || "")).toLowerCase();
        var keys = Object.keys(root.service_map);
        for (var i = 0; i < keys.length; i++) {
            var serviceKey = keys[i];
            if (key.indexOf(serviceKey) >= 0) {
                return root.service_map[serviceKey];
            }
        }

        return {
            icon: "󰎆",
            name: (player.identity && player.identity.length > 0) ? player.identity : "Media",
            type: "media"
        };
    }

    function browserSiteForPlayer(player: var): var {
        if (!player)
            return null;

        var service = root.serviceForPlayer(player);
        if (!service || service.type !== "browser")
            return null;

        var search = ((player.trackTitle || "") + " " + (player.trackArtist || "") + " " + (player.trackArtists || "") + " " + (player.identity || "")).toLowerCase();

        if (search.indexOf("youtube") >= 0 || search.indexOf("youtu.be") >= 0) {
            return root.service_map.youtube;
        }
        if (search.indexOf("twitch") >= 0 || search.indexOf("twitch.tv") >= 0) {
            return root.service_map.twitch;
        }
        if (search.indexOf("netflix") >= 0 || search.indexOf("netflix.com") >= 0) {
            return root.service_map.netflix;
        }
        if (search.indexOf("nebula") >= 0 || search.indexOf("nebula.tv") >= 0) {
            return root.service_map.nebula;
        }
        if (search.indexOf("hulu") >= 0 || search.indexOf("hulu.com") >= 0) {
            return root.service_map.hulu;
        }
        if (search.indexOf("disney+") >= 0 || search.indexOf("disneyplus") >= 0 || search.indexOf("disneyplus.com") >= 0) {
            return root.service_map.disneyplus;
        }
        if (search.indexOf("prime video") >= 0 || search.indexOf("primevideo") >= 0 || search.indexOf("amazon.com") >= 0) {
            return root.service_map.primevideo;
        }
        if (search.indexOf(" max ") >= 0 || search.indexOf("max.com") >= 0 || search.indexOf("hbo max") >= 0) {
            return root.service_map.max;
        }

        return null;
    }

    function appGlyph(player: var): string {
        var site = root.browserSiteForPlayer(player);
        if (site)
            return site.icon;

        var service = root.serviceForPlayer(player);
        return service ? service.icon : "󰎆";
    }

    function playerLabel(player: var): string {
        if (!player)
            return "No media";
        var service = root.serviceForPlayer(player);
        if (service && service.name)
            return service.name;
        return player.identity || "Unknown";
    }

    function displayLabel(player: var): string {
        if (!player)
            return "No media";

        if (root.label_mode === "player")
            return root.playerLabel(player);
        if (root.label_mode === "media")
            return root.mediaLabel(player);

        var site = root.browserSiteForPlayer(player);
        if (site && site.name)
            return site.name;

        var service = root.serviceForPlayer(player);
        if (service && service.type === "browser")
            return root.playerLabel(player);
        return root.mediaLabel(player);
    }

    function pickPlayer(): var {
        var values = Mpris.players && Mpris.players.values ? Mpris.players.values : [];
        if (!values || values.length === 0)
            return null;

        var best = null;
        var bestScore = -1;
        for (var i = 0; i < values.length; i++) {
            var player = values[i];
            var service = root.serviceForPlayer(player);
            var isBrowser = service && service.type === "browser";
            var isPlaying = !!player.isPlaying;
            var hasMediaInfo = ((player.trackTitle || "").length > 0) || ((player.trackArtist || "").length > 0);

            // Priority:
            // 1) Playing native media apps (mpv/spotify/etc)
            // 2) Playing browser sessions
            // 3) Paused native media apps
            // 4) Paused browser sessions
            var score = 0;
            if (isPlaying && !isBrowser)
                score = 400;
            else if (isPlaying && isBrowser)
                score = 300;
            else if (!isPlaying && !isBrowser)
                score = 200;
            else
                score = 100;

            if (hasMediaInfo)
                score += 10;

            if (score > bestScore) {
                best = player;
                bestScore = score;
            }
        }
        return best;
    }

    function refreshPlayer(): void {
        root.currentPlayer = pickPlayer();
        if (!root.currentPlayer) {
            root.displayPosition = 0;
            return;
        }

        if (!root.currentPlayer.isPlaying) {
            root.displayPosition = normalizeTime(root.currentPlayer.position);
        }
    }

    function toggleCurrentPlayer(): void {
        var player = root.currentPlayer;
        if (!player || !player.canControl)
            return;
        if (player.canTogglePlaying) {
            player.togglePlaying();
            return;
        }

        if (player.isPlaying && player.canPause) {
            player.pause();
            return;
        }

        if (!player.isPlaying && player.canPlay) {
            player.play();
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.refreshPlayer();
            if (root.currentPlayer && root.currentPlayer.isPlaying) {
                root.displayPosition = root.normalizeTime(root.currentPlayer.position);
            }
        }
    }

    Component.onCompleted: refreshPlayer()

    // ── Bar widget ─────────────────────────────────────────────────────────────

    ClippingRectangle {
        id: header
        radius: Theme.radius_normal
        color: headerMouse.pressed ? Theme.color_surface_pressed : ((root.hovered || root.expanded) ? Theme.color_surface_hover : Theme.color_surface)
        border.width: Theme.border_width
        border.color: Theme.color_border
        implicitHeight: Theme.bar_widget_height
        clip: true

        // Collapsed: padding + icon + padding
        // Expanded:  padding + icon + padding + label + padding
        // Label x = collapsedWidth, so it is perfectly clipped when not shown
        implicitWidth: Theme.bar_widget_padding + glyphText.implicitWidth + Theme.bar_widget_padding + (root.hovered || root.expanded ? Math.min(labelText.implicitWidth, 140) + Theme.bar_widget_padding : 0)

        Behavior on color {
            ColorAnimation {
                duration: Animations.duration_hover
                easing.type: Animations.easing_standard
            }
        }

        Behavior on implicitWidth {
            NumberAnimation {
                duration: Animations.duration_normal
                easing.type: Animations.easing_emphasized
            }
        }

        Text {
            id: glyphText
            anchors.left: parent.left
            anchors.leftMargin: Theme.bar_widget_padding
            anchors.verticalCenter: parent.verticalCenter
            text: root.appGlyph(root.currentPlayer)
            color: Theme.color_text
            font.pixelSize: Theme.font_size_icon
            font.family: Theme.font_family_icon
        }

        Text {
            id: labelText
            anchors.left: glyphText.right
            anchors.leftMargin: Theme.bar_widget_padding
            anchors.verticalCenter: parent.verticalCenter
            text: root.playerLabel(root.currentPlayer)
            color: Theme.color_text
            font.pixelSize: Theme.font_size
            font.family: Theme.font_family
        }

        MouseArea {
            id: headerMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    // ── Media player popup ─────────────────────────────────────────────────────

    PopupWindow {
        id: dropdown
        anchor.item: root
        visible: root.expanded
        implicitWidth: dropdown.screen.width
        implicitHeight: dropdown.screen.height
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            MouseArea {
                anchors.fill: parent
                enabled: root.expanded
                onClicked: root.expanded = false
            }
        }

        Rectangle {
            id: popupPanel
            readonly property int contentWidth: 240

            x: root.mapToGlobal(root.width / 2, 0).x - width / 2
            y: Theme.bar_widget_height + (Theme.bar_padding * 2)
            width: contentWidth + (Theme.bar_widget_padding * 2)
            height: popupColumn.implicitHeight + (Theme.bar_widget_padding * 2)
            radius: Theme.radius_background
            color: Theme.color_background
            border.width: Theme.border_width
            border.color: Theme.color_border
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : Animations.dropdown_scale_closed
            transformOrigin: Item.Top

            Behavior on opacity {
                NumberAnimation {
                    duration: Animations.duration_dropdown
                    easing.type: Animations.easing_emphasized
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: Animations.duration_dropdown
                    easing.type: Animations.easing_emphasized
                }
            }

            // Absorb clicks so the backdrop doesn't fire through the panel
            MouseArea {
                anchors.fill: parent
            }

            Column {
                id: popupColumn
                x: Theme.bar_widget_padding
                y: Theme.bar_widget_padding
                width: popupPanel.contentWidth
                spacing: 8

                // ── Header label ───────────────────────────────────────────────

                Text {
                    text: "Media"
                    color: Theme.color_text_subtle
                    font.pixelSize: Theme.font_size_xs
                    font.family: Theme.font_family
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 1
                    leftPadding: 2
                    bottomPadding: 2
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.color_border_subtle
                }

                // ── Album art ──────────────────────────────────────────────────

                Rectangle {
                    width: parent.width
                    height: (artImage.status === Image.Ready && artImage.sourceSize.width > 0)
                        ? Math.round(parent.width * artImage.sourceSize.height / artImage.sourceSize.width)
                        : parent.width
                    radius: Theme.radius_normal
                    color: Theme.color_surface
                    clip: true

                    Image {
                        id: artImage
                        anchors.fill: parent
                        source: root.currentPlayer && root.currentPlayer.trackArtUrl ? root.currentPlayer.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.appGlyph(root.currentPlayer)
                        color: Theme.color_text_muted
                        font.pixelSize: Theme.font_size_jumbo
                        font.family: Theme.font_family_icon
                        visible: artImage.status !== Image.Ready
                    }
                }

                // ── Track info ─────────────────────────────────────────────────

                Column {
                    width: parent.width
                    spacing: 2
                    leftPadding: 2

                    Text {
                        width: parent.width - parent.leftPadding
                        text: root.currentPlayer ? (root.currentPlayer.trackTitle || root.playerLabel(root.currentPlayer)) : "No media"
                        color: Theme.color_text
                        font.pixelSize: Theme.font_size
                        font.family: Theme.font_family
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width - parent.leftPadding
                        text: root.currentPlayer ? (root.currentPlayer.trackArtist || root.currentPlayer.trackArtists || "") : ""
                        color: Theme.color_text_muted
                        font.pixelSize: Theme.font_size_sm
                        font.family: Theme.font_family
                        elide: Text.ElideRight
                        visible: text.length > 0
                    }
                }

                // ── Progress bar + timestamps ──────────────────────────────────

                Column {
                    width: parent.width
                    spacing: 4

                    Rectangle {
                        width: parent.width
                        height: 3
                        radius: 2
                        color: Theme.color_surface

                        Rectangle {
                            width: {
                                if (!root.currentPlayer)
                                    return 0;
                                var len = root.normalizeTime(root.currentPlayer.length);
                                if (len <= 0)
                                    return 0;
                                return Math.min(1.0, root.displayPosition / len) * parent.width;
                            }
                            height: parent.height
                            radius: parent.radius
                            color: Theme.color_text
                        }
                    }

                    RowLayout {
                        width: parent.width

                        Text {
                            text: root.formatTime(root.displayPosition)
                            color: Theme.color_text_muted
                            font.pixelSize: Theme.font_size_xs
                            font.family: Theme.font_family
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.currentPlayer ? root.formatTime(root.normalizeTime(root.currentPlayer.length)) : "0:00"
                            color: Theme.color_text_muted
                            font.pixelSize: Theme.font_size_xs
                            font.family: Theme.font_family
                        }
                    }
                }

                // ── Playback controls ──────────────────────────────────────────

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    bottomPadding: 2

                    // Previous
                    Rectangle {
                        width: 32
                        height: 32
                        radius: Theme.radius_normal
                        color: prevMouse.pressed ? Theme.color_surface_pressed : (prevMouse.containsMouse ? Theme.color_surface_hover : Theme.color_surface)

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easing_standard
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰒮"
                            color: (root.currentPlayer && root.currentPlayer.canGoPrevious) ? Theme.color_text : Theme.color_text_subtle
                            font.pixelSize: Theme.font_size_icon
                            font.family: Theme.font_family_icon
                        }

                        MouseArea {
                            id: prevMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: !!root.currentPlayer && root.currentPlayer.canGoPrevious
                            onClicked: root.currentPlayer.previous()
                        }
                    }

                    // Play / Pause
                    Rectangle {
                        width: 36
                        height: 36
                        radius: Theme.radius_normal
                        color: playMouse.pressed ? Theme.color_surface_pressed : (playMouse.containsMouse ? Theme.color_surface_hover : Theme.color_surface)
                        border.width: Theme.border_width
                        border.color: Theme.color_border

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easing_standard
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: (root.currentPlayer && root.currentPlayer.isPlaying) ? "󰏤" : "󰐊"
                            color: Theme.color_text
                            font.pixelSize: Theme.font_size_icon
                            font.family: Theme.font_family_icon
                        }

                        MouseArea {
                            id: playMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleCurrentPlayer()
                        }
                    }

                    // Next
                    Rectangle {
                        width: 32
                        height: 32
                        radius: Theme.radius_normal
                        color: nextMouse.pressed ? Theme.color_surface_pressed : (nextMouse.containsMouse ? Theme.color_surface_hover : Theme.color_surface)

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easing_standard
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰒭"
                            color: (root.currentPlayer && root.currentPlayer.canGoNext) ? Theme.color_text : Theme.color_text_subtle
                            font.pixelSize: Theme.font_size_icon
                            font.family: Theme.font_family_icon
                        }

                        MouseArea {
                            id: nextMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: !!root.currentPlayer && root.currentPlayer.canGoNext
                            onClicked: root.currentPlayer.next()
                        }
                    }
                }
            }
        }
    }
}

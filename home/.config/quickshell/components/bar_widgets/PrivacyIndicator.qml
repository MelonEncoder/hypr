import QtQuick
import Quickshell.Io
import ".."

Rectangle {
    id: root
    property bool micInUse: false
    property bool screenInUse: false
    readonly property bool anyInUse: root.micInUse || root.screenInUse

    visible: anyInUse
    implicitWidth: iconsRow.implicitWidth + (Theme.bar_widget_padding * 2)
    implicitHeight: Theme.bar_widget_height
    radius: Theme.radius_normal
    color: Theme.color_privacy
    border.width: Theme.border_width
    border.color: Theme.color_border

    Row {
        id: iconsRow
        anchors.centerIn: parent
        spacing: 8

        Text {
            visible: root.micInUse
            text: ""
            color: Theme.color_text
            font.pixelSize: Theme.font_size
            font.family: Theme.font_family_icon
        }

        Text {
            visible: root.screenInUse
            text: "󰍺"
            color: Theme.color_text
            font.pixelSize: Theme.font_size
            font.family: Theme.font_family_icon
        }
    }

    StdioCollector {
        id: probeOut
        waitForEnd: true
        onStreamFinished: {
            var parts = text.trim().split(":");
            root.micInUse = parts.length > 0 && parts[0] === "1";
            root.screenInUse = parts.length > 1 && parts[1] === "1";
        }
    }

    Process {
        id: probe
        stdout: probeOut
    }

    function refresh(): void {
        probe.exec(["sh", "-c", "mic=0; screen=0; " + "if command -v pw-dump >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then " + "data=\"$(pw-dump 2>/dev/null)\"; " + "mic=$(printf '%s' \"$data\" | jq -r '[.[] | select(.type==\"PipeWire:Interface:Node\") | .info as $i | ($i.props // {}) as $p | select(($p[\"media.class\"] // \"\") == \"Stream/Input/Audio\") | select(((($i.state // \"\") | ascii_downcase) != \"error\"))] | if length > 0 then 1 else 0 end'); " + "screen=$(printf '%s' \"$data\" | jq -r '[.[] | select(.type==\"PipeWire:Interface:Node\") | .info as $i | ($i.props // {}) as $p | (($p[\"media.class\"] // \"\") | ascii_downcase) as $mc | (($p[\"media.role\"] // \"\") | ascii_downcase) as $mr | (($p[\"media.category\"] // \"\") | ascii_downcase) as $mcat | select($mc == \"stream/input/video\") | select(((($i.state // \"\") | ascii_downcase) != \"error\")) | select(($mr == \"screen\") or ($mr == \"capture\") or ($mr == \"screencast\") or ($mcat == \"capture\") or ($mr == \"\") ) | select($mr != \"camera\")] | if length > 0 then 1 else 0 end'); " + "else " + "if command -v pactl >/dev/null 2>&1; then pactl list source-outputs short 2>/dev/null | grep -q . && mic=1; fi; " + "if command -v pw-dump >/dev/null 2>&1; then pw-dump 2>/dev/null | grep -Eq '\"media.class\"[[:space:]]*:[[:space:]]*\"Stream/Input/Video\"' && screen=1; fi; " + "fi; " + "printf '%s:%s\\n' \"$mic\" \"$screen\""]);
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}

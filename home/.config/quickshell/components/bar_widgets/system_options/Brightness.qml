pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../"

Rectangle {
    id: root
    property string panelScreenName: ""
    property int ddcDisplay: 1
    property int brightnessPercent: 50
    property int brightnessMax: 100
    property int pendingBrightnessRaw: -1
    property int pendingBrightnessPercent: -1
    property string brightnessBackend: "ddcutil"
    property string brightnessCtlDevice: ""

    readonly property int trackHeight: 14
    readonly property int thumbDiameter: 22

    function clampPercent(value: int): int {
        return Math.max(0, Math.min(100, value));
    }

    function shellQuote(value: string): string {
        if (!value)
            return "''";
        return "'" + value.replace(/'/g, "'\"'\"'") + "'";
    }

    function setBrightness(percent: int): void {
        var next = clampPercent(percent);
        if (next === root.brightnessPercent)
            return;
        root.brightnessPercent = next;
        var max = Math.max(1, root.brightnessMax);
        root.pendingBrightnessRaw = Math.round((next * max) / 100);
        root.pendingBrightnessPercent = next;
        brightnessApplyTimer.restart();
    }

    function updateBrightnessFromTrack(mouseX: real, trackWidth: real): void {
        var width = Math.max(1, trackWidth);
        var ratio = Math.max(0, Math.min(1, mouseX / width));
        setBrightness(Math.round(ratio * 100));
    }

    function detectBrightnessBackend(): void {
        brightnessDetect.exec(["sh", "-c", "name=" + shellQuote(root.panelScreenName) + "; " + "if printf '%s' \"$name\" | grep -Eq '^(eDP|LVDS|DSI)' ; then " + "for dev in /sys/class/backlight/*; do " + "[ -d \"$dev\" ] || continue; " + "printf 'brightnessctl\\t%s\\n' \"$(basename \"$dev\")\"; " + "exit 0; " + "done; " + "fi; " + "printf 'ddcutil\\t%s\\n' \"$name\""]);
    }

    function probeBrightness(): void {
        if (root.brightnessBackend === "brightnessctl" && root.brightnessCtlDevice.length > 0) {
            brightnessProbe.exec(["sh", "-c", "current=$(brightnessctl -d " + shellQuote(root.brightnessCtlDevice) + " g 2>/dev/null); " + "max=$(brightnessctl -d " + shellQuote(root.brightnessCtlDevice) + " m 2>/dev/null); " + "[ -n \"$current\" ] && [ -n \"$max\" ] && printf 'current value = %s\\nmax value = %s\\n' \"$current\" \"$max\" || true"]);
            return;
        }
        brightnessProbe.exec(["sh", "-c", "ddcutil --brief --display " + root.ddcDisplay + " getvcp 10 2>/dev/null || true"]);
    }

    implicitWidth: 280
    implicitHeight: sliderRow.implicitHeight + (Theme.bar_widget_height)
    width: implicitWidth
    height: implicitHeight
    Layout.fillWidth: true
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: Theme.radius_normal
    color: Theme.color_surface

    RowLayout {
        id: sliderRow
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: Theme.bar_widget_height
            rightMargin: Theme.bar_widget_height
        }
        spacing: 10

        Text {
            text: "󰃠"
            color: Theme.color_text
            font.pixelSize: Theme.font_size_icon_lg
            font.family: Theme.font_family_icon
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            id: sliderContainer
            Layout.fillWidth: true
            implicitHeight: root.thumbDiameter
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                id: sliderTrack
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: root.trackHeight
                radius: root.trackHeight / 2
                color: Theme.color_surface_hover

                Rectangle {
                    id: sliderFill
                    width: Math.max(radius * 2, Math.round(sliderTrack.width * root.brightnessPercent / 100))
                    height: parent.height
                    radius: parent.radius
                    color: Theme.color_text

                    Behavior on width {
                        enabled: !sliderMouse.pressed
                        NumberAnimation {
                            duration: 140
                            easing.type: Easing.InOutCubic
                        }
                    }
                }
            }

            Rectangle {
                id: sliderThumb
                width: root.thumbDiameter
                height: root.thumbDiameter
                radius: root.thumbDiameter / 2
                color: Theme.color_text
                anchors.verticalCenter: sliderTrack.verticalCenter
                x: Math.max(0, Math.min(sliderTrack.width - width, Math.round(sliderTrack.width * root.brightnessPercent / 100) - width / 2))

                Behavior on x {
                    enabled: !sliderMouse.pressed
                    NumberAnimation {
                        duration: 140
                        easing.type: Easing.InOutCubic
                    }
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.38
                    height: parent.width * 0.38
                    radius: width / 2
                    color: Theme.color_surface
                    opacity: 0.5
                }
            }

            MouseArea {
                id: sliderMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPressed: function (mouse) {
                    root.updateBrightnessFromTrack(mouse.x, sliderTrack.width);
                }
                onPositionChanged: function (mouse) {
                    if (!pressed)
                        return;
                    root.updateBrightnessFromTrack(mouse.x, sliderTrack.width);
                }
            }
        }
    }

    Process {
        id: brightnessSet
    }

    Process {
        id: brightnessDetect
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length === 0)
                    return;
                var parts = raw.split(/\t+/);
                var backend = parts.length > 0 ? parts[0].trim() : "";
                if (backend !== "brightnessctl" && backend !== "ddcutil")
                    backend = "ddcutil";
                root.brightnessBackend = backend;
                root.brightnessCtlDevice = backend === "brightnessctl" && parts.length > 1 ? parts[1].trim() : "";
                root.probeBrightness();
            }
        }
    }

    Process {
        id: brightnessProbe
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                var raw = text.trim();
                if (raw.length === 0)
                    return;
                var currentMatch = raw.match(/current value =\s*([0-9]+)/);
                var maxMatch = raw.match(/max value =\s*([0-9]+)/);
                if (!currentMatch || !maxMatch)
                    return;
                var current = parseInt(currentMatch[1]);
                var max = parseInt(maxMatch[1]);
                if (isNaN(current) || isNaN(max) || max <= 0)
                    return;
                root.brightnessMax = max;
                root.brightnessPercent = root.clampPercent(Math.round((current * 100) / max));
            }
        }
    }

    Timer {
        id: brightnessApplyTimer
        interval: 120
        running: false
        repeat: false
        onTriggered: {
            if (root.brightnessBackend === "brightnessctl") {
                if (root.pendingBrightnessPercent < 0 || root.brightnessCtlDevice.length === 0)
                    return;
                brightnessSet.exec(["sh", "-c", "brightnessctl -d " + root.shellQuote(root.brightnessCtlDevice) + " set " + root.pendingBrightnessPercent + "% >/dev/null 2>&1 || true"]);
                return;
            }
            if (root.pendingBrightnessRaw < 0)
                return;
            brightnessSet.exec(["sh", "-c", "ddcutil --display " + root.ddcDisplay + " setvcp 10 " + root.pendingBrightnessRaw + " >/dev/null 2>&1 || true"]);
        }
    }

    onPanelScreenNameChanged: detectBrightnessBackend()
    Component.onCompleted: detectBrightnessBackend()
}

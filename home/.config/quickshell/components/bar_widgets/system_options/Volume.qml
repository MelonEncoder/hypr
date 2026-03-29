pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../../"

Rectangle {
    id: root

    readonly property int trackHeight: 14
    readonly property int thumbDiameter: 22
    readonly property int sectionMargin: Math.round(Theme.bar_widget_padding / 2)

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property int pipewireVolume: {
        if (!sink || !sink.audio)
            return 0;
        return Math.max(0, Math.min(150, Math.round(sink.audio.volume * 100)));
    }
    readonly property int expandedContentHeight: deviceColumn.implicitHeight

    readonly property var audioSinks: {
        var result = [];
        var nodes = Pipewire.nodes.values;
        for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i];
            if (node.isSink && !node.isStream)
                result.push(node);
        }
        return result;
    }

    property int currentVolume: 0
    property bool expanded: false

    onPipewireVolumeChanged: {
        if (!sliderMouse.pressed)
            currentVolume = pipewireVolume;
    }

    function setVolumeFromTrack(mouseX: real, trackWidth: real): void {
        currentVolume = Math.round(Math.max(0, Math.min(100, mouseX / Math.max(1, trackWidth) * 100)));
        if (sink && sink.audio)
            sink.audio.volume = root.currentVolume / 100;
    }

    function setDefaultSink(node: var): void {
        Pipewire.preferredDefaultAudioSink = node;
        root.expanded = false;
    }

    PwObjectTracker {
        id: sinkTracker
    }

    onSinkChanged: sinkTracker.objects = root.sink ? [root.sink] : []

    Component.onCompleted: {
        currentVolume = pipewireVolume;
        if (root.sink)
            sinkTracker.objects = [root.sink];
    }

    implicitWidth: 280
    implicitHeight: volumeFrame.implicitHeight + (root.sectionMargin * 2)
    width: implicitWidth
    height: implicitHeight
    Layout.fillWidth: true
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: Theme.radius_normal
    color: Theme.color_surface

    Item {
        id: volumeFrame
        x: root.sectionMargin
        y: root.sectionMargin
        width: parent.width - (root.sectionMargin * 2)
        implicitHeight: volumeMenu.implicitHeight

        ColumnLayout {
            id: volumeMenu
            width: parent.width
            spacing: 4

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.bar_widget_height * 1.5
                radius: Theme.radius_normal
                color: "transparent"

                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 10
                        rightMargin: 10
                    }
                    spacing: 10

                    Rectangle {
                        id: muteButton
                        property bool hovered: muteButtonMouse.containsMouse
                        property bool pressed: muteButtonMouse.pressed
                        implicitWidth: Theme.bar_widget_height
                        implicitHeight: Theme.bar_widget_height
                        Layout.alignment: Qt.AlignVCenter
                        radius: Theme.radius_normal
                        color: muteButton.pressed ? Theme.color_surface_pressed : (muteButton.hovered ? Theme.color_surface_hover : "transparent")

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easing_standard
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: !root.sink || !root.sink.audio ? "" : (root.sink.audio.muted ? "" : (root.currentVolume > 66 ? "" : (root.currentVolume > 33 ? "" : "")))
                            color: Theme.color_text
                            font.pixelSize: Theme.font_size_icon
                            font.family: Theme.font_family_icon
                        }

                        MouseArea {
                            id: muteButtonMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.sink && root.sink.audio)
                                    root.sink.audio.muted = !root.sink.audio.muted;
                            }
                        }
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
                                width: Math.max(radius * 2, Math.round(sliderTrack.width * root.currentVolume / 100))
                                height: parent.height
                                radius: parent.radius
                                color: Theme.color_text

                                Behavior on width {
                                    enabled: !sliderMouse.pressed
                                    NumberAnimation {
                                        duration: Animations.duration_fast
                                        easing.type: Animations.easing_standard
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
                            x: Math.max(0, Math.min(sliderTrack.width - width, Math.round(sliderTrack.width * root.currentVolume / 100) - width / 2))

                            Behavior on x {
                                enabled: !sliderMouse.pressed
                                NumberAnimation {
                                    duration: Animations.duration_fast
                                    easing.type: Animations.easing_standard
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
                                root.setVolumeFromTrack(mouse.x, sliderTrack.width);
                            }
                            onPositionChanged: function (mouse) {
                                if (!pressed)
                                    return;
                                root.setVolumeFromTrack(mouse.x, sliderTrack.width);
                            }
                        }
                    }

                    Rectangle {
                        id: deviceToggle
                        property bool hovered: deviceToggleMouse.containsMouse
                        property bool pressed: deviceToggleMouse.pressed
                        Layout.alignment: Qt.AlignVCenter
                        implicitWidth: Theme.bar_widget_height
                        implicitHeight: Theme.bar_widget_height
                        radius: Theme.radius_normal
                        color: root.expanded || deviceToggle.pressed ? Theme.color_surface_pressed : (deviceToggle.hovered ? Theme.color_surface_hover : "transparent")

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easing_standard
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: root.expanded ? "\uf077" : "\uf078"
                            color: root.expanded ? Theme.color_text : Theme.color_text_subtle
                            font.pixelSize: Theme.font_size_icon_lg
                            font.family: Theme.font_family_icon
                        }

                        MouseArea {
                            id: deviceToggleMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.expanded = !root.expanded
                        }
                    }
                }
            }

            Item {
                visible: root.expanded || opacity > 0.01
                Layout.fillWidth: true
                Layout.preferredHeight: root.expanded ? root.expandedContentHeight : 0
                implicitHeight: root.expanded ? root.expandedContentHeight : 0
                opacity: root.expanded ? 1 : 0
                clip: true

                Behavior on Layout.preferredHeight {
                    NumberAnimation {
                        duration: Animations.duration_dropdown_section
                        easing.type: Animations.easing_emphasized
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Animations.duration_dropdown_section
                        easing.type: Animations.easing_emphasized
                    }
                }

                ColumnLayout {
                    id: deviceColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 3

                    Text {
                        text: Strings.tr.output_devices
                        color: Theme.color_text_subtle
                        font.pixelSize: Theme.font_size
                        font.family: Theme.font_family
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                    }

                    Repeater {
                        model: root.audioSinks

                        Rectangle {
                            id: deviceItem
                            required property var modelData
                            readonly property bool isDefault: !!root.sink && modelData.id === root.sink.id
                            property bool hovered: deviceMouse.containsMouse
                            property bool pressed: deviceMouse.pressed

                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.bar_widget_height
                            radius: Theme.radius_normal
                            color: deviceItem.pressed ? Theme.color_surface_pressed : (deviceItem.hovered || deviceItem.isDefault ? Theme.color_surface_hover : "transparent")

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.duration_hover
                                    easing.type: Animations.easing_standard
                                }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Text {
                                    text: deviceItem.isDefault ? "" : ""
                                    color: deviceItem.isDefault ? Theme.color_text : Theme.color_text_subtle
                                    font.pixelSize: Theme.font_size_sm
                                    font.family: Theme.font_family_icon
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                Text {
                                    text: deviceItem.modelData.description || deviceItem.modelData.nick || deviceItem.modelData.name || "Unknown"
                                    color: Theme.color_text
                                    font.pixelSize: Theme.font_size
                                    font.family: Theme.font_family
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }

                            MouseArea {
                                id: deviceMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.setDefaultSink(deviceItem.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}

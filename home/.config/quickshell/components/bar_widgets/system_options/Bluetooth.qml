pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import "../../"

Rectangle {
    id: root
    property bool expanded: false
    property var btDevices: Bluetooth.defaultAdapter.devices.values
    readonly property int sectionMargin: Math.round(Theme.bar_widget_padding / 2)
    readonly property int expandedContentHeight: bluetoothExpandedContent.implicitHeight

    function getConnectedBtDevices(): var {
        var connected = [];
        for (var i = 0; i < btDevices.length; i++) {
            if (btDevices[i] && btDevices[i].connected)
                connected.push(btDevices[i]);
        }
        return connected;
    }

    function getAvailableBtDevices(): var {
        var available = [];
        for (var i = 0; i < btDevices.length; i++) {
            var dev = btDevices[i];
            if (!dev || dev.connected || dev.blocked)
                continue;
            available.push(dev);
        }
        return available;
    }

    function refreshBluetooth(): void {
        if (!Bluetooth.defaultAdapter || !Bluetooth.defaultAdapter.enabled || Bluetooth.defaultAdapter.discovering)
            return;
        Bluetooth.defaultAdapter.discovering = true;
        btDevices = Bluetooth.defaultAdapter.devices.values;
    }

    implicitWidth: 280
    implicitHeight: btFrame.implicitHeight + (root.sectionMargin * 2)
    width: implicitWidth
    height: implicitHeight
    Layout.fillWidth: true
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: Theme.radius_normal
    color: Theme.color_surface

    Item {
        id: btFrame
        x: root.sectionMargin
        y: root.sectionMargin
        width: parent.width - (root.sectionMargin * 2)
        implicitHeight: btMenu.implicitHeight

        ColumnLayout {
            id: btMenu
            width: parent.width
            spacing: 4

            Rectangle {
                id: bluetoothHeader
                property bool hovered: bluetoothHeaderMouse.containsMouse
                property bool pressed: bluetoothHeaderMouse.pressed
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.bar_widget_height * 1.5
                radius: Theme.radius_normal
                color: pressed ? Theme.color_surface_pressed : Theme.color_surface_hover

                Behavior on color {
                    ColorAnimation {
                        duration: Animations.duration_hover
                        easing.type: Animations.easing_standard
                    }
                }

                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 10
                        rightMargin: 10
                    }
                    spacing: 12

                    Text {
                        text: Bluetooth.defaultAdapter.enabled ? "󰂱" : "󰂲"
                        color: Theme.color_text
                        font.pixelSize: Theme.font_size_icon
                        font.family: Theme.font_family_icon
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Column {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        Text {
                            text: "Bluetooth"
                            color: Theme.color_text
                            font.pixelSize: Theme.font_size
                            font.family: Theme.font_family
                        }

                        Text {
                            text: Bluetooth.defaultAdapter.enabled ? "On" : "Off"
                            color: Theme.color_text_subtle
                            font.pixelSize: Theme.font_size
                            font.family: Theme.font_family
                            elide: Text.ElideRight
                            width: Math.max(0, bluetoothHeader.width - 60)
                        }
                    }
                }

                MouseArea {
                    id: bluetoothHeaderMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.expanded = !root.expanded;
                        if (root.expanded)
                            root.refreshBluetooth();
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
                    id: bluetoothExpandedContent
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 3

                    Text {
                        text: "Connected"
                        color: Theme.color_text_subtle
                        font.pixelSize: Theme.font_size
                        font.family: Theme.font_family
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                    }

                    Repeater {
                        model: root.getConnectedBtDevices()

                        Rectangle {
                            id: connectedBtDevice
                            required property var modelData
                            property bool hovered: connectedDeviceMouse.containsMouse
                            property bool pressed: connectedDeviceMouse.pressed
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.bar_widget_height
                            radius: Theme.radius_normal
                            color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.duration_hover
                                    easing.type: Animations.easing_standard
                                }
                            }

                            Text {
                                id: connectedDeviceName
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: parent.modelData.name
                                color: Theme.color_text
                                font.pixelSize: Theme.font_size
                                font.family: Theme.font_family
                                elide: Text.ElideRight
                                width: parent.width - 20
                            }

                            MouseArea {
                                id: connectedDeviceMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: connectedBtDevice.modelData.disconnect()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.bar_widget_height
                        radius: Theme.radius_normal
                        color: "transparent"
                        visible: root.getConnectedBtDevices().length === 0

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: !Bluetooth.defaultAdapter ? "Bluetooth unavailable" : (Bluetooth.defaultAdapter.enabled ? "None connected" : "Bluetooth disabled")
                            color: Theme.color_text_subtle
                            font.pixelSize: Theme.font_size
                            font.family: Theme.font_family
                        }
                    }

                    Text {
                        text: "Available"
                        color: Theme.color_text_subtle
                        font.pixelSize: Theme.font_size
                        font.family: Theme.font_family
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                    }

                    Repeater {
                        model: root.getAvailableBtDevices()

                        Rectangle {
                            id: availableBtDevice
                            required property var modelData
                            property bool hovered: availableDeviceMouse.containsMouse
                            property bool pressed: availableDeviceMouse.pressed
                            Layout.fillWidth: true
                            Layout.preferredHeight: Theme.bar_widget_height
                            radius: Theme.radius_normal
                            color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.duration_hover
                                    easing.type: Animations.easing_standard
                                }
                            }

                            Text {
                                id: availableDeviceName
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: parent.modelData.name
                                color: Theme.color_text
                                font.pixelSize: Theme.font_size
                                font.family: Theme.font_family
                                elide: Text.ElideRight
                                width: parent.width - 20
                            }

                            MouseArea {
                                id: availableDeviceMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: availableBtDevice.modelData.connect()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.bar_widget_height
                        radius: Theme.radius_normal
                        color: "transparent"
                        visible: root.getAvailableBtDevices().length === 0

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: !Bluetooth.defaultAdapter ? "Bluetooth unavailable" : (Bluetooth.defaultAdapter.enabled ? (root.discovering ? "Scanning..." : "None available") : "Bluetooth disabled")
                            color: Theme.color_text_subtle
                            font.pixelSize: Theme.font_size
                            font.family: Theme.font_family
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: bluetoothDiscoveryStop
        interval: 10000
        running: root.expanded
        repeat: false
        onTriggered: {
            if (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.discovering) {
                Bluetooth.defaultAdapter.discovering = false;
                root.btDevices = Bluetooth.defaultAdapter.devices.values;
            }
        }
    }
}

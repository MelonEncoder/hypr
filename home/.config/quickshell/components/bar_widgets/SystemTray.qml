pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import ".."

Rectangle {
    id: root
    property bool expanded: false
    property bool hovered: clickArea.containsMouse
    property bool pressed: clickArea.pressed

    implicitWidth: label.implicitWidth + (Theme.bar_widget_padding * 2)
    implicitHeight: Theme.bar_widget_height
    radius: Theme.radius_normal
    color: root.pressed ? Theme.color_surface_pressed : (root.hovered ? Theme.color_surface_hover : Theme.color_surface)
    border.width: Theme.border_width
    border.color: Theme.color_border

    Behavior on color {
        ColorAnimation {
            duration: Animations.duration_hover
            easing.type: Animations.easing_standard
        }
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.expanded ? "" : ""
        color: Theme.color_text
        font.pixelSize: Theme.font_size
        font.family: Theme.font_family_icon
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.expanded = !root.expanded
    }

    PopupWindow {
        id: dropdown
        anchor.item: root
        visible: root.expanded
        implicitWidth: dropdown.screen.width
        implicitHeight: dropdown.screen.height
        color: "transparent"

        Rectangle {
            width: parent.width
            height: parent.height
            color: "transparent"
            MouseArea {
                anchors.fill: parent
                enabled: root.expanded
                onClicked: root.expanded = false
            }
        }

        Rectangle {
            id: panel
            x: dropdown.width - width - Theme.bar_padding
            y: Theme.bar_widget_height + (Theme.bar_padding * 2)
            width: Math.max(180, trayList.implicitWidth + (Theme.bar_widget_padding * 2))
            height: trayList.implicitHeight + (Theme.bar_widget_padding * 2)
            radius: Theme.radius_background
            color: Theme.color_background
            border.width: Theme.border_width
            border.color: Theme.color_border
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : Animations.dropdown_scale_closed

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

            Behavior on y {
                NumberAnimation {
                    duration: Animations.duration_dropdown
                    easing.type: Animations.easing_emphasized
                }
            }

            ColumnLayout {
                id: trayList
                anchors.centerIn: parent
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: "System Tray"
                    color: Theme.color_text_subtle
                    font.pixelSize: Theme.font_size_xs
                    font.family: Theme.font_family
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 1
                    leftPadding: 2
                    bottomPadding: 2
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.color_border_subtle
                }

                Repeater {
                    model: SystemTray.items

                    Rectangle {
                        id: trayItem
                        required property var modelData
                        Layout.fillWidth: true
                        property bool hovered: trayHover.containsMouse
                        property bool pressed: trayHover.pressed
                        readonly property string itemLabel: {
                            if (!modelData)
                                return "?";
                            var text = (modelData.tooltipTitle || modelData.title || modelData.id || "?") + "";
                            return text.length > 0 ? text : "?";
                        }
                        radius: Theme.radius_normal
                        color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : "transparent")
                        implicitWidth: trayRow.implicitWidth + (Theme.bar_widget_padding * 2)
                        implicitHeight: trayRow.implicitHeight + (Theme.bar_widget_padding * 2)

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easing_standard
                            }
                        }

                        RowLayout {
                            id: trayRow
                            anchors.centerIn: parent
                            width: parent.width - (Theme.bar_widget_padding * 2)
                            spacing: 8

                            IconImage {
                                id: trayIcon
                                source: {
                                    var s = (trayItem.modelData.icon || "").toString();
                                    if (s.startsWith("image://icon/") && s.indexOf("?fallback=") === -1)
                                        return s + "?fallback=application-x-executable";
                                    return s;
                                }
                                implicitSize: 16
                                visible: source.toString() !== "" && status === Image.Ready
                                asynchronous: true
                            }

                            Text {
                                id: trayName
                                Layout.fillWidth: true
                                text: trayItem.itemLabel
                                color: Theme.color_text
                                font.pixelSize: Theme.font_size
                                font.family: Theme.font_family
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: trayHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: function (mouse) {
                                if (!trayItem.modelData)
                                    return;
                                if (mouse.button == Qt.LeftButton) {
                                    if (!trayItem.modelData.onlyMenu) {
                                        trayItem.modelData.activate();
                                    }
                                }

                                if (mouse.button == Qt.RightButton && trayItem.modelData.hasMenu) {
                                    var point = trayItem.mapToItem(null, Math.round(trayItem.width / 2), trayItem.height);
                                    trayItem.modelData.display(dropdown, Math.round(point.x), Math.round(point.y));
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

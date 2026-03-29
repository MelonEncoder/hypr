pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import "system_options"
import ".."

Rectangle {
    id: root
    property bool expanded: false
    property bool hovered: clickArea.containsMouse
    property bool pressed: clickArea.pressed
    property string panelScreenName: ""
    property int ddcDisplay: 1
    readonly property int iconSpacing: 4
    readonly property int slotSize: Math.max(1, Theme.bar_widget_icon_size)
    readonly property int popupWidth: 280
    readonly property int popupMaxHeight: 420

    implicitWidth: (slotSize * 3) + (iconSpacing * 2) + (Theme.bar_widget_padding * 2)
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

    Row {
        id: icon
        anchors.centerIn: parent
        spacing: root.iconSpacing

        Repeater {
            model: ["󰖩", "󰕾", "󰂱"]
            Item {
                required property string modelData
                width: root.slotSize
                height: root.slotSize

                Text {
                    anchors.centerIn: parent
                    text: parent.modelData
                    color: Theme.color_text
                    font.pixelSize: Theme.font_size_icon
                    font.family: Theme.font_family_icon
                }
            }
        }
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
        anchor.rect.x: 0
        anchor.rect.y: Theme.bar_widget_height + (Theme.bar_padding * 2)
        implicitHeight: dropdown.screen.height
        implicitWidth: dropdown.screen.width
        color: "transparent"

        Rectangle {
            id: backdrop
            anchors.fill: parent
            color: "transparent"

            MouseArea {
                anchors.fill: parent
                enabled: root.expanded
                onClicked: root.expanded = false
            }
        }

        Rectangle {
            id: popupContainer
            x: dropdown.width - root.popupWidth - 30
            y: Theme.bar_widget_height + (Theme.bar_padding * 2)
            width: root.popupWidth + (Theme.bar_widget_padding * 2)
            height: popupContent.implicitHeight + (Theme.bar_widget_padding * 2)
            radius: Theme.radius_background
            color: Theme.color_background
            border.width: Theme.border_width
            border.color: Theme.color_border

            Item {
                id: popupContent
                x: Theme.bar_widget_padding
                y: Theme.bar_widget_padding
                width: root.popupWidth
                implicitHeight: optionsColumn.implicitHeight

                Column {
                    id: optionsColumn
                    width: parent.width
                    spacing: 6

                    Screenshot {
                        width: popupContent.width
                    }
                    Brightness {
                        width: popupContent.width
                        panelScreenName: root.panelScreenName
                        ddcDisplay: root.ddcDisplay
                    }
                    Volume {
                        width: popupContent.width
                    }
                    Wifi {
                        width: popupContent.width
                    }
                    Bluetooth {
                        width: popupContent.width
                    }
                    PowerProfiles {
                        width: popupContent.width
                    }
                }
            }
        }
    }
}

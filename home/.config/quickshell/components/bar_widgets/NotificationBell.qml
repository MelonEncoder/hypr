pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import ".."
import "../../services"

Item {
    id: root
    property bool expanded: false

    implicitWidth: widget.implicitWidth
    implicitHeight: Theme.bar_widget_height
    visible: countRepeater.count > 0

    // Reactive notification count — .length on a QML model list is not reactive,
    // but Repeater.count is updated by the model's own change signals.
    Repeater {
        id: countRepeater
        model: NotificationService.trackedNotifications
        delegate: Item {}
    }

    // ── Bar widget ──────────────────────────────────────────────────────────

    Rectangle {
        id: widget
        radius: Theme.radius_normal
        color: widgetMouse.pressed ? Theme.color_surface_pressed : (widgetMouse.containsMouse ? Theme.color_surface_hover : Theme.color_surface)
        border.width: Theme.border_width
        border.color: Theme.color_border
        implicitWidth: bellIcon.implicitWidth + (Theme.bar_widget_padding * 2)
        implicitHeight: Theme.bar_widget_height

        Behavior on color {
            ColorAnimation {
                duration: Animations.duration_hover
                easing.type: Animations.easing_standard
            }
        }

        Text {
            id: bellIcon
            anchors.centerIn: parent
            text: ""
            color: Theme.color_text
            font.pixelSize: Theme.font_size_icon
            font.family: Theme.font_family_icon
        }

        MouseArea {
            id: widgetMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    // ── Notification history popup ──────────────────────────────────────────

    PopupWindow {
        id: dropdown
        anchor.item: root
        anchor.rect.x: 0
        anchor.rect.y: Theme.bar_widget_height + (Theme.bar_padding * 2)
        visible: root.expanded
        implicitWidth: dropdown.screen.width
        implicitHeight: dropdown.screen.height
        color: "transparent"

        // Backdrop — click outside to dismiss
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
            readonly property int panelWidth: 320

            x: (dropdown.width - width) / 2
            y: Theme.bar_widget_height + (Theme.bar_padding * 2)
            width: panelWidth
            height: headerSection.implicitHeight + (Theme.bar_widget_padding * 2) + Theme.calendar_content_spacing + notifFlickable.height
            radius: Theme.radius_background
            color: Theme.color_background
            border.width: Theme.border_width
            border.color: Theme.color_border
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : Animations.dropdown_scale_closed
            transformOrigin: Item.Top
            clip: true

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

            // Absorb clicks so backdrop doesn't fire through the panel
            MouseArea {
                anchors.fill: parent
            }

            // ── Header ────────────────────────────────────────────────────

            Column {
                id: headerSection
                x: Theme.bar_widget_padding
                y: Theme.bar_widget_padding
                width: popupPanel.panelWidth - (Theme.bar_widget_padding * 2)
                spacing: Theme.calendar_content_spacing

                RowLayout {
                    width: parent.width
                    spacing: 0

                    Text {
                        text: Strings.tr.notifications
                        color: Theme.color_text_subtle
                        font.pixelSize: Theme.font_size_xs
                        font.family: Theme.font_family
                        font.letterSpacing: 1
                        leftPadding: 2
                        bottomPadding: 2
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        visible: countRepeater.count > 0
                        text: Strings.tr.clear_all
                        color: clearMouse.containsMouse ? Theme.color_text : Theme.color_text_subtle
                        font.pixelSize: Theme.font_size_xs
                        font.family: Theme.font_family
                        rightPadding: 2
                        bottomPadding: 2

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easing_standard
                            }
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var list = NotificationService.trackedNotifications;
                                for (var i = list.length - 1; i >= 0; i--)
                                    list[i].dismiss();
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.color_border_subtle
                }
            }

            // ── Notification list ──────────────────────────────────────────

            Flickable {
                id: notifFlickable
                anchors.top: headerSection.bottom
                anchors.topMargin: Theme.calendar_content_spacing
                anchors.left: parent.left
                anchors.leftMargin: Theme.bar_widget_padding
                anchors.right: parent.right
                anchors.rightMargin: Theme.bar_widget_padding
                height: Math.min(notifList.implicitHeight, 400)
                contentHeight: notifList.implicitHeight
                clip: true

                Column {
                    id: notifList
                    width: parent.width
                    spacing: Theme.calendar_content_spacing

                    // Empty state
                    Text {
                        visible: countRepeater.count === 0
                        width: parent.width
                        text: Strings.tr.no_notifications
                        color: Theme.color_text_subtle
                        font.pixelSize: Theme.font_size_sm
                        font.family: Theme.font_family
                        horizontalAlignment: Text.AlignHCenter
                        topPadding: 6
                        bottomPadding: 6
                    }

                    // Notification cards
                    Repeater {
                        model: NotificationService.trackedNotifications

                        delegate: Rectangle {
                            id: notifCard
                            required property var modelData

                            readonly property color accentColor: modelData.urgency === NotificationUrgency.Critical ? Theme.notification_accent_critical : (modelData.urgency === NotificationUrgency.Low ? Theme.notification_accent_low : Theme.notification_accent_normal)

                            width: notifList.width
                            implicitHeight: cardContent.implicitHeight + 18
                            radius: Theme.radius_normal
                            color: cardMouse.containsMouse ? Theme.color_surface_hover : Theme.color_surface
                            clip: true

                            Behavior on color {
                                ColorAnimation {
                                    duration: Animations.duration_hover
                                    easing.type: Animations.easing_standard
                                }
                            }

                            // Urgency accent stripe
                            Rectangle {
                                anchors.top: parent.top
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 2
                                color: notifCard.accentColor
                            }

                            Column {
                                id: cardContent
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                anchors.topMargin: 10
                                spacing: 2

                                Text {
                                    visible: text.length > 0
                                    text: notifCard.modelData.appName || ""
                                    color: Theme.color_text_subtle
                                    font.pixelSize: Theme.font_size_xs
                                    font.family: Theme.font_family
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Text {
                                    text: notifCard.modelData.summary || ""
                                    color: Theme.color_text
                                    font.pixelSize: Theme.font_size_sm
                                    font.family: Theme.font_family
                                    font.bold: true
                                    wrapMode: Text.Wrap
                                    width: parent.width
                                }

                                Text {
                                    visible: text.length > 0
                                    text: notifCard.modelData.body || ""
                                    textFormat: Text.StyledText
                                    color: Theme.color_text_muted
                                    font.pixelSize: Theme.font_size_xs
                                    font.family: Theme.font_family
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                    width: parent.width
                                }
                            }

                            // Click card to dismiss
                            MouseArea {
                                id: cardMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notifCard.modelData.dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

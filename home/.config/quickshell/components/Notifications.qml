pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "."

Scope {
    id: root

    readonly property int default_timeout_ms: 10000
    readonly property bool use_notification_timeout: true
    readonly property bool expire_resident: false
    readonly property bool expire_critical: false

    readonly property int margin: 20
    readonly property int width: 380
    readonly property int min_height: 72
    readonly property int max_body_lines: 4
    readonly property int stack_gap_below_bar: 8
    readonly property int spacing: 6
    readonly property int padding: 12
    readonly property int inner_spacing: 6
    readonly property int action_spacing: 4
    readonly property int image_size: 28
    readonly property int action_height: Theme.font_size_jumbo
    readonly property int radius: Theme.radius_normal
    readonly property int border_width: Theme.border_width
    readonly property int slide_offset: 28
    readonly property int top_accent_height: 2
    readonly property int image_max_height: 120
    readonly property int image_radius: Theme.radius_normal

    NotificationServer {
        id: notificationServer

        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        persistenceSupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panel
            required property var modelData
            readonly property int topOffset: root.margin + Theme.bar_widget_height + (Theme.bar_padding * 2) + root.stack_gap_below_bar
            readonly property bool hasNotifications: notificationRepeater.count > 0

            screen: modelData
            visible: hasNotifications
            color: "transparent"
            aboveWindows: true
            focusable: false
            exclusionMode: ExclusionMode.Ignore
            implicitWidth: root.width
            implicitHeight: hasNotifications ? notificationColumn.implicitHeight : 0

            anchors {
                top: true
                right: true
            }

            Item {
                anchors.fill: parent

                Column {
                    id: notificationColumn
                    anchors.top: parent.top
                    anchors.right: parent.right
                    width: root.width
                    spacing: root.spacing

                    Repeater {
                        id: notificationRepeater
                        model: notificationServer.trackedNotifications

                        delegate: Item {
                            id: notificationItem
                            required property var modelData

                            property var notification: modelData
                            property bool closing: false
                            property bool expireOnClose: false
                            property var visibleActions: {
                                var actions = notification.actions || [];
                                var filtered = [];
                                for (var i = 0; i < actions.length; i++) {
                                    var action = actions[i];
                                    var label = ((action.text || "") + "").trim().toLowerCase();
                                    if (label === "dismiss" || label === "close")
                                        continue;
                                    filtered.push(action);
                                }
                                return filtered;
                            }
                            property bool shouldAutoExpire: (!notification.resident || root.expire_resident) && (notification.urgency !== NotificationUrgency.Critical || root.expire_critical)
                            property int resolvedTimeout: {
                                if (!root.use_notification_timeout)
                                    return root.default_timeout_ms;
                                if (notification.expireTimeout <= 0)
                                    return root.default_timeout_ms;
                                return notification.expireTimeout;
                            }
                            implicitWidth: root.width
                            implicitHeight: Math.max(root.min_height, content.implicitHeight + (root.padding * 2) + root.top_accent_height)
                            width: implicitWidth
                            height: implicitHeight

                            function beginClose(expire) {
                                if (closing)
                                    return;
                                closing = true;
                                expireOnClose = expire;
                                card.entered = false;
                                closeTimer.start();
                            }

                            Timer {
                                id: autoExpireTimer
                                running: notificationItem.shouldAutoExpire && notificationItem.resolvedTimeout > 0 && !notificationItem.closing
                                interval: notificationItem.resolvedTimeout
                                repeat: false
                                onTriggered: notificationItem.beginClose(true)
                            }

                            Timer {
                                id: closeTimer
                                interval: Math.max(Animations.duration_slow, Animations.duration_normal) + 40
                                repeat: false
                                onTriggered: {
                                    if (notificationItem.expireOnClose)
                                        notificationItem.notification.expire();
                                    else
                                        notificationItem.notification.dismiss();
                                }
                            }

                            Rectangle {
                                id: card
                                property bool entered: false
                                readonly property color accentColor: notificationItem.notification.urgency === NotificationUrgency.Critical ? Theme.notification_accent_critical : (notificationItem.notification.urgency === NotificationUrgency.Low ? Theme.notification_accent_low : Theme.notification_accent_normal)

                                width: parent.width
                                height: parent.height
                                radius: root.radius
                                clip: true
                                color: Theme.color_surface
                                border.width: root.border_width
                                border.color: Theme.color_border
                                opacity: entered ? 1 : 0
                                x: entered ? 0 : width + root.slide_offset
                                scale: entered ? 1.0 : 0.97
                                transformOrigin: Item.TopRight

                                // Top accent stripe
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: root.top_accent_height
                                    color: card.accentColor
                                }

                                Behavior on x {
                                    NumberAnimation {
                                        duration: Animations.duration_slow
                                        easing.type: Animations.easing_emphasized
                                    }
                                }

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

                                Component.onCompleted: entered = true

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: notificationItem.beginClose(false)
                                }

                                Connections {
                                    target: notificationItem.notification

                                    function onClosed() {
                                        notificationItem.closing = true;
                                        card.entered = false;
                                    }
                                }

                                ColumnLayout {
                                    id: content
                                    anchors.fill: parent
                                    anchors.topMargin: root.padding + root.top_accent_height
                                    anchors.leftMargin: root.padding
                                    anchors.rightMargin: root.padding
                                    anchors.bottomMargin: root.padding
                                    spacing: root.inner_spacing

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: root.inner_spacing

                                        Item {
                                            id: iconContainer
                                            readonly property string iconSource: notificationItem.notification.appIcon || ""
                                            visible: iconSource !== ""
                                            Layout.preferredWidth: visible ? root.image_size : 0
                                            Layout.preferredHeight: visible ? root.image_size : 0
                                            Layout.alignment: Qt.AlignTop

                                            Rectangle {
                                                anchors.fill: parent
                                                radius: root.radius
                                                color: Theme.notification_icon_background
                                                clip: true

                                                Image {
                                                    anchors.fill: parent
                                                    anchors.margins: 3
                                                    source: iconContainer.iconSource
                                                    fillMode: Image.PreserveAspectFit
                                                    asynchronous: true
                                                    smooth: true
                                                }
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2

                                            Text {
                                                visible: text.length > 0
                                                text: notificationItem.notification.appName || ""
                                                color: Theme.color_text_subtle
                                                font.pixelSize: Theme.font_size_sm
                                                font.family: Theme.font_family
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }

                                            Text {
                                                text: notificationItem.notification.summary || ""
                                                color: Theme.color_text
                                                font.pixelSize: Theme.font_size
                                                font.family: Theme.font_family
                                                font.bold: true
                                                wrapMode: Text.Wrap
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }

                                    Text {
                                        visible: text.length > 0
                                        text: notificationItem.notification.body || ""
                                        textFormat: Text.StyledText
                                        color: Theme.color_text_muted
                                        font.pixelSize: Theme.font_size
                                        font.family: Theme.font_family
                                        wrapMode: Text.Wrap
                                        maximumLineCount: root.max_body_lines
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Rectangle {
                                        visible: notificationImage.source.toString() !== ""
                                        Layout.fillWidth: true
                                        Layout.maximumHeight: visible ? root.image_max_height : 0
                                        Layout.minimumHeight: 0
                                        Layout.preferredHeight: visible ? implicitHeight : 0
                                        implicitHeight: notificationImage.status === Image.Ready ? Math.min(root.image_max_height, (notificationImage.implicitHeight > 0 ? notificationImage.implicitHeight : root.image_max_height)) : root.image_max_height
                                        radius: root.image_radius
                                        color: Theme.color_overlay_dark
                                        clip: true

                                        Image {
                                            id: notificationImage
                                            anchors.fill: parent
                                            source: notificationItem.notification.image || ""
                                            fillMode: Image.PreserveAspectFit
                                            asynchronous: true
                                            cache: true
                                            smooth: true
                                            mipmap: true
                                            autoTransform: true
                                        }
                                    }

                                    Flow {
                                        visible: repeater.count > 0
                                        Layout.fillWidth: true
                                        spacing: root.action_spacing

                                        Repeater {
                                            id: repeater
                                            model: notificationItem.visibleActions

                                            delegate: Rectangle {
                                                required property var modelData

                                                property var action: modelData
                                                implicitWidth: actionLabel.implicitWidth + (root.padding * 2)
                                                implicitHeight: root.action_height
                                                radius: Theme.radius_normal
                                                color: actionMouse.pressed ? Theme.notification_action_pressed : (actionMouse.containsMouse ? Theme.notification_action_hover : Theme.notification_action)

                                                Behavior on color {
                                                    ColorAnimation {
                                                        duration: Animations.duration_hover
                                                        easing.type: Animations.easing_standard
                                                    }
                                                }

                                                Text {
                                                    id: actionLabel
                                                    anchors.centerIn: parent
                                                    text: parent.action.text
                                                    color: Theme.color_text
                                                    font.pixelSize: Theme.font_size
                                                    font.family: Theme.font_family
                                                }

                                                MouseArea {
                                                    id: actionMouse
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        parent.action.invoke();
                                                        notificationItem.beginClose(false);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

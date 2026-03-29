pragma Singleton

import QtQuick
import Quickshell.Services.Notifications

QtObject {
    id: root

    readonly property var trackedNotifications: _server.trackedNotifications

    property NotificationServer _server: NotificationServer {
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
}

pragma Singleton

import QtQuick

QtObject {
	readonly property int default_timeout_ms: 10000
	readonly property bool use_notification_timeout: true
	readonly property bool expire_resident: false
	readonly property bool expire_critical: false
}

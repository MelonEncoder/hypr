pragma Singleton

import QtQuick

QtObject {
	readonly property int duration_fast: 140
	readonly property int duration_normal: 220
	readonly property int duration_slow: 320
	readonly property int easing_standard: Easing.InOutCubic
	readonly property int easing_emphasized: Easing.OutCubic
}

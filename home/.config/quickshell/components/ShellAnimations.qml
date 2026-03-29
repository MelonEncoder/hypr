pragma Singleton

import QtQuick

QtObject {
    readonly property int duration_fast: 140
    readonly property int duration_hover: 100
    readonly property int duration_normal: 220
    readonly property int duration_slow: 320
    readonly property int duration_dropdown: 180
    readonly property int duration_dropdown_section: 200
    readonly property int easing_standard: Easing.InOutCubic
    readonly property int easing_emphasized: Easing.OutCubic
    readonly property real dropdown_scale_closed: 0.96
    readonly property int dropdown_offset: 10
}

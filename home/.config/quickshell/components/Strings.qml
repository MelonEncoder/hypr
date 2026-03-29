pragma Singleton

import QtQuick

QtObject {
    id: root
    property string language: "ja"

    // All translations keyed by language code.
    // Add a new top-level key (e.g. "ko") to support another language.
    readonly property var _all: ({
        en: {
            // Popup window headers
            media:            "Media",
            system:           "System",
            quick_settings:   "Quick Settings",
            system_tray:      "System Tray",
            calendar:         "Calendar",
            notifications:    "Notifications",

            // Notification panel
            no_notifications: "No notifications",
            clear_all:        "Clear all",

            // System info labels
            kernel:           "Kernel",
            version:          "Version",

            // Screenshot buttons
            fullscreen:       "Fullscreen",
            region:           "Region",

            // Volume
            output_devices:   "Output Devices",

            // Wi-Fi
            wifi:             "Wi-Fi",

            // Bluetooth
            bluetooth:        "Bluetooth",
            bt_on:            "On",
            bt_off:           "Off",
            bt_unavailable:   "Bluetooth unavailable",
            bt_disabled:      "Bluetooth disabled",
            scanning:         "Scanning...",

            // Power profiles
            power_profiles:   "Power Profiles",

            // Shared status strings
            connected:        "Connected",
            available:        "Available",
            none_connected:   "None connected",
            none_available:   "None available",
            loading:          "Loading...",

            // Media fallback
            no_media:         "No media",

            // Power actions
            power_lock:       "Lock Screen",
            power_logout:     "Log Out",
            power_suspend:    "Sleep",
            power_reboot:     "Restart",
            power_poweroff:   "Shut Down"
        },
        ja: {
            // Popup window headers
            media:            "メディア",
            system:           "システム",
            quick_settings:   "クイック設定",
            system_tray:      "システムトレイ",
            calendar:         "カレンダー",
            notifications:    "通知",

            // Notification panel
            no_notifications: "通知なし",
            clear_all:        "すべて削除",

            // System info labels
            kernel:           "カーネル",
            version:          "バージョン",

            // Screenshot buttons
            fullscreen:       "全画面",
            region:           "範囲選択",

            // Volume
            output_devices:   "出力デバイス",

            // Wi-Fi
            wifi:             "Wi-Fi",

            // Bluetooth
            bluetooth:        "Bluetooth",
            bt_on:            "オン",
            bt_off:           "オフ",
            bt_unavailable:   "Bluetooth 使用不可",
            bt_disabled:      "Bluetooth 無効",
            scanning:         "スキャン中...",

            // Power profiles
            power_profiles:   "電源プロファイル",

            // Shared status strings
            connected:        "接続済み",
            available:        "利用可能",
            none_connected:   "未接続",
            none_available:   "なし",
            loading:          "読み込み中...",

            // Media fallback
            no_media:         "メディアなし",

            // Power actions
            power_lock:       "ロック画面",
            power_logout:     "ログアウト",
            power_suspend:    "スリープ",
            power_reboot:     "再起動",
            power_poweroff:   "シャットダウン"
        }
    })

    // Reactive string map for the current language.
    // Any binding to Strings.tr.<key> automatically re-evaluates on language change.
    readonly property var tr: _all[language] || _all["en"]
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."
import "../../services"

Item {
    id: root
    property bool expanded: false
    property int calYear: new Date().getFullYear()
    property int calMonth: new Date().getMonth() + 1
    implicitWidth: widget.implicitWidth
    implicitHeight: Theme.bar_widget_height

    function daysInMonth(year: int, month: int): int {
        return new Date(year, month, 0).getDate();
    }

    function firstWeekday(year: int, month: int): int {
        return new Date(year, month - 1, 1).getDay();
    }

    function prevMonth(): void {
        if (root.calMonth === 1) {
            root.calMonth = 12;
            root.calYear -= 1;
        } else {
            root.calMonth -= 1;
        }
    }

    function nextMonth(): void {
        if (root.calMonth === 12) {
            root.calMonth = 1;
            root.calYear += 1;
        } else {
            root.calMonth += 1;
        }
    }

    // Build flat array of cell objects for the calendar grid
    readonly property var calCells: {
        var cells = [];
        var offset = root.firstWeekday(root.calYear, root.calMonth);
        var total = root.daysInMonth(root.calYear, root.calMonth);
        var today = new Date();
        var todayDay = today.getDate();
        var todayMonth = today.getMonth() + 1;
        var todayYear = today.getFullYear();
        var cellCount = Math.ceil((offset + total) / 7) * 7;
        for (var i = 0; i < cellCount; i++) {
            var day = i - offset + 1;
            var isValid = i >= offset && day <= total;
            cells.push({
                day: isValid ? day : 0,
                isValid: isValid,
                isToday: isValid && day === todayDay && root.calMonth === todayMonth && root.calYear === todayYear,
                weekCol: i % 7
            });
        }
        return cells;
    }

    // ── Bar widget ──────────────────────────────────────────────────────────

    Rectangle {
        id: widget
        radius: Theme.radius_normal
        color: widgetMouse.pressed ? Theme.color_surface_pressed : (widgetMouse.containsMouse ? Theme.color_surface_hover : Theme.color_surface)
        border.width: Theme.border_width
        border.color: Theme.color_border
        implicitWidth: row.implicitWidth + (Theme.bar_widget_padding * 2)
        implicitHeight: Theme.bar_widget_height

        Behavior on color {
            ColorAnimation {
                duration: Animations.duration_hover
                easing.type: Animations.easing_standard
            }
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Theme.bar_widget_padding

            Text {
                text: DateTime.time
                color: Theme.color_text
                font.pixelSize: Theme.font_size
                font.family: Theme.font_family
            }

            Text {
                text: DateTime.date
                color: Theme.color_text_subtle
                font.pixelSize: Theme.font_size
                font.family: Theme.font_family
            }
        }

        MouseArea {
            id: widgetMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.calYear = new Date().getFullYear();
                root.calMonth = new Date().getMonth() + 1;
                root.expanded = !root.expanded;
            }
        }
    }

    // ── Calendar popup ──────────────────────────────────────────────────────

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
            readonly property int contentWidth: Theme.calendar_cell_width * 7

            x: (dropdown.width - width) / 2
            y: Theme.bar_widget_height + (Theme.bar_padding * 2)
            width: contentWidth + (Theme.bar_widget_padding * 2)
            height: popupContent.implicitHeight + (Theme.bar_widget_padding * 2)
            radius: Theme.radius_background
            color: Theme.color_background
            border.width: Theme.border_width
            border.color: Theme.color_border
            opacity: root.expanded ? 1 : 0
            scale: root.expanded ? 1 : Animations.dropdown_scale_closed
            transformOrigin: Item.Top

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

            Column {
                id: popupContent
                x: Theme.bar_widget_padding
                y: Theme.bar_widget_padding
                width: popupPanel.contentWidth
                spacing: Theme.calendar_content_spacing

                // ── Section label ───────────────────────────────────────────

                Text {
                    text: Strings.tr.calendar
                    color: Theme.color_text_subtle
                    font.pixelSize: Theme.font_size_xs
                    font.family: Theme.font_family
                    font.letterSpacing: 1
                    leftPadding: 2
                    bottomPadding: 2
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.color_border_subtle
                }

                // ── Month navigation ────────────────────────────────────────

                Item {
                    width: parent.width
                    height: Theme.calendar_nav_height

                    Text {
                        id: prevBtn
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "‹"
                        color: prevMonthMouse.containsMouse ? Theme.color_text : Theme.color_text_subtle
                        font.pixelSize: Theme.font_size_title
                        font.family: Theme.font_family
                        leftPadding: 4

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easing_standard
                            }
                        }

                        MouseArea {
                            id: prevMonthMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.prevMonth()
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.calYear + "年" + root.calMonth + "月"
                        color: Theme.color_text
                        font.pixelSize: Theme.font_size
                        font.family: Theme.font_family
                    }

                    Text {
                        id: nextBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "›"
                        color: nextMonthMouse.containsMouse ? Theme.color_text : Theme.color_text_subtle
                        font.pixelSize: Theme.font_size_title
                        font.family: Theme.font_family
                        rightPadding: 4

                        Behavior on color {
                            ColorAnimation {
                                duration: Animations.duration_hover
                                easing.type: Animations.easing_standard
                            }
                        }

                        MouseArea {
                            id: nextMonthMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.nextMonth()
                        }
                    }
                }

                // ── Day-of-week headers (日月火水木金土) ────────────────────

                Grid {
                    columns: 7
                    width: parent.width

                    Repeater {
                        model: ["日", "月", "火", "水", "木", "金", "土"]
                        delegate: Text {
                            required property string modelData
                            required property int index
                            width: Theme.calendar_cell_width
                            height: Theme.calendar_header_height
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: modelData
                            // Sunday red, Saturday blue
                            color: index === 0 ? Theme.calendar_color_sunday : (index === 6 ? Theme.calendar_color_saturday : Theme.color_text_subtle)
                            font.pixelSize: Theme.font_size_xs
                            font.family: Theme.font_family
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.color_border_subtle
                }

                // ── Calendar day grid ───────────────────────────────────────

                Grid {
                    columns: 7
                    width: parent.width
                    bottomPadding: 2

                    Repeater {
                        model: root.calCells
                        delegate: Item {
                            required property var modelData

                            width: Theme.calendar_cell_width
                            height: Theme.calendar_cell_height

                            // Today highlight circle
                            Rectangle {
                                anchors.centerIn: parent
                                width: Theme.calendar_today_size
                                height: Theme.calendar_today_size
                                radius: Theme.calendar_today_size / 2
                                color: Theme.color_text
                                visible: parent.modelData.isToday
                            }

                            Text {
                                anchors.centerIn: parent
                                text: parent.modelData.isValid ? parent.modelData.day.toString() : ""
                                color: {
                                    if (!parent.modelData.isValid)
                                        return "transparent";
                                    if (parent.modelData.isToday)
                                        return Theme.color_background;
                                    if (parent.modelData.weekCol === 0)
                                        return Theme.calendar_color_sunday;
                                    if (parent.modelData.weekCol === 6)
                                        return Theme.calendar_color_saturday;
                                    return Theme.color_text;
                                }
                                font.pixelSize: Theme.font_size_xs
                                font.family: Theme.font_family
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }
}

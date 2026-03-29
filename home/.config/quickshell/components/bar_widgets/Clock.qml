pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import ".."
import "../../services"

Rectangle {
    radius: Theme.radius_normal
    color: Theme.color_surface
    border.width: Theme.border_width
    border.color: Theme.color_border
    implicitWidth: row.implicitWidth + (Theme.bar_widget_padding * 2)
    implicitHeight: Theme.bar_widget_height

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
}

import QtQuick
import ".."
import "../../constants"
import "../../services"

Rectangle {
	radius: Theme.radius_normal
	color: Theme.color_surface
	border.width: Theme.border_width
	border.color: Theme.color_border
	implicitWidth: label.implicitWidth + (BarTheme.widget_padding * 2)
	implicitHeight: BarTheme.widget_height

	Text {
		id: label
		anchors.centerIn: parent
		text: DateTime.date
		color: Theme.color_text
		font.pixelSize: Theme.font_size
		font.family: Theme.font_family
	}
}

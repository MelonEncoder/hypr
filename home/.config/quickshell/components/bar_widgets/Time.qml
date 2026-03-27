import QtQuick
import ".."
import "../../services"

Rectangle {
	radius: Theme.radius_normal
	color: Theme.color_surface
	border.width: Theme.border_width
	border.color: Theme.color_border
	implicitWidth: label.implicitWidth + (Theme.bar_widget_padding * 2)
	implicitHeight: Theme.bar_widget_height

	Text {
		id: label
		anchors.centerIn: parent
		text: DateTime.time
		color: Theme.color_text
		font.pixelSize: Theme.font_size
		font.family: Theme.font_family
	}
}

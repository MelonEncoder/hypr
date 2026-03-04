import QtQuick
import ".."
import "../../constants"
import "../../services"

Rectangle {
	radius: Theme.radius
	color: Theme.colors.surface
	border.width: Theme.borderSize
	border.color: Theme.colors.border
	implicitWidth: label.implicitWidth + (BarTheme.widgetPadding * 2)
	implicitHeight: BarTheme.widgetHeight

	Text {
		id: label
		anchors.centerIn: parent
		text: DateTime.time
		color: Theme.colors.text
		font.pixelSize: Theme.font.size
		font.family: Theme.font.family
	}
}

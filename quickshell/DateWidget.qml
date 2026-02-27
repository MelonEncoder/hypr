import QtQuick

Rectangle {
	radius: Theme.radius
	color: Theme.widgetBackgroundIdle
	border.width: Theme.borderWidth
	border.color: Theme.surfaceBorder
	implicitWidth: label.implicitWidth + Theme.widgetPaddingX
	implicitHeight: Theme.widgetHeight

	Text {
		id: label
		anchors.centerIn: parent
		text: DateTime.date
		color: Theme.textPrimary
		font.pixelSize: Theme.fontSize
		font.family: Theme.fontFamily
	}
}

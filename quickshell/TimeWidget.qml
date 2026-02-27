import QtQuick

Rectangle {
	radius: 5
	color: Colors.surfaceBackground
	border.width: 1
	border.color: Colors.surfaceBorder
	implicitWidth: label.implicitWidth + 12
	implicitHeight: label.implicitHeight + 8

	Text {
		id: label
		anchors.centerIn: parent
		text: DateTime.time
		color: Colors.textPrimary
		font.pixelSize: 12
	}
}

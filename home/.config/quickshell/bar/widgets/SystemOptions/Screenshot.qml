import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../../constants" as Constants
import "../../" as Bar

Item {
	id: root

	function trigger(mode: string): void {
		screenshotProc.exec([
			"hyprshot",
			"-z",
			"-m",
			mode,
		])
	}

	implicitWidth: 280
	implicitHeight: screenshotContent.implicitHeight
	width: implicitWidth
	height: implicitHeight
	Layout.fillWidth: true
	Layout.preferredWidth: implicitWidth
	Layout.preferredHeight: implicitHeight

	RowLayout {
		id: screenshotContent
		width: parent.width
		spacing: Bar.BarTheme.inner_spacing

		Rectangle {
			id: fullscreenButton
			property bool hovered: fullscreenMouse.containsMouse
			property bool pressed: fullscreenMouse.pressed
			Layout.fillWidth: true
			Layout.preferredHeight: Bar.BarTheme.widget_height * 1.5
			radius: Constants.Theme.radius_normal
			color: pressed ? Constants.Theme.color_surface_pressed : (hovered ? Constants.Theme.color_surface_hover : Constants.Theme.color_surface)

			RowLayout {
				anchors.centerIn: parent
				spacing: 6

				Text {
					text: "󰍹"
					color: Constants.Theme.color_text
					font.pixelSize: Constants.Theme.font_size + 1
					font.family: Constants.Theme.font_family_icon
				}

				Text {
					text: "Fullscreen"
					color: Constants.Theme.color_text
					font.pixelSize: Constants.Theme.font_size
					font.family: Constants.Theme.font_family
				}
			}

			MouseArea {
				id: fullscreenMouse
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: root.trigger("output")
			}
		}

		Rectangle {
			id: regionButton
			property bool hovered: regionMouse.containsMouse
			property bool pressed: regionMouse.pressed
			Layout.fillWidth: true
			Layout.preferredHeight: Bar.BarTheme.widget_height * 1.5
			radius: Constants.Theme.radius_normal
			color: pressed ? Constants.Theme.color_surface_pressed : (hovered ? Constants.Theme.color_surface_hover : Constants.Theme.color_surface)

			RowLayout {
				anchors.centerIn: parent
				spacing: 6

				Text {
					text: "󰹑"
					color: Constants.Theme.color_text
					font.pixelSize: Constants.Theme.font_size + 1
					font.family: Constants.Theme.font_family_icon
				}

				Text {
					text: "Region"
					color: Constants.Theme.color_text
					font.pixelSize: Constants.Theme.font_size
					font.family: Constants.Theme.font_family
				}
			}

			MouseArea {
				id: regionMouse
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: root.trigger("region")
			}
		}
	}
	Process {
	    id: screenshotProc
	}
}

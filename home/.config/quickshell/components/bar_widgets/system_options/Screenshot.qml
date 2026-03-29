import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../"

Item {
    id: root

    function trigger(mode: string): void {
        screenshotProc.exec(["hyprshot", "-z", "-m", mode,]);
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
        spacing: 6

        Rectangle {
            id: fullscreenButton
            property bool hovered: fullscreenMouse.containsMouse
            property bool pressed: fullscreenMouse.pressed
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.bar_widget_height * 1.5
            radius: Theme.radius_normal
            color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : Theme.color_surface)

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easing_standard
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "󰍹"
                    color: Theme.color_text
                    font.pixelSize: Theme.font_size_icon_sm
                    font.family: Theme.font_family_icon
                }

                Text {
                    text: "Fullscreen"
                    color: Theme.color_text
                    font.pixelSize: Theme.font_size
                    font.family: Theme.font_family
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
            Layout.preferredHeight: Theme.bar_widget_height * 1.5
            radius: Theme.radius_normal
            color: pressed ? Theme.color_surface_pressed : (hovered ? Theme.color_surface_hover : Theme.color_surface)

            Behavior on color {
                ColorAnimation {
                    duration: Animations.duration_hover
                    easing.type: Animations.easing_standard
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "󰹑"
                    color: Theme.color_text
                    font.pixelSize: Theme.font_size_icon_sm
                    font.family: Theme.font_family_icon
                }

                Text {
                    text: "Region"
                    color: Theme.color_text
                    font.pixelSize: Theme.font_size
                    font.family: Theme.font_family
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

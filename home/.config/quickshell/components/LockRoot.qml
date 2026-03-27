pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Hyprland._GlobalShortcuts
import QtCore
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "."
import "../services"

Scope {
	id: root

	// margin + padding
	readonly property int screen_margin: 48
	readonly property int column_width: 400
	readonly property int column_spacing: 50
	readonly property int header_spacing: 0
	readonly property int column_offset: -90
	readonly property int time_font_size: 68
	readonly property int date_font_size: 18
	// input
	readonly property int input_height: 50
	readonly property int input_radius: Theme.radius_normal * 2
	readonly property int input_border_width: 3
	readonly property int input_padding: 18
	readonly property int input_font_size: 16
	readonly property int status_font_size: 14
	readonly property int status_height: 24
	// bg
	readonly property int background_blur_max: 40
	readonly property real background_blur_strength: 0.6
	// shadow
	readonly property real text_shadow_blur: 0.5
	readonly property real text_shadow_horizontal_offset: 0
	readonly property real text_shadow_vertical_offset: 0
	readonly property real input_shadow_blur: 0.6
	readonly property real input_shadow_horizontal_offset: 0
	readonly property real input_shadow_vertical_offset: 0

	readonly property string time_font_family: "JetBrains Mono"
	readonly property string body_font_family: "JetBrains Mono"


	property bool locked: false
	property bool authenticating: false
	property bool failedAttempt: false
	property string statusText: ""
	property string submittedSecret: ""
	readonly property string wallpaperPath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/share/wallpapers/apartment.jpg"
	readonly property string currentUser: (Quickshell.env("USER") || "") + ""

	function activateLock(): void {
		if (root.locked) return
		root.locked = true
		root.authenticating = false
		root.failedAttempt = false
		root.statusText = ""
		root.submittedSecret = ""
	}

	function resetPrompt(): void {
		root.authenticating = false
		root.submittedSecret = ""
	}

	function submitSecret(secret: string): void {
		var value = (secret || "") + ""
		if (!root.locked || root.authenticating) return
		if (value.length === 0) {
			root.statusText = "Enter your password"
			root.failedAttempt = true
			return
		}

		root.authenticating = true
		root.failedAttempt = false
		root.statusText = "Checking password..."
		root.submittedSecret = value

		if (!pam.start()) {
			root.authenticating = false
			root.submittedSecret = ""
			root.failedAttempt = true
			root.statusText = "Unable to start PAM"
		}
	}

	function finishUnlock(): void {
		root.locked = false
		root.authenticating = false
		root.failedAttempt = false
		root.statusText = ""
		root.submittedSecret = ""
		sessionLock.unlock()
	}

	GlobalShortcut {
		appid: "quickshell"
		name: "lock-screen"
		description: "Lock the current session"
		triggerDescription: "SUPER+L"
		onPressed: root.activateLock()
	}

	IpcHandler {
		target: "lock"

		function lock(): void {
			root.activateLock()
		}
	}

	WlSessionLock {
		id: sessionLock
		locked: root.locked
		surface: lockSurface
	}

	PamContext {
		id: pam
		config: "swaylock"
		user: root.currentUser

		onPamMessage: {
			if (!root.authenticating) return

			if (message && message.length > 0) {
				root.statusText = message
				root.failedAttempt = messageIsError
			}

			if (responseRequired) {
				respond(root.submittedSecret)
				root.submittedSecret = ""
			}
		}

		onCompleted: result => {
			root.authenticating = false
			root.submittedSecret = ""

			if (result === PamResult.Success) {
				root.finishUnlock()
				return
			}

			root.failedAttempt = true
			root.statusText = result === PamResult.MaxTries
				? "Too many failed attempts"
				: "Incorrect password"
		}

		onError: error => {
			root.authenticating = false
			root.submittedSecret = ""
			root.failedAttempt = true
			root.statusText = PamError.toString(error)
		}
	}

	Component {
		id: lockSurface

		WlSessionLockSurface {
			id: surface
			color: "transparent"

			Rectangle {
				anchors.fill: parent
				color: Theme.lock_base

				Image {
					id: wallpaper
					anchors.fill: parent
					source: root.wallpaperPath
					fillMode: Image.PreserveAspectCrop
					asynchronous: true
					cache: true
					smooth: true
					opacity: 0
				}

				MultiEffect {
					anchors.fill: parent
					source: wallpaper
					autoPaddingEnabled: false
					blurEnabled: true
					blur: root.background_blur_strength
					blurMax: root.background_blur_max
				}

				Rectangle {
					anchors.fill: parent
					color: Theme.lock_scrim
				}

				FocusScope {
					id: focusRoot
					anchors.fill: parent
					focus: true

					MouseArea {
						anchors.fill: parent
						cursorShape: Qt.ArrowCursor
						onPressed: passwordInput.forceActiveFocus()
					}

					Column {
						id: lockColumn
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.verticalCenter: parent.verticalCenter
						anchors.verticalCenterOffset: 0
						width: Math.min(parent.width - (root.screen_margin * 2), root.column_width)
						spacing: root.column_spacing

						Column {
							width: parent.width
							spacing: root.header_spacing

							Item {
								width: parent.width
								height: timeText.implicitHeight

								Text {
									id: timeText
									anchors.horizontalCenter: parent.horizontalCenter
									text: DateTime.time
									horizontalAlignment: Text.AlignHCenter
									color: Theme.color_text
									font.family: root.time_font_family
									font.pixelSize: root.time_font_size
									font.bold: true
								}

								MultiEffect {
									anchors.fill: timeText
									source: timeText
									autoPaddingEnabled: true
									shadowEnabled: true
									shadowColor: Theme.lock_shadow
									shadowBlur: root.text_shadow_blur
									shadowHorizontalOffset: root.text_shadow_horizontal_offset
									shadowVerticalOffset: root.text_shadow_vertical_offset
								}
							}

							Item {
								width: parent.width
								height: dateText.implicitHeight

								Text {
									id: dateText
									anchors.horizontalCenter: parent.horizontalCenter
									text: DateTime.fullDate
									horizontalAlignment: Text.AlignHCenter
									color: Theme.color_text
									font.family: root.body_font_family
									font.pixelSize: root.date_font_size
								}

								MultiEffect {
									anchors.fill: dateText
									source: dateText
									autoPaddingEnabled: true
									shadowEnabled: true
									shadowColor: Theme.lock_shadow
									shadowBlur: root.text_shadow_blur
									shadowHorizontalOffset: root.text_shadow_horizontal_offset
									shadowVerticalOffset: root.text_shadow_vertical_offset
								}
							}
						}

						Item {
							width: parent.width
							height: root.input_height

							Rectangle {
								id: inputFrame
								property color frameBorderColor: root.failedAttempt
									? Theme.lock_error
									: Theme.color_background

								anchors.fill: parent
								radius: root.input_radius
								color: Theme.color_text
								border.width: root.input_border_width
								border.color: frameBorderColor

								Behavior on frameBorderColor {
									ColorAnimation {
										duration: Animations.duration_normal
										easing.type: Animations.easing_standard
									}
								}

								TextInput {
									id: passwordInput
									anchors.fill: parent
									anchors.leftMargin: root.input_padding
									anchors.rightMargin: root.input_padding
									verticalAlignment: TextInput.AlignVCenter
									color: Theme.color_background
									font.family: root.body_font_family
									font.pixelSize: root.input_font_size
									echoMode: TextInput.Password
									passwordCharacter: "•"
									selectByMouse: false
									focus: true
									enabled: root.locked && !root.authenticating
									inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

									onAccepted: root.submitSecret(text)
									onTextEdited: {
										if (root.failedAttempt) root.failedAttempt = false
										if (root.statusText === "Incorrect password" || root.statusText === "Too many failed attempts" || root.statusText === "Enter your password") {
											root.statusText = ""
										}
									}

									Keys.onEscapePressed: {
										text = ""
										root.failedAttempt = false
										root.statusText = ""
									}
								}

								Text {
									anchors.fill: parent
									anchors.leftMargin: root.input_padding
									anchors.rightMargin: root.input_padding
									verticalAlignment: Text.AlignVCenter
									text: passwordInput.text.length === 0 ? "Input Password..." : ""
									color: Theme.lock_placeholder
									font.family: root.body_font_family
									font.pixelSize: root.input_font_size
									font.italic: true
								}
							}

							MultiEffect {
								anchors.fill: inputFrame
								source: inputFrame
								autoPaddingEnabled: true
								shadowEnabled: true
								shadowColor: Theme.lock_shadow
								shadowBlur: root.input_shadow_blur
								shadowHorizontalOffset: root.input_shadow_horizontal_offset
								shadowVerticalOffset: root.input_shadow_vertical_offset
							}
						}

						Text {
							width: parent.width
							height: root.status_height
							text: root.authenticating ? "Checking password..." : root.statusText
							visible: text.length > 0
							horizontalAlignment: Text.AlignHCenter
							color: root.failedAttempt ? Theme.lock_error : Theme.color_text
							font.family: root.body_font_family
							font.pixelSize: root.status_font_size
						}
					}

					Component.onCompleted: passwordInput.forceActiveFocus()
					onActiveFocusChanged: {
						if (activeFocus && root.locked) passwordInput.forceActiveFocus()
					}
				}
			}
		}
	}
}

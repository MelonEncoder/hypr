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
import "../constants"
import "../services"

Scope {
	id: root

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
				color: LockTheme.base_color

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
					blur: LockTheme.background_blur_strength
					blurMax: LockTheme.background_blur_max
					brightness: LockTheme.background_brightness
					saturation: LockTheme.background_saturation
				}

				Rectangle {
					anchors.fill: parent
					color: LockTheme.scrim_color
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
						anchors.verticalCenterOffset: LockTheme.column_offset
						width: Math.min(parent.width - (LockTheme.screen_margin * 2), LockTheme.column_width)
						spacing: LockTheme.column_spacing

						Text {
							width: parent.width
							text: DateTime.time
							horizontalAlignment: Text.AlignHCenter
							color: Theme.color_text
							font.family: LockTheme.time_font_family
							font.pixelSize: LockTheme.time_font_size
							font.bold: true
						}

						Text {
							width: parent.width
							text: DateTime.fullDate
							horizontalAlignment: Text.AlignHCenter
							color: LockTheme.date_color
							font.family: LockTheme.body_font_family
							font.pixelSize: LockTheme.date_font_size
						}

						Rectangle {
							property color frameBorderColor: root.failedAttempt
								? LockTheme.input_fail_border_color
								: (passwordInput.activeFocus ? LockTheme.input_focus_border_color : LockTheme.input_border_color)

							width: parent.width
							height: LockTheme.input_height
							radius: LockTheme.input_radius
							color: LockTheme.input_fill_color
							border.width: LockTheme.input_border_width
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
								anchors.leftMargin: LockTheme.input_padding
								anchors.rightMargin: LockTheme.input_padding
								verticalAlignment: TextInput.AlignVCenter
								color: LockTheme.input_text_color
								font.family: LockTheme.body_font_family
								font.pixelSize: LockTheme.input_font_size
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
								anchors.leftMargin: LockTheme.input_padding
								anchors.rightMargin: LockTheme.input_padding
								verticalAlignment: Text.AlignVCenter
								text: passwordInput.text.length === 0 ? "Input Password..." : ""
								color: LockTheme.placeholder_color
								font.family: LockTheme.body_font_family
								font.pixelSize: LockTheme.input_font_size
								font.italic: true
							}
						}

						Text {
							width: parent.width
							height: LockTheme.status_height
							text: root.authenticating ? "Checking password..." : root.statusText
							visible: text.length > 0
							horizontalAlignment: Text.AlignHCenter
							color: root.failedAttempt ? LockTheme.error_color : LockTheme.status_color
							font.family: LockTheme.body_font_family
							font.pixelSize: LockTheme.status_font_size
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

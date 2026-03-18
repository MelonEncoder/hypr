import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "."
import "../bar"
import "../constants"

pragma ComponentBehavior: Bound

Scope {
	id: root

	NotificationServer {
		id: notificationServer

		keepOnReload: true
		bodySupported: true
		bodyMarkupSupported: true
		actionsSupported: true
		persistenceSupported: true
		imageSupported: true

		onNotification: notification => {
			notification.tracked = true;
		}
	}

	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: panel
			required property var modelData
			readonly property int topOffset: NotificationTheme.margin
				+ BarTheme.widget_height
				+ (BarTheme.bar_padding * 2)
				+ NotificationTheme.stack_gap_below_bar
			readonly property bool hasNotifications: notificationRepeater.count > 0

			screen: modelData
			visible: hasNotifications
			color: "transparent"
			aboveWindows: true
			focusable: false
			exclusionMode: ExclusionMode.Ignore
			implicitWidth: NotificationTheme.width
			implicitHeight: hasNotifications
				? notificationColumn.implicitHeight
				: 0
			margins.top: panel.topOffset
			margins.right: NotificationTheme.margin

			anchors {
				top: true
				right: true
			}

			Item {
				anchors.fill: parent

				Column {
					id: notificationColumn
					anchors.top: parent.top
					anchors.right: parent.right
					width: NotificationTheme.width
					spacing: NotificationTheme.spacing

					Repeater {
						id: notificationRepeater
						model: notificationServer.trackedNotifications

						delegate: Item {
							id: notificationItem
							required property var modelData

							property var notification: modelData
							property bool closing: false
							property bool expireOnClose: false
							property var visibleActions: {
								var actions = notification.actions || [];
								var filtered = [];
								for (var i = 0; i < actions.length; i++) {
									var action = actions[i];
									var label = ((action.text || "") + "").trim().toLowerCase();
									if (label === "dismiss" || label === "close") continue;
									filtered.push(action);
								}
								return filtered;
							}
							property bool shouldAutoExpire: (!notification.resident || NotificationSettings.expire_resident)
								&& (notification.urgency !== NotificationUrgency.Critical || NotificationSettings.expire_critical)
							property int resolvedTimeout: {
								if (!NotificationSettings.use_notification_timeout) return NotificationSettings.default_timeout_ms;
								if (notification.expireTimeout <= 0) return NotificationSettings.default_timeout_ms;
								return notification.expireTimeout;
							}
							implicitWidth: NotificationTheme.width
							implicitHeight: Math.max(
								NotificationTheme.min_height,
								content.implicitHeight + (NotificationTheme.padding * 2) + NotificationTheme.top_accent_height
							)
							width: implicitWidth
							height: implicitHeight

							function beginClose(expire) {
								if (closing) return;
								closing = true;
								expireOnClose = expire;
								card.entered = false;
								closeTimer.start();
							}

							Timer {
								id: autoExpireTimer
								running: notificationItem.shouldAutoExpire && notificationItem.resolvedTimeout > 0 && !notificationItem.closing
								interval: notificationItem.resolvedTimeout
								repeat: false
								onTriggered: notificationItem.beginClose(true)
							}

							Timer {
								id: closeTimer
								interval: Math.max(Animations.duration_slow, Animations.duration_normal) + 40
								repeat: false
								onTriggered: {
									if (notificationItem.expireOnClose) notificationItem.notification.expire();
									else notificationItem.notification.dismiss();
								}
							}

							Rectangle {
								id: card
								property bool entered: false
								readonly property color accentColor: notificationItem.notification.urgency === NotificationUrgency.Critical
									? NotificationTheme.accent_critical
									: (notificationItem.notification.urgency === NotificationUrgency.Low
										? NotificationTheme.accent_low
										: NotificationTheme.accent_normal)

								width: parent.width
								height: parent.height
								radius: NotificationTheme.radius
								clip: true
								color: NotificationTheme.background_color
								border.width: NotificationTheme.border_width
								border.color: NotificationTheme.border_color
								opacity: entered ? 1 : 0
								x: entered ? 0 : width + NotificationTheme.slide_offset
								scale: entered ? 1.0 : 0.97
								transformOrigin: Item.TopRight

								// Top accent stripe
								Rectangle {
									anchors.top: parent.top
									anchors.left: parent.left
									anchors.right: parent.right
									height: NotificationTheme.top_accent_height
									color: card.accentColor
								}

								Behavior on x {
									NumberAnimation {
										duration: Animations.duration_slow
										easing.type: Animations.easing_emphasized
									}
								}

								Behavior on opacity {
									NumberAnimation {
										duration: Animations.duration_normal
										easing.type: Animations.easing_standard
									}
								}

								Behavior on scale {
									NumberAnimation {
										duration: Animations.duration_slow
										easing.type: Animations.easing_emphasized
									}
								}

								Component.onCompleted: entered = true

								MouseArea {
									anchors.fill: parent
									onClicked: notificationItem.beginClose(false)
								}

								Connections {
									target: notificationItem.notification

									function onClosed() {
										notificationItem.closing = true;
										card.entered = false;
									}
								}

								ColumnLayout {
									id: content
									anchors.fill: parent
									anchors.topMargin: NotificationTheme.padding + NotificationTheme.top_accent_height
									anchors.leftMargin: NotificationTheme.padding
									anchors.rightMargin: NotificationTheme.padding
									anchors.bottomMargin: NotificationTheme.padding
									spacing: NotificationTheme.inner_spacing

									RowLayout {
										Layout.fillWidth: true
										spacing: NotificationTheme.inner_spacing

										Item {
											id: iconContainer
											readonly property string iconSource: notificationItem.notification.appIcon || ""
											visible: iconSource !== ""
											Layout.preferredWidth: visible ? NotificationTheme.image_size : 0
											Layout.preferredHeight: visible ? NotificationTheme.image_size : 0
											Layout.alignment: Qt.AlignTop

											Rectangle {
												anchors.fill: parent
												radius: NotificationTheme.radius
												color: NotificationTheme.icon_background_color
												clip: true

												Image {
													anchors.fill: parent
													anchors.margins: 3
													source: iconContainer.iconSource
													fillMode: Image.PreserveAspectFit
													asynchronous: true
													smooth: true
												}
											}
										}

										ColumnLayout {
											Layout.fillWidth: true
											spacing: 2

											Text {
												visible: text.length > 0
												text: notificationItem.notification.appName || ""
												color: Theme.color_text_subtle
												font.pixelSize: Theme.font_size - 1
												font.family: Theme.font_family
												elide: Text.ElideRight
												Layout.fillWidth: true
											}

											Text {
												text: notificationItem.notification.summary || ""
												color: Theme.color_text
												font.pixelSize: Theme.font_size
												font.family: Theme.font_family
												font.bold: true
												wrapMode: Text.Wrap
												Layout.fillWidth: true
											}
										}
									}

									Text {
										visible: text.length > 0
										text: notificationItem.notification.body || ""
										textFormat: Text.StyledText
										color: Theme.color_text_muted
										font.pixelSize: Theme.font_size
										font.family: Theme.font_family
										wrapMode: Text.Wrap
										maximumLineCount: NotificationTheme.max_body_lines
										elide: Text.ElideRight
										Layout.fillWidth: true
									}

									Rectangle {
										visible: notificationImage.source.toString() !== ""
										height: visible ? implicitHeight : 0
										Layout.fillWidth: true
										Layout.maximumHeight: visible ? NotificationTheme.image_max_height : 0
										Layout.minimumHeight: 0
										Layout.preferredHeight: visible ? implicitHeight : 0
										implicitHeight: notificationImage.status === Image.Ready
											? Math.min(
												NotificationTheme.image_max_height,
												(notificationImage.implicitHeight > 0 ? notificationImage.implicitHeight : NotificationTheme.image_max_height)
											)
											: NotificationTheme.image_max_height
										radius: NotificationTheme.image_radius
										color: NotificationTheme.image_background_color
										clip: true

										Image {
											id: notificationImage
											anchors.fill: parent
											source: notificationItem.notification.image || ""
											fillMode: Image.PreserveAspectFit
											asynchronous: true
											cache: true
											smooth: true
											mipmap: true
											autoTransform: true
										}
									}

									Flow {
										visible: repeater.count > 0
										Layout.fillWidth: true
										spacing: NotificationTheme.action_spacing

										Repeater {
											id: repeater
											model: notificationItem.visibleActions

											delegate: Rectangle {
												required property var modelData

												property var action: modelData
												implicitWidth: actionLabel.implicitWidth + (NotificationTheme.padding * 2)
												implicitHeight: NotificationTheme.action_height
												radius: Theme.radius_normal
												color: actionMouse.pressed
													? NotificationTheme.action_pressed_color
													: (actionMouse.containsMouse ? NotificationTheme.action_hover_color : NotificationTheme.action_color)

												Behavior on color {
													ColorAnimation {
														duration: Animations.duration_hover
														easing.type: Animations.easing_standard
													}
												}

												Text {
													id: actionLabel
													anchors.centerIn: parent
													text: parent.action.text
													color: Theme.color_text
													font.pixelSize: Theme.font_size
													font.family: Theme.font_family
												}

												MouseArea {
													id: actionMouse
													anchors.fill: parent
													hoverEnabled: true
													onClicked: {
														parent.action.invoke();
														notificationItem.beginClose(false);
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

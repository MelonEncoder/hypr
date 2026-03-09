pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Hyprland._GlobalShortcuts
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../constants"
import "."

Scope {
	id: root

	property bool visible: false
	property string query: ""
	property string pendingExec: ""
	property string launchStatus: ""
	property int selectedIndex: 0
	property var searchInputRef: null
	property var listViewRef: null
	property bool appsLoading: false
	property string appLoadMessage: "Loading applications..."

	function refreshApplications(): void {
		appsLoading = true
		appLoadMessage = "Loading applications..."
		appScan.exec([
			"bash",
			"-lc",
				"python3 - <<'PY'\n"
				+ "import configparser\n"
				+ "from pathlib import Path\n"
				+ "\n"
				+ "dirs = []\n"
				+ "home = Path.home()\n"
				+ "dirs.append(home / '.local/share/applications')\n"
				+ "dirs.extend(Path('/usr/share').glob('*/applications'))\n"
				+ "dirs.append(Path('/usr/share/applications'))\n"
				+ "dirs.append(Path('/var/lib/flatpak/exports/share/applications'))\n"
				+ "dirs.append(home / '.local/share/flatpak/exports/share/applications')\n"
				+ "icon_roots = [\n"
				+ "    home / '.local/share/icons/hicolor',\n"
				+ "    Path('/usr/local/share/icons/hicolor'),\n"
				+ "    Path('/usr/share/icons/hicolor'),\n"
				+ "    Path('/var/lib/flatpak/exports/share/icons/hicolor'),\n"
				+ "    home / '.local/share/flatpak/exports/share/icons/hicolor',\n"
				+ "]\n"
				+ "\n"
				+ "seen = set()\n"
				+ "entries = []\n"
				+ "\n"
				+ "def clean_exec(value: str) -> str:\n"
				+ "    value = value or ''\n"
				+ "    parts = []\n"
				+ "    for token in value.split():\n"
				+ "        if token.startswith('%'):\n"
				+ "            continue\n"
				+ "        if token.startswith('@@'):\n"
				+ "            continue\n"
				+ "        parts.append(token)\n"
				+ "    return ' '.join(parts).strip()\n"
				+ "\n"
				+ "def clean_text(value: str) -> str:\n"
				+ "    return (value or '').replace('\\t', ' ').replace('\\n', ' ').strip()\n"
				+ "\n"
				+ "def resolve_icon(value: str) -> str:\n"
				+ "    value = clean_text(value)\n"
				+ "    if not value:\n"
				+ "        return ''\n"
				+ "    if value.startswith('/'):\n"
				+ "        return value if Path(value).exists() else ''\n"
				+ "    if '://' in value:\n"
				+ "        return value\n"
				+ "    candidates = []\n"
				+ "    for root in icon_roots:\n"
				+ "        if not root.exists():\n"
				+ "            continue\n"
				+ "        candidates.extend(root.glob(f'**/{value}.png'))\n"
				+ "        candidates.extend(root.glob(f'**/{value}.svg'))\n"
				+ "        candidates.extend(root.glob(f'**/{value}.xpm'))\n"
				+ "    if not candidates:\n"
				+ "        return ''\n"
				+ "    def rank(path: Path):\n"
				+ "        path_str = str(path)\n"
				+ "        scalable = 1 if '/scalable/' in path_str else 0\n"
				+ "        apps = 1 if '/apps/' in path_str else 0\n"
				+ "        size = 0\n"
				+ "        for part in path.parts:\n"
				+ "            if 'x' in part:\n"
				+ "                try:\n"
				+ "                    size = max(size, int(part.split('x', 1)[0]))\n"
				+ "                except Exception:\n"
				+ "                    pass\n"
				+ "        return (apps, scalable, size)\n"
				+ "    candidates.sort(key=rank, reverse=True)\n"
				+ "    return str(candidates[0])\n"
				+ "\n"
				+ "for directory in dirs:\n"
				+ "    if not directory.exists() or not directory.is_dir():\n"
				+ "        continue\n"
				+ "    for path in sorted(directory.glob('*.desktop')):\n"
				+ "        desktop_id = path.name\n"
				+ "        if desktop_id in seen:\n"
				+ "            continue\n"
				+ "        parser = configparser.ConfigParser(interpolation=None, strict=False)\n"
				+ "        try:\n"
				+ "            parser.read(path, encoding='utf-8')\n"
				+ "        except Exception:\n"
				+ "            continue\n"
				+ "        if not parser.has_section('Desktop Entry'):\n"
				+ "            continue\n"
				+ "        section = parser['Desktop Entry']\n"
				+ "        if section.get('Type', 'Application') != 'Application':\n"
				+ "            continue\n"
				+ "        if section.get('NoDisplay', '').lower() == 'true':\n"
				+ "            continue\n"
				+ "        if section.get('Hidden', '').lower() == 'true':\n"
				+ "            continue\n"
				+ "        name = section.get('Name', '').strip()\n"
				+ "        exec_value = clean_exec(section.get('Exec', ''))\n"
				+ "        if not name or not exec_value:\n"
				+ "            continue\n"
				+ "        seen.add(desktop_id)\n"
				+ "        entries.append((\n"
				+ "            clean_text(name),\n"
				+ "            resolve_icon(section.get('Icon', '').strip()),\n"
				+ "            clean_text(exec_value),\n"
				+ "            clean_text(desktop_id),\n"
				+ "            clean_text(section.get('GenericName', '').strip()),\n"
				+ "            clean_text(section.get('Comment', '').strip()),\n"
				+ "        ))\n"
				+ "\n"
				+ "entries.sort(key=lambda item: item[0].casefold())\n"
				+ "for item in entries:\n"
				+ "    print('\\t'.join(item))\n"
				+ "PY"
		])
	}

	function updateFilteredModel(): void {
		var trimmedQuery = root.query.trim().toLowerCase()
		filteredApps.clear()

		for (var i = 0; i < allApps.count; ++i) {
			var app = allApps.get(i)
			if (!app) continue

			var haystack = ((app.name || "") + " " + (app.genericName || "") + " " + (app.comment || "")).toLowerCase()
			if (trimmedQuery.length > 0 && haystack.indexOf(trimmedQuery) === -1) continue

			filteredApps.append({
				name: app.name || "",
				icon: app.icon || "",
				exec: app.exec || "",
				desktopId: app.desktopId || "",
				genericName: app.genericName || "",
				comment: app.comment || ""
			})
		}

		if (filteredApps.count <= 0) {
			selectedIndex = 0
			return
		}

		selectedIndex = Math.max(0, Math.min(selectedIndex, filteredApps.count - 1))
	}

	function clearSearch(): void {
		query = ""
		if (searchInputRef) searchInputRef.text = ""
	}

	function toggle(): void {
		visible = !visible
		if (visible) {
			refreshApplications()
			clearSearch()
			selectedIndex = 0
			launchStatus = ""
			searchFocusTimer.restart()
			updateFilteredModel()
		} else {
			clearSearch()
			selectedIndex = 0
		}
	}

	function closeLauncher(): void {
		visible = false
		clearSearch()
		selectedIndex = 0
	}

	function moveSelection(delta: int): void {
		if (filteredApps.count <= 0) return
		selectedIndex = Math.max(0, Math.min(filteredApps.count - 1, selectedIndex + delta))
		if (listViewRef) listViewRef.positionViewAtIndex(selectedIndex, ListView.Contain)
	}

	function launchSelected(): void {
		if (filteredApps.count <= 0) return
		var app = filteredApps.get(selectedIndex)
		if (!app || !app.exec) return

		pendingExec = app.exec
		launchStatus = "Launching " + app.name
		appLaunch.exec([
			"sh",
			"-c",
			"(" + root.pendingExec + ") >/dev/null 2>&1 &"
		])
		closeLauncher()
	}

	GlobalShortcut {
		appid: "quickshell"
		name: "app-launcher"
		description: "Open application launcher"
		triggerDescription: "SUPER+SPACE"
		onPressed: root.toggle()
	}

	ListModel {
		id: allApps
	}

	ListModel {
		id: filteredApps
	}

	StdioCollector {
		id: appScanOut
		waitForEnd: true

		onStreamFinished: {
			allApps.clear()
			root.appsLoading = false

			var raw = text.trim()
			if (raw.length === 0) {
				root.appLoadMessage = "No applications found"
				root.updateFilteredModel()
				return
			}

			var lines = raw.split("\n")
			for (var i = 0; i < lines.length; ++i) {
				var line = lines[i].trim()
				if (line.length === 0) continue
				var parts = line.split("\t")
				if (parts.length < 6) continue
				allApps.append({
					name: parts[0] || "",
					icon: parts[1] || "",
					exec: parts[2] || "",
					desktopId: parts[3] || "",
					genericName: parts[4] || "",
					comment: parts.slice(5).join("\t") || ""
				})
			}

			if (allApps.count === 0) {
				root.appLoadMessage = "No applications found"
			}

			root.updateFilteredModel()
		}
	}

	Process {
		id: appScan
		stdout: appScanOut
		onExited: function(exitCode, exitStatus) {
			if (exitCode !== 0) {
				root.appsLoading = false
				root.appLoadMessage = "Application scan failed"
			}
		}
	}

	Process {
		id: appLaunch
		onExited: function(exitCode, exitStatus) {
			if (exitCode !== 0) {
				root.launchStatus = "Launch failed"
			}
		}
	}

	HyprlandFocusGrab {
		active: root.visible
		windows: launcherWindows.instances
		onCleared: root.closeLauncher()
	}

	Timer {
		id: searchFocusTimer
		interval: 20
		repeat: false
		onTriggered: {
			if (root.searchInputRef) root.searchInputRef.forceActiveFocus()
		}
	}

	Component.onCompleted: {
		refreshApplications()
		updateFilteredModel()
	}

	Variants {
		id: launcherWindows
		model: root.visible ? Quickshell.screens : []

		PanelWindow {
			id: launcherWindow
			required property var modelData

			screen: modelData
			visible: root.visible
			color: "transparent"
			focusable: root.visible
			exclusiveZone: 0
			WlrLayershell.layer: WlrLayer.Overlay
			WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

			anchors {
				left: true
				right: true
				top: true
				bottom: true
			}

			implicitWidth: modelData.width
			implicitHeight: modelData.height

			Rectangle {
				anchors.fill: parent
				color: LauncherTheme.overlay_color
				opacity: root.visible ? 1 : 0

				Behavior on opacity {
					NumberAnimation {
						duration: Animations.duration_normal
						easing.type: Animations.easing_standard
					}
				}
			}

			Rectangle {
				id: panel
				anchors.centerIn: parent
				width: Math.min(LauncherTheme.window_width, parent.width - (LauncherTheme.window_margin * 2))
				height: Math.min(LauncherTheme.window_height, parent.height - (LauncherTheme.window_margin * 2))
				radius: 18
				color: Theme.background
				border.width: LauncherTheme.border_width
				border.color: LauncherTheme.panel_border_color
				opacity: root.visible ? 1 : 0
				scale: root.visible ? 1 : Animations.dropdown_scale_closed
				y: root.visible ? 0 : Animations.dropdown_offset
				z: 1
				focus: root.visible
				clip: true

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

				Behavior on y {
					NumberAnimation {
						duration: Animations.duration_slow
						easing.type: Animations.easing_emphasized
					}
				}

				ColumnLayout {
					anchors.fill: parent
					anchors.margins: LauncherTheme.content_padding
					spacing: LauncherTheme.section_spacing

					Rectangle {
						Layout.fillWidth: true
						Layout.preferredHeight: LauncherTheme.search_height
						radius: LauncherTheme.row_radius
						color: LauncherTheme.search_color
						border.width: LauncherTheme.border_width
						border.color: searchInput.activeFocus
							? LauncherTheme.search_active_border_color
							: LauncherTheme.search_border_color

						RowLayout {
							anchors.fill: parent
							anchors.leftMargin: LauncherTheme.search_padding
							anchors.rightMargin: LauncherTheme.search_padding
							spacing: 12

							Text {
								text: ""
								color: Theme.color_text_subtle
								font.pixelSize: Theme.font_size + 6
								font.family: Theme.font_family_icon
								Layout.alignment: Qt.AlignVCenter
							}

								Item {
									Layout.fillWidth: true
									Layout.fillHeight: true

									TextInput {
										id: searchInput
										Component.onCompleted: root.searchInputRef = searchInput
										anchors.left: parent.left
										anchors.right: parent.right
										anchors.verticalCenter: parent.verticalCenter
										height: Math.max(contentHeight, Theme.font_size + 10)
										color: Theme.color_text
										font.pixelSize: Theme.font_size + 5
										font.family: Theme.font_family
									selectedTextColor: Theme.color_text
									selectionColor: "#33ffffff"
									clip: true
									selectByMouse: true
									text: root.query
									onTextChanged: {
										root.query = text
										root.selectedIndex = 0
										root.updateFilteredModel()
									}
									Keys.onDownPressed: function(event) {
										root.moveSelection(1)
										event.accepted = true
									}
									Keys.onUpPressed: function(event) {
										root.moveSelection(-1)
										event.accepted = true
									}
									Keys.onEscapePressed: function(event) {
										root.closeLauncher()
										event.accepted = true
									}
									Keys.onPressed: function(event) {
										if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
											root.launchSelected()
											event.accepted = true
										}
									}
								}

								Text {
									anchors.verticalCenter: parent.verticalCenter
									visible: searchInput.text.length === 0
									text: "Search apps"
									color: LauncherTheme.hint_color
									font.pixelSize: Theme.font_size + 5
									font.family: Theme.font_family
								}
							}
						}
					}

					Text {
						visible: root.launchStatus.length > 0
						text: root.launchStatus
						color: LauncherTheme.muted_color
						font.pixelSize: Theme.font_size
						font.family: Theme.font_family
						Layout.fillWidth: true
						elide: Text.ElideRight
					}

					Rectangle {
						Layout.fillWidth: true
						Layout.fillHeight: true
						radius: LauncherTheme.row_radius
						color: "transparent"
						border.width: 0
						clip: true

							ListView {
								id: listView
								Component.onCompleted: root.listViewRef = listView
								anchors.fill: parent
								model: filteredApps
							spacing: LauncherTheme.list_spacing
							clip: true
							currentIndex: root.selectedIndex
							boundsBehavior: Flickable.StopAtBounds

							delegate: Rectangle {
								id: row
								required property int index
								required property string name
								required property string icon
								required property string exec
								required property string genericName
								required property string comment
								readonly property bool hasImageSource: icon.indexOf("/") === 0
									|| icon.indexOf("file://") === 0
									|| icon.indexOf("qrc:/") === 0
									|| icon.indexOf("image://") === 0
								
								width: listView.width
								height: LauncherTheme.row_height
								radius: LauncherTheme.row_radius
								color: root.selectedIndex === index
									? LauncherTheme.row_selected_color
									: (rowMouse.containsMouse ? LauncherTheme.row_hover_color : LauncherTheme.row_color)

								Behavior on color {
									ColorAnimation {
										duration: Animations.duration_hover
										easing.type: Animations.easing_standard
									}
								}

								RowLayout {
									anchors.fill: parent
									anchors.leftMargin: 16
									anchors.rightMargin: 16
									spacing: 14

									Rectangle {
										Layout.alignment: Qt.AlignVCenter
										Layout.preferredWidth: LauncherTheme.icon_wrap_size
										Layout.preferredHeight: LauncherTheme.icon_wrap_size
										radius: 12
										color: LauncherTheme.icon_background_color

										Image {
											anchors.centerIn: parent
											width: LauncherTheme.icon_size
											height: LauncherTheme.icon_size
											visible: row.hasImageSource
											source: row.hasImageSource
												? (row.icon.indexOf("/") === 0 ? ("file://" + row.icon) : row.icon)
												: ""
											fillMode: Image.PreserveAspectFit
											asynchronous: true
											sourceSize.width: LauncherTheme.icon_size
											sourceSize.height: LauncherTheme.icon_size
										}

										Text {
											anchors.centerIn: parent
											visible: !row.hasImageSource
											text: row.name.length > 0 ? row.name.charAt(0).toUpperCase() : "?"
											color: Theme.color_text
											font.pixelSize: Theme.font_size + 5
											font.family: Theme.font_family
											font.bold: true
										}
									}

									ColumnLayout {
										Layout.fillWidth: true
										Layout.alignment: Qt.AlignVCenter
										spacing: 2

										Text {
											text: row.name
											color: Theme.color_text
											font.pixelSize: Theme.font_size + 3
											font.family: Theme.font_family
											elide: Text.ElideRight
											Layout.fillWidth: true
										}

										Text {
											text: row.genericName.length > 0 ? row.genericName : row.comment
											visible: text.length > 0
											color: Theme.color_text_subtle
											font.pixelSize: Theme.font_size
											font.family: Theme.font_family
											elide: Text.ElideRight
											Layout.fillWidth: true
										}
									}

									Text {
										text: row.exec
										color: LauncherTheme.muted_color
										font.pixelSize: Theme.font_size - 1
										font.family: Theme.font_family
										elide: Text.ElideLeft
										horizontalAlignment: Text.AlignRight
										Layout.preferredWidth: Math.min(220, implicitWidth)
									}
								}

								MouseArea {
									id: rowMouse
									anchors.fill: parent
									hoverEnabled: true
									cursorShape: Qt.PointingHandCursor
									onEntered: root.selectedIndex = row.index
									onClicked: {
										root.selectedIndex = row.index
										root.launchSelected()
									}
								}
							}

							ScrollBar.vertical: ScrollBar {
								policy: ScrollBar.AsNeeded
							}
						}

						Text {
							anchors.centerIn: parent
							visible: filteredApps.count === 0
							text: root.appsLoading
								? root.appLoadMessage
								: (allApps.count === 0 ? root.appLoadMessage : "No matching applications")
							color: LauncherTheme.hint_color
							font.pixelSize: Theme.font_size + 2
							font.family: Theme.font_family
						}
					}
				}

				Keys.onDownPressed: function(event) {
					root.moveSelection(1)
					event.accepted = true
				}

				Keys.onUpPressed: function(event) {
					root.moveSelection(-1)
					event.accepted = true
				}

				Keys.onPressed: function(event) {
					if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
						root.launchSelected()
						event.accepted = true
					}
				}

				Keys.onEscapePressed: function(event) {
					root.closeLauncher()
					event.accepted = true
				}
			}

			MouseArea {
				anchors.fill: parent
				acceptedButtons: Qt.LeftButton
				z: 0
				onClicked: root.closeLauncher()
			}
		}
	}
}

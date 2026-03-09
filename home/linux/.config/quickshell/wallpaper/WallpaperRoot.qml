import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Hyprland._GlobalShortcuts
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtCore
import "."
import "../constants"

pragma ComponentBehavior: Bound

Scope {
	id: root

	readonly property string wallpaperDirectory: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/share/wallpapers"
	readonly property int windowContentWidth: (WallpaperTheme.visible_preview_count * WallpaperTheme.preview_slot_width)
		+ ((WallpaperTheme.visible_preview_count - 1) * WallpaperTheme.preview_spacing)
		+ (WallpaperTheme.content_padding * 2)
	readonly property int carouselLoopCount: 200
	readonly property int virtualWallpaperCount: wallpaperModel.count > 0 ? wallpaperModel.count * carouselLoopCount : 0
	property bool selectorVisible: false
	property int selectedIndex: 0
	property int carouselIndex: 0
	property string statusText: ""
	property string pendingWallpaperPath: ""
	property string pendingWallpaperName: ""

	function wrappedIndex(index: int): int {
		if (wallpaperModel.count <= 0) return 0
		var wrapped = index % wallpaperModel.count
		return wrapped < 0 ? wrapped + wallpaperModel.count : wrapped
	}

	function baseCarouselIndex(): int {
		if (wallpaperModel.count <= 0) return 0
		return Math.floor(carouselLoopCount / 2) * wallpaperModel.count
	}

	function recenterCarousel(): void {
		if (wallpaperModel.count <= 0) {
			carouselIndex = 0
			return
		}

		carouselIndex = baseCarouselIndex() + wrappedIndex(carouselIndex)
	}

	function refreshWallpapers(): void {
		wallpaperScan.running = false
		wallpaperScan.exec([
			"bash",
			"-lc",
			"find -L \"$HOME/.local/share/wallpapers\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.bmp' \\) -printf '%f\\t%p\\n' | sort"
		])
	}

	function clampSelection(): void {
		if (wallpaperModel.count <= 0) {
			selectedIndex = 0
			carouselIndex = 0
			return
		}

		selectedIndex = wrappedIndex(selectedIndex)
	}

	function toggleSelector(): void {
		selectorVisible = !selectorVisible
		statusText = ""
		refreshWallpapers()
		clampSelection()
	}

	function moveSelection(delta: int): void {
		if (wallpaperModel.count <= 0) return
		carouselIndex += delta
		selectedIndex = wrappedIndex(carouselIndex)
		if (carouselIndex < wallpaperModel.count || carouselIndex >= (virtualWallpaperCount - wallpaperModel.count)) {
			recenterCarousel()
		}
	}

	function closeSelector(): void {
		selectorVisible = false
		statusText = ""
	}

	function selectedWallpaperPath(): string {
		if (wallpaperModel.count <= 0) return ""
		var selectedWallpaper = wallpaperModel.get(selectedIndex)
		return selectedWallpaper && selectedWallpaper.filePath ? selectedWallpaper.filePath : ""
	}

	function applySelectedWallpaper(): void {
		var path = selectedWallpaperPath()
		if (path.length === 0) {
			statusText = "No wallpaper selected"
			return
		}

		pendingWallpaperPath = path
		var selectedWallpaper = wallpaperModel.get(selectedIndex)
		pendingWallpaperName = selectedWallpaper && selectedWallpaper.fileName ? selectedWallpaper.fileName : ""
		statusText = "Applying " + pendingWallpaperName + " [" + pendingWallpaperPath + "]"
		wallpaperApply.exec([
			"bash",
			"-lc",
			"wallpaper_path='" + root.pendingWallpaperPath.replace(/'/g, "'\\''") + "'\n"
				+ "printf 'wallpaper_path=%s\\n' \"$wallpaper_path\"\n"
				+ "hyprctl hyprpaper preload \"$wallpaper_path\"\n"
				+ "hyprctl hyprpaper wallpaper ,\"$wallpaper_path\""
		])
		selectorVisible = false
	}

	GlobalShortcut {
		appid: "quickshell"
		name: "wallpaper-selector"
		description: "Open wallpaper selector"
		triggerDescription: "SUPER+SHIFT+W"
		onPressed: root.toggleSelector()
	}

	ListModel {
		id: wallpaperModel
	}

	StdioCollector {
		id: wallpaperScanOut
		waitForEnd: true
		onStreamFinished: {
			wallpaperModel.clear()

			var raw = text.trim()
			if (raw.length === 0) {
				root.statusText = "No wallpapers found in " + root.wallpaperDirectory
				root.clampSelection()
				return
			}

			var lines = raw.split("\n")
			for (var i = 0; i < lines.length; i++) {
				var parts = lines[i].split("\t")
				if (parts.length < 2) continue
				wallpaperModel.append({
					fileName: parts[0],
					filePath: parts.slice(1).join("\t")
				})
			}

			if (wallpaperModel.count > 0 && root.statusText.indexOf("No wallpapers found") === 0) {
				root.statusText = ""
			}

			root.clampSelection()
			root.recenterCarousel()
		}
	}

	Process {
		id: wallpaperScan
		stdout: wallpaperScanOut
	}

	Process {
		id: wallpaperApply
		stdout: wallpaperCommandOutput
		stderr: wallpaperCommandOutput
		onExited: function(exitCode, exitStatus) {
			if (exitCode !== 0) {
				var details = wallpaperCommandOutput.text.trim()
				root.statusText = details.length > 0 ? details : "hyprpaper apply failed"
				return
			}

			root.statusText = "Applied " + root.pendingWallpaperName
		}
	}

	StdioCollector {
		id: wallpaperCommandOutput
		waitForEnd: true
	}

	HyprlandFocusGrab {
		active: root.selectorVisible
		windows: selectorWindows.instances
		onCleared: root.closeSelector()
	}

	Variants {
		id: selectorWindows
		model: root.selectorVisible ? Quickshell.screens : []

		PanelWindow {
			id: selectorWindow
			required property var modelData

			visible: root.selectorVisible
			screen: modelData
			color: "transparent"
			focusable: root.selectorVisible
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
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.verticalCenter: parent.verticalCenter
				width: Math.min(root.windowContentWidth, parent.width - (WallpaperTheme.window_margin * 2))
				implicitHeight: WallpaperTheme.list_surface_height
				radius: WallpaperTheme.window_radius
				color: Theme.color_background
				border.width: WallpaperTheme.window_border_width
				border.color: WallpaperTheme.window_border_color

				Rectangle {
					id: listSurface
					anchors.centerIn: parent
					width: parent.width
					height: WallpaperTheme.list_surface_height
					radius: WallpaperTheme.window_radius
					color: "transparent"
					border.width: 0
					clip: false

					ListView {
						id: listView
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						anchors.leftMargin: WallpaperTheme.content_padding
						anchors.rightMargin: WallpaperTheme.content_padding
						height: WallpaperTheme.preview_slot_height
						model: root.virtualWallpaperCount
						orientation: ListView.Horizontal
						spacing: WallpaperTheme.preview_spacing
						snapMode: ListView.SnapToItem
						clip: false
						currentIndex: root.carouselIndex
						boundsBehavior: Flickable.StopAtBounds

						onCurrentIndexChanged: {
							if (currentIndex < 0 || wallpaperModel.count <= 0) return
							root.carouselIndex = currentIndex
							root.selectedIndex = root.wrappedIndex(currentIndex)
							if (currentIndex < wallpaperModel.count || currentIndex >= (root.virtualWallpaperCount - wallpaperModel.count)) {
								root.recenterCarousel()
								positionViewAtIndex(root.carouselIndex, ListView.Center)
							}
						}

						Component.onCompleted: positionViewAtIndex(root.carouselIndex, ListView.Center)

						Connections {
							target: root
							function onCarouselIndexChanged() {
								listView.positionViewAtIndex(root.carouselIndex, ListView.Center)
							}
						}

						delegate: Item {
							id: wallpaper
							required property int index
							readonly property int wallpaperIndex: root.wrappedIndex(index)
							readonly property var wallpaperItem: wallpaperModel.count > 0 ? wallpaperModel.get(wallpaperIndex) : null
							readonly property string fileName: wallpaperItem && wallpaperItem.fileName ? wallpaperItem.fileName : ""
							readonly property string filePath: wallpaperItem && wallpaperItem.filePath ? wallpaperItem.filePath : ""

							readonly property bool selected: root.selectedIndex === wallpaperIndex

							width: WallpaperTheme.preview_slot_width
							height: WallpaperTheme.preview_slot_height

							Rectangle {
								anchors.centerIn: parent
								width: WallpaperTheme.selected_preview_width
								height: WallpaperTheme.selected_preview_height
								radius: WallpaperTheme.preview_radius
								color: wallpaper.selected ? WallpaperTheme.preview_selected_color : WallpaperTheme.preview_default_color
								border.width: wallpaper.selected ? WallpaperTheme.selected_border_width : WallpaperTheme.default_border_width
								border.color: wallpaper.selected ? WallpaperTheme.preview_selected_border_color : WallpaperTheme.preview_default_border_color
								z: wallpaper.selected ? 1 : 0
								scale: wallpaper.selected ? 1 : WallpaperTheme.inactive_preview_scale
								transformOrigin: Item.Bottom

								Behavior on scale {
									enabled: !wallpaper.selected
									NumberAnimation {
										duration: Animations.duration_slow
										easing.type: Animations.easing_emphasized
									}
								}

								Image {
									anchors.fill: parent
									anchors.margins: WallpaperTheme.preview_margin
									source: "file://" + wallpaper.filePath
									fillMode: Image.PreserveAspectCrop
									asynchronous: true
									cache: false
									clip: true
								}

								Rectangle {
									anchors.left: parent.left
									anchors.right: parent.right
									anchors.bottom: parent.bottom
									anchors.margins: WallpaperTheme.preview_margin
									height: WallpaperTheme.caption_height
									radius: WallpaperTheme.caption_radius
									color: WallpaperTheme.caption_color

									Text {
										anchors.fill: parent
										anchors.leftMargin: WallpaperTheme.caption_padding
										anchors.rightMargin: WallpaperTheme.caption_padding
										text: wallpaper.fileName
										color: Theme.color_text
										font.pixelSize: Theme.font_size
										font.family: Theme.font_family
										verticalAlignment: Text.AlignVCenter
										elide: Text.ElideRight
									}
								}
							}

							MouseArea {
								anchors.fill: parent
								hoverEnabled: true
								cursorShape: Qt.PointingHandCursor
								onClicked: {
									root.carouselIndex = wallpaper.index
									root.selectedIndex = wallpaper.wallpaperIndex
								}
								onDoubleClicked: {
									root.carouselIndex = wallpaper.index
									root.selectedIndex = wallpaper.wallpaperIndex
									root.applySelectedWallpaper()
								}
							}
						}
					}
				}

				Keys.onLeftPressed: function(event) {
					root.moveSelection(-1)
					event.accepted = true
				}

				Keys.onRightPressed: function(event) {
					root.moveSelection(1)
					event.accepted = true
				}

				Keys.onPressed: function(event) {
					if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
						root.applySelectedWallpaper()
						event.accepted = true
					}
				}

				Keys.onEscapePressed: function(event) {
					root.closeSelector()
					event.accepted = true
				}

				focus: root.selectorVisible
			}
		}
	}

}

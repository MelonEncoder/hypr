import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Hyprland._GlobalShortcuts
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtCore
import "."

pragma ComponentBehavior: Bound

Scope {
	id: root

	readonly property string wallpaperDirectory: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/share/wallpapers"
	readonly property int windowContentWidth: (root.visible_preview_count * root.preview_slot_width)
		+ ((root.visible_preview_count - 1) * root.preview_spacing)
		+ (root.content_padding * 2)
	readonly property int carouselLoopCount: 200
	readonly property int virtualWallpaperCount: wallpaperModel.count > 0 ? wallpaperModel.count * carouselLoopCount : 0
	property bool selectorVisible: false
	property int selectedIndex: 0
	property int carouselIndex: 0
	property string statusText: ""
	property string pendingWallpaperPath: ""
	property string pendingWallpaperName: ""

	readonly property int window_margin: 24
	readonly property int content_padding: 8
	readonly property int content_spacing: 10
	readonly property int visible_preview_count: 3
	readonly property int preview_spacing: 12
	readonly property int preview_width: 345
	readonly property int preview_height: 230
	readonly property real selected_preview_scale: 1.16
	readonly property real inactive_preview_scale: 1 / selected_preview_scale
	readonly property int selected_preview_width: Math.round(preview_width * selected_preview_scale)
	readonly property int selected_preview_height: Math.round(preview_height * selected_preview_scale)
	readonly property int preview_slot_width: selected_preview_width
	readonly property int preview_slot_height: selected_preview_height
	readonly property int list_surface_height: preview_slot_height + (content_padding * 2)
	readonly property int preview_margin: 6
	readonly property int caption_height: 28
	readonly property int caption_padding: 8
	readonly property int window_radius: 18
	readonly property int preview_radius: 12
	readonly property int caption_radius: 0
	readonly property int window_border_width: 2
	readonly property int selected_border_width: 2
	readonly property int default_border_width: 0
	readonly property color window_color: Theme.color_background
	readonly property color window_border_color: Qt.rgba(1, 1, 1, 0.333)
	readonly property color preview_selected_color: Qt.rgba(1, 1, 1, 0.2)
	readonly property color preview_default_color: Qt.rgba(0, 0, 0, 0.078)
	readonly property color preview_selected_border_color: Qt.rgba(1, 1, 1, 1)
	readonly property color preview_default_border_color: Qt.rgba(1, 1, 1, 0.267)
	readonly property color caption_color: Qt.rgba(0, 0, 0, 0.733)

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
				width: Math.min(root.windowContentWidth, parent.width - (root.window_margin * 2))
				implicitHeight: root.list_surface_height
				radius: root.window_radius
				color: Theme.color_background
				border.width: root.window_border_width
				border.color: root.window_border_color

				Rectangle {
					id: listSurface
					anchors.centerIn: parent
					width: parent.width
					height: root.list_surface_height
					radius: root.window_radius
					color: "transparent"
					border.width: 0
					clip: false

					ListView {
						id: listView
						anchors.left: parent.left
						anchors.right: parent.right
						anchors.verticalCenter: parent.verticalCenter
						anchors.leftMargin: root.content_padding
						anchors.rightMargin: root.content_padding
						height: root.preview_slot_height
						model: root.virtualWallpaperCount
						orientation: ListView.Horizontal
						spacing: root.preview_spacing
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

							width: root.preview_slot_width
							height: root.preview_slot_height

							Rectangle {
								anchors.centerIn: parent
								width: root.selected_preview_width
								height: root.selected_preview_height
								radius: root.preview_radius
								color: wallpaper.selected ? root.preview_selected_color : root.preview_default_color
								border.width: wallpaper.selected ? root.selected_border_width : root.default_border_width
								border.color: wallpaper.selected ? root.preview_selected_border_color : root.preview_default_border_color
								z: wallpaper.selected ? 1 : 0
								scale: wallpaper.selected ? 1 : root.inactive_preview_scale
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
									anchors.margins: root.preview_margin
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
									anchors.margins: root.preview_margin
									height: root.caption_height
									radius: root.caption_radius
									color: root.caption_color

									Text {
										anchors.fill: parent
										anchors.leftMargin: root.caption_padding
										anchors.rightMargin: root.caption_padding
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

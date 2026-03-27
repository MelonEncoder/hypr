import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets
import ".."

Item {
	id: root
	property var currentPlayer: null
	property real displayPosition: 0
	// Modes: "auto" (browser => player name, media apps => track), "player", "media"
	property string label_mode: "auto"
	property var service_map: ({
		youtube: { icon: "󰗃", name: "YouTube", type: "site" },
		twitch: { icon: "󰕃", name: "Twitch", type: "site" },
		netflix: { icon: "󰝆", name: "Netflix", type: "site" },
		nebula: { icon: "", name: "Nebula", type: "site" },
		hulu: { icon: "󰠩", name: "Hulu", type: "site" },
		disneyplus: { icon: "󰨜", name: "Disney+", type: "site" },
		primevideo: { icon: "", name: "Prime Video", type: "site" },
		max: { icon: "󰨜", name: "Max", type: "site" },
		spotify: { icon: "󰓇", name: "Spotify", type: "media" },
		mpv: { icon: "󰐹", name: "mpv", type: "media" },
		vlc: { icon: "󰕼", name: "VLC", type: "media" },
		steam: { icon: "󰓓", name: "Steam", type: "media" },
		firefox: { icon: "󰈹", name: "Firefox", type: "browser" },
		zen: { icon: "󰈹", name: "Zen", type: "browser" },
		librewolf: { icon: "󰈹", name: "LibreWolf", type: "browser" },
		floorp: { icon: "󰈹", name: "Floorp", type: "browser" },
		waterfox: { icon: "󰈹", name: "Waterfox", type: "browser" },
		chromium: { icon: "", name: "Chromium", type: "browser" },
		chrome: { icon: "", name: "Chrome", type: "browser" },
		"google chrome": { icon: "", name: "Chrome", type: "browser" },
		brave: { icon: "", name: "Brave", type: "browser" },
		vivaldi: { icon: "", name: "Vivaldi", type: "browser" },
		edge: { icon: "󰇩", name: "Edge", type: "browser" },
		"microsoft edge": { icon: "󰇩", name: "Edge", type: "browser" },
		opera: { icon: "", name: "Opera", type: "browser" },
		epiphany: { icon: "󰖟", name: "Epiphany", type: "browser" },
		qutebrowser: { icon: "", name: "Qutebrowser", type: "browser" }
	})

	implicitWidth: header.implicitWidth
	implicitHeight: Theme.bar_widget_height

	function normalizeTime(value: real): real {
		// Some backends expose MPRIS time in microseconds.
		return value > 100000 ? value / 1000000 : value
	}

	function formatTime(seconds: real): string {
		var s = Math.max(0, Math.floor(seconds))
		var m = Math.floor(s / 60)
		var r = s % 60
		return m.toString() + ":" + (r < 10 ? "0" : "") + r.toString()
	}

	function mediaLabel(player: var): string {
		if (!player) return "No media"
		var title = player.trackTitle || ""
		var artist = player.trackArtist || player.trackArtists || ""
		if (title.length > 0 && artist.length > 0) return artist + "  -  " + title
		if (title.length > 0) return title
		if (artist.length > 0) return artist
		return player.identity || "Unknown"
	}

	function serviceForPlayer(player: var): var {
		if (!player) return null

		var key = ((player.desktopEntry || "") + " " + (player.identity || "")).toLowerCase()
		var keys = Object.keys(root.service_map)
		for (var i = 0; i < keys.length; i++) {
			var serviceKey = keys[i]
			if (key.indexOf(serviceKey) >= 0) {
				return root.service_map[serviceKey]
			}
		}

		return {
			icon: "󰎆",
			name: (player.identity && player.identity.length > 0) ? player.identity : "Media",
			type: "media"
		}
	}

	function browserSiteForPlayer(player: var): var {
		if (!player) return null

		var service = root.serviceForPlayer(player)
		if (!service || service.type !== "browser") return null

		var search = (
			(player.trackTitle || "") + " "
			+ (player.trackArtist || "") + " "
			+ (player.trackArtists || "") + " "
			+ (player.identity || "")
		).toLowerCase()

		if (search.indexOf("youtube") >= 0 || search.indexOf("youtu.be") >= 0) {
			return root.service_map.youtube
		}
		if (search.indexOf("twitch") >= 0 || search.indexOf("twitch.tv") >= 0) {
			return root.service_map.twitch
		}
		if (search.indexOf("netflix") >= 0 || search.indexOf("netflix.com") >= 0) {
			return root.service_map.netflix
		}
		if (search.indexOf("nebula") >= 0 || search.indexOf("nebula.tv") >= 0) {
			return root.service_map.nebula
		}
		if (search.indexOf("hulu") >= 0 || search.indexOf("hulu.com") >= 0) {
			return root.service_map.hulu
		}
		if (search.indexOf("disney+") >= 0 || search.indexOf("disneyplus") >= 0 || search.indexOf("disneyplus.com") >= 0) {
			return root.service_map.disneyplus
		}
		if (search.indexOf("prime video") >= 0 || search.indexOf("primevideo") >= 0 || search.indexOf("amazon.com") >= 0) {
			return root.service_map.primevideo
		}
		if (search.indexOf(" max ") >= 0 || search.indexOf("max.com") >= 0 || search.indexOf("hbo max") >= 0) {
			return root.service_map.max
		}

		return null
	}

	function appGlyph(player: var): string {
		var site = root.browserSiteForPlayer(player)
		if (site) return site.icon

		var service = root.serviceForPlayer(player)
		return service ? service.icon : "󰎆"
	}

	function playerLabel(player: var): string {
		if (!player) return "No media"
		var service = root.serviceForPlayer(player)
		if (service && service.name) return service.name
		return player.identity || "Unknown"
	}

	function displayLabel(player: var): string {
		if (!player) return "No media"

		if (root.label_mode === "player") return root.playerLabel(player)
		if (root.label_mode === "media") return root.mediaLabel(player)

		var site = root.browserSiteForPlayer(player)
		if (site && site.name) return site.name

		var service = root.serviceForPlayer(player)
		if (service && service.type === "browser") return root.playerLabel(player)
		return root.mediaLabel(player)
	}

	function pickPlayer(): var {
		var values = Mpris.players && Mpris.players.values ? Mpris.players.values : []
		if (!values || values.length === 0) return null

		var best = null
		var bestScore = -1
		for (var i = 0; i < values.length; i++) {
			var player = values[i]
			var service = root.serviceForPlayer(player)
			var isBrowser = service && service.type === "browser"
			var isPlaying = !!player.isPlaying
			var hasMediaInfo = ((player.trackTitle || "").length > 0) || ((player.trackArtist || "").length > 0)

			// Priority:
			// 1) Playing native media apps (mpv/spotify/etc)
			// 2) Playing browser sessions
			// 3) Paused native media apps
			// 4) Paused browser sessions
			var score = 0
			if (isPlaying && !isBrowser) score = 400
			else if (isPlaying && isBrowser) score = 300
			else if (!isPlaying && !isBrowser) score = 200
			else score = 100

			if (hasMediaInfo) score += 10

			if (score > bestScore) {
				best = player
				bestScore = score
			}
		}
		return best
	}

	function refreshPlayer(): void {
		root.currentPlayer = pickPlayer()
		if (!root.currentPlayer) {
			root.displayPosition = 0
			return
		}

		if (!root.currentPlayer.isPlaying) {
			root.displayPosition = normalizeTime(root.currentPlayer.position)
		}
	}

	function toggleCurrentPlayer(): void {
		var player = root.currentPlayer
		if (!player || !player.canControl) return

		if (player.canTogglePlaying) {
			player.togglePlaying()
			return
		}

		if (player.isPlaying && player.canPause) {
			player.pause()
			return
		}

		if (!player.isPlaying && player.canPlay) {
			player.play()
		}
	}

	Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered: {
			root.refreshPlayer()
			if (root.currentPlayer && root.currentPlayer.isPlaying) {
				root.displayPosition = root.normalizeTime(root.currentPlayer.position)
			}
		}
	}

	Component.onCompleted: refreshPlayer()

	ClippingRectangle {
		id: header
		radius: Theme.radius_normal
		color: headerMouse.pressed ? Theme.color_surface_pressed : (headerMouse.containsMouse ? Theme.color_surface_hover : Theme.color_surface)
		border.width: Theme.border_width
		border.color: Theme.color_border

		Behavior on color {
			ColorAnimation {
				duration: Animations.duration_hover
				easing.type: Animations.easing_standard
			}
		}
		
		implicitWidth: row.implicitWidth + (Theme.bar_widget_padding * 2)
		implicitHeight: Theme.bar_widget_height
		clip: true

		RowLayout {
			id: row
			anchors.fill: parent
			anchors.leftMargin: Theme.bar_widget_padding
			anchors.rightMargin: Theme.bar_widget_padding
			spacing: 6 + 1

			Text {
				text: root.appGlyph(root.currentPlayer)
				color: Theme.color_text
				font.pixelSize: Theme.font_size
				font.family: Theme.font_family_icon
			}

			Text {
				text: root.displayLabel(root.currentPlayer)
				color: Theme.color_text
				font.pixelSize: Theme.font_size
				font.family: Theme.font_family
				elide: Text.ElideRight
			}

			Text {
				text: root.currentPlayer
					? ("[" + root.formatTime(root.displayPosition) + " / " + root.formatTime(root.normalizeTime(root.currentPlayer.length)) + "]")
					: "[0:00 / 0:00]"
				visible: !!root.currentPlayer
				color: Theme.color_text_muted
				font.pixelSize: Theme.font_size
				font.family: Theme.font_family
			}
		}

		MouseArea {
			id: headerMouse
			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor
			onClicked: root.toggleCurrentPlayer()
		}
	}
}	

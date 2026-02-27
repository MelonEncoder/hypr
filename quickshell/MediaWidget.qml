import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell

Item {
	id: root
	property bool expanded: false
	property var currentPlayer: null
	property real displayPosition: 0

	implicitWidth: header.implicitWidth
	implicitHeight: Theme.widgetHeight

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

	function appGlyph(player: var): string {
		if (!player) return "󰎆"

		var key = ((player.desktopEntry || "") + " " + (player.identity || "")).toLowerCase()
		if (key.indexOf("spotify") >= 0) return "󰓇"
		if (key.indexOf("firefox") >= 0 || key.indexOf("youtube") >= 0) return "󰗃"
		if (key.indexOf("vlc") >= 0) return "󰕼"
		if (key.indexOf("mpv") >= 0) return "󰐹"
		if (key.indexOf("steam") >= 0) return "󰓓"
		return "󰎆"
	}

	function mediaLabel(player: var): string {
		if (!player) return "No media"
		var title = player.trackTitle || ""
		var artist = player.trackArtist || player.trackArtists || ""
		if (title.length > 0 && artist.length > 0) return title + " - " + artist
		if (title.length > 0) return title
		if (artist.length > 0) return artist
		return player.identity || "Unknown"
	}

	function pickPlayer(): var {
		var values = Mpris.players && Mpris.players.values ? Mpris.players.values : []
		if (!values || values.length === 0) return null

		var first = values[0]
		for (var i = 0; i < values.length; i++) {
			if (values[i].isPlaying) return values[i]
		}
		return first
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

	Rectangle {
		id: header
		radius: Theme.radius
		color: root.expanded
			? Theme.widgetBackgroundActive
			: (headerMouse.containsMouse ? Theme.widgetBackgroundHover : Theme.widgetBackgroundIdle)
		border.width: Theme.borderWidth
		border.color: Theme.surfaceBorder
		implicitWidth: row.implicitWidth + (Theme.widgetPaddingX + 2)
		implicitHeight: Theme.widgetHeight
		clip: true

		RowLayout {
			id: row
			anchors.fill: parent
			anchors.leftMargin: Theme.innerSpacing + 1
			anchors.rightMargin: Theme.innerSpacing + 1
			spacing: Theme.innerSpacing + 1

			Text {
				text: root.appGlyph(root.currentPlayer)
				color: Theme.textPrimary
				font.pixelSize: Theme.fontIconSize
				font.family: Theme.fontFamily
			}

			Text {
				text: root.mediaLabel(root.currentPlayer)
				color: Theme.textPrimary
				font.pixelSize: Theme.fontSize
				font.family: Theme.fontFamily
				elide: Text.ElideRight
			}

			Text {
				text: root.currentPlayer
					? ("[" + root.formatTime(root.displayPosition) + " / " + root.formatTime(root.normalizeTime(root.currentPlayer.length)) + "]")
					: "[0:00 / 0:00]"
				color: Theme.textMuted
				font.pixelSize: Theme.fontSize
				font.family: Theme.fontFamily
			}
		}

		MouseArea {
			id: headerMouse
			anchors.fill: parent
			hoverEnabled: true
			onClicked: root.expanded = !root.expanded
		}
	}
}	

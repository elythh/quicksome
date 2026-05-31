import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

Rectangle {
    id: mediaWidget
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: 320
    Layout.preferredHeight: Theme.widgetHeight
    radius: Theme.borderRadius
    clip: true

    property var players: Mpris.players && Mpris.players.values ? Mpris.players.values : []
    property var player: {
        let fallback = null
        for (let i = 0; i < players.length; i++) {
            const p = players[i]
            if (!p) continue
            if (p.playbackState === MprisPlaybackState.Playing) return p
            if (!fallback && p.playbackState !== MprisPlaybackState.Stopped) fallback = p
            if (!fallback) fallback = p
        }
        return fallback
    }
    property var defaultAudio: Pipewire.defaultAudio
    property bool mediaActive: player !== null && player.playbackState !== MprisPlaybackState.Stopped

    visible: player !== null

    color: Theme.bgAlt

    Image {
        anchors.fill: parent
        source: player && player.trackArtUrl ? player.trackArtUrl : ""
        fillMode: Image.PreserveAspectCrop
        visible: mediaActive && source !== ""
        smooth: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#9c000000"
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 8

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Font.DemiBold
                color: "#f5f5f5"
                text: player ? (player.trackTitle || player.identity || "Unknown") : "No media"
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: "#d0d0d0"
                text: player ? (player.trackArtist || "Unknown Artist") : ""
                elide: Text.ElideRight
                visible: mediaActive
            }
        }

        RowLayout {
            spacing: 4
            Layout.alignment: Qt.AlignVCenter

            Rectangle {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                radius: 11
                color: "#66000000"

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 12
                    color: "#f5f5f5"
                    text: "󰒮"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (player && player.canGoPrevious) player.previous()
                }
            }

            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 12
                color: "#88ffffff"

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 12
                    color: "#101010"
                    text: player && player.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!player) return
                        if (player.playbackState === MprisPlaybackState.Playing) {
                            if (player.pause) {
                                player.pause()
                            } else if (player.togglePlaying) {
                                player.togglePlaying()
                            }
                        } else {
                            if (player.play) {
                                player.play()
                            } else if (player.togglePlaying) {
                                player.togglePlaying()
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                radius: 11
                color: "#66000000"

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 12
                    color: "#f5f5f5"
                    text: "󰒭"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (player && player.canGoNext) player.next()
                }
            }
        }
    }
}

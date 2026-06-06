import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris

ClippingRectangle {
    id: root
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: 320
    Layout.preferredHeight: Theme.widgetHeight
    radius: Theme.borderRadius
    color: "#101010"

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
    property bool mediaActive: player !== null && player.playbackState !== MprisPlaybackState.Stopped

    visible: player !== null

    ClippingRectangle {
        id: artClip
        anchors.fill: parent
        radius: Theme.borderRadius
        color: "transparent"
        visible: mediaActive

        Image {
            id: artwork
            anchors.fill: parent
            source: player && player.trackArtUrl ? player.trackArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            smooth: true
            asynchronous: true
            visible: source !== ""
        }

        Rectangle {
            anchors.fill: parent
            color: "#80000000"
            visible: artwork.visible
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#80000000"
        visible: artClip.visible
    }

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        height: implicitHeight
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
                Layout.alignment: Qt.AlignVCenter
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 12
                    color: "#ffffff"
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
                Layout.alignment: Qt.AlignVCenter
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 12
                    color: "#ffffff"
                    text: player && player.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!player) return
                        if (player.playbackState === MprisPlaybackState.Playing) {
                            if (player.pause) player.pause()
                            else if (player.togglePlaying) player.togglePlaying()
                        } else {
                            if (player.play) player.play()
                            else if (player.togglePlaying) player.togglePlaying()
                        }
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                Layout.alignment: Qt.AlignVCenter
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 12
                    color: "#ffffff"
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

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Widgets

PanelWindow {
    id: mediaPopup

    property bool open: false
    property var targetScreen: null
    property var player: null

    signal requestClose()

    screen: targetScreen
    visible: open && player !== null

    implicitWidth: 530
    implicitHeight: 280

    color: "transparent"

    margins {
        right: 10
        bottom: 13
    }

    anchors {
        right: true
        bottom: true
    }

    ClippingRectangle {
        id: mediaCard
        width: 520
        height: 270
        anchors.centerIn: parent
        radius: 12
        color: Theme.bg

        // Album art background
        Image {
            id: albumArt
            anchors.fill: parent
            source: player && player.trackArtUrl ? player.trackArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            opacity: 0.3
            visible: source !== ""
            smooth: true
        }

        // Gradient overlay
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(0.05, 0.05, 0.05, 0.85) }
                GradientStop { position: 1.0; color: Qt.rgba(0.05, 0.05, 0.05, 0.15) }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // Left side - song info
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                Item { Layout.fillHeight: true }

                Text {
                    id: songName
                    Layout.fillWidth: true
                    text: {
                        if (!player) return "No Song"
                        var title = player.trackTitle || "Unknown"
                        return title.length > 30 ? title.substring(0, 30) + "..." : title
                    }
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize + 2
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Text {
                    id: artistName
                    Layout.fillWidth: true
                    text: {
                        if (!player) return ""
                        var artist = player.trackArtist || "Unknown Artist"
                        return artist.length > 22 ? artist.substring(0, 22) + "..." : artist
                    }
                    color: Theme.fgAlt
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    elide: Text.ElideRight
                }

                Item { Layout.fillHeight: true }

                Text {
                    id: playerName
                    Layout.fillWidth: true
                    text: player ? ("Playing Via: " + (player.identity || "Unknown")) : ""
                    color: Theme.fgAlt
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                }
            }

            // Right side - playback controls
            Rectangle {
                Layout.preferredWidth: 80
                Layout.fillHeight: true
                radius: 12
                color: Theme.bgAlt

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 25

                    // Previous button
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignHCenter
                        radius: 20
                        color: prevMouse.containsMouse ? Theme.accent : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        Text {
                            anchors.centerIn: parent
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 22
                            color: prevMouse.containsMouse ? Theme.bg : Theme.fg
                            text: "󰒮"
                        }

                        MouseArea {
                            id: prevMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (player) player.previous()
                            }
                        }
                    }

                    // Play/Pause button
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignHCenter
                        radius: 20
                        color: playMouse.containsMouse ? Theme.accent : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        Text {
                            anchors.centerIn: parent
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 22
                            color: playMouse.containsMouse ? Theme.bg : Theme.fg
                            text: player && player.playbackState === MprisPlaybackState.Playing ? "󰏦" : "󰐍"
                        }

                        MouseArea {
                            id: playMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (player) {
                                    if (player.canPause && player.playbackState === MprisPlaybackState.Playing) {
                                        player.pause()
                                    } else if (player.canPlay) {
                                        player.play()
                                    }
                                }
                            }
                        }
                    }

                    // Next button
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        Layout.alignment: Qt.AlignHCenter
                        radius: 20
                        color: nextMouse.containsMouse ? Theme.accent : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        Text {
                            anchors.centerIn: parent
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 22
                            color: nextMouse.containsMouse ? Theme.bg : Theme.fg
                            text: "󰒭"
                        }

                        MouseArea {
                            id: nextMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (player) player.next()
                            }
                        }
                    }
                }
            }
        }
    }
}

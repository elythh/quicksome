//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Notifications
import QtQuick.Layouts
import Quickshell.Widgets

ShellRoot {
    id: root
    property var notificationHistory: []
    property var players: Mpris.players && Mpris.players.values ? Mpris.players.values : []
    property var activePlayer: {
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
    property string lastTrackKey: ""
    property int mediaToastSequence: 0
    property string mediaToastApp: ""
    property string mediaToastTitle: ""
    property string mediaToastArtist: ""

    function pushHistoryEntry(entry) {
        const updatedHistory = [entry]
        const currentHistory = notificationHistory || []
        const maxItems = 100

        for (let i = 0; i < currentHistory.length && i < (maxItems - 1); ++i) {
            updatedHistory.push(currentHistory[i])
        }

        notificationHistory = updatedHistory
    }

    function appendNotificationHistory(notification) {
        if (!notification) return

        pushHistoryEntry({
            appName: notification.appName || "Notification",
            summary: notification.summary || "",
            body: notification.body || "",
            urgency: notification.urgency,
            timeText: Qt.formatTime(new Date(), "hh:mm")
        })
    }

    function handleMprisChange() {
        const p = activePlayer
        if (!p) return

        const title = p.trackTitle || ""
        const artist = p.trackArtist || ""
        if (title === "" && artist === "") return

        const key = (p.uniqueId || p.identity || "player") + "|" + title + "|" + artist
        if (key === lastTrackKey) return
        lastTrackKey = key

        pushHistoryEntry({
            appName: p.identity || "Media",
            summary: title || "Now playing",
            body: artist,
            urgency: NotificationUrgency.Low,
            timeText: Qt.formatTime(new Date(), "hh:mm")
        })

        mediaToastApp = p.identity || "Media"
        mediaToastTitle = title || "Now playing"
        mediaToastArtist = artist
        mediaToastSequence = mediaToastSequence + 1
    }

    onActivePlayerChanged: handleMprisChange()

    Connections {
        target: activePlayer ? activePlayer : null

        function onTrackChanged() {
            root.handleMprisChange()
        }

        function onMetadataChanged() {
            root.handleMprisChange()
        }

        function onTrackTitleChanged() {
            root.handleMprisChange()
        }

        function onTrackArtistChanged() {
            root.handleMprisChange()
        }

        function onPlaybackStateChanged() {
            root.handleMprisChange()
        }
    }

    NotificationServer {
        id: notificationServer
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: false
        bodyHyperlinksSupported: false
        imageSupported: true

        onNotification: function(notification) {
            notification.tracked = true
            root.appendNotificationHistory(notification)
        }
    }

    // Notification popup
    NotificationPopup {
        notificationServer: notificationServer
    }

    MprisToastPopup {
        toastSequence: root.mediaToastSequence
        appName: root.mediaToastApp
        title: root.mediaToastTitle
        artist: root.mediaToastArtist
    }

    VolumeOSD {}

    LockScreen {
        id: lockScreen
    }

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            property var modelData
            property bool quickMenuOpen: false
            property bool notificationHistoryOpen: false
            screen: modelData
            
            implicitHeight: 48
            anchors {
                left: true
                right: true
                bottom: true
            }

            color: "#1a1a1a"
            mask: Region { item: barrect }

            QuickMenuPopup {
                targetScreen: bar.screen
                open: bar.quickMenuOpen
                onRequestClose: bar.quickMenuOpen = false
            }

            NotificationHistoryPopup {
                targetScreen: bar.screen
                open: bar.notificationHistoryOpen
                historyItems: root.notificationHistory
                onRequestClose: bar.notificationHistoryOpen = false
                onRequestClearAll: root.notificationHistory = []
            }

            Rectangle {
                id: barrect
                anchors.fill: parent
                color: "#ee0e0e0e"
                radius: 0

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 12

                    // Left section - Launcher and workspaces
                    RowLayout {
                        spacing: 8
                        Layout.alignment: Qt.AlignLeft

                        LauncherButton {
                            iconSource: Qt.resolvedUrl("assets/icons/nixos-logo.svg")
                            tooltip: "Application Menu"
                        }

                        WorkspacesWidget {
                            id: workspaces
                            shellScreen: bar.screen
                        }

                        // Separator
                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 24
                            color: Theme.fgAlt
                            opacity: 0.3
                        }

                        CurrentWorkspaceWidget {
                            id: currentWorkspace
                        }
                    }

                    // Spacer to push right widgets to the edge
                    Item {
                        Layout.fillWidth: true
                    }

                    // Right section - System widgets
                    RowLayout {
                        id: rightSection
                        property bool trayGroupExpanded: true
                        spacing: 8
                        Layout.alignment: Qt.AlignRight
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: Theme.widgetHeight
                            Layout.preferredHeight: Theme.widgetHeight
                            radius: Theme.borderRadius
                            color: trayGroupToggleArea.containsMouse ? Theme.bgAlt : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            IconImage {
                                anchors.centerIn: parent
                                implicitSize: 16
                                source: rightSection.trayGroupExpanded
                                    ? Qt.resolvedUrl("assets/icons/tray-collapse.svg")
                                    : Qt.resolvedUrl("assets/icons/tray-expand.svg")
                            }

                            MouseArea {
                                id: trayGroupToggleArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    rightSection.trayGroupExpanded = !rightSection.trayGroupExpanded
                                }
                            }

                        }

                        SysTray {
                            parentWindow: bar
                            itemsExpanded: rightSection.trayGroupExpanded
                            showToggle: false
                            visible: rightSection.trayGroupExpanded
                        }

                        MediaWidget {
                            visible: mediaActive
                        }


                        NetworkStatusWidget {}

                        ClockWidget {
                            onClicked: {
                                bar.quickMenuOpen = !bar.quickMenuOpen
                            }
                        }

                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: Theme.widgetHeight
                            Layout.preferredHeight: Theme.widgetHeight
                            radius: Theme.borderRadius
                            color: notificationButtonMouse.containsMouse ? Theme.accent : Theme.bgAlt

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            IconImage {
                                anchors.centerIn: parent
                                implicitSize: 18
                                source: (root.notificationHistory && root.notificationHistory.length > 0)
                                    ? Qt.resolvedUrl("assets/icons/notification-bell-blue.svg")
                                    : Qt.resolvedUrl("assets/icons/notification-bell.svg")
                                opacity: notificationButtonMouse.containsMouse ? 0.95 : 0.85
                            }

                            MouseArea {
                                id: notificationButtonMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    bar.notificationHistoryOpen = !bar.notificationHistoryOpen
                                }
                            }
                        }

                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: Theme.widgetHeight
                            Layout.preferredHeight: Theme.widgetHeight
                            radius: Theme.borderRadius
                            color: powerButtonMouse.containsMouse ? Theme.red : Theme.bgAlt

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            IconImage {
                                anchors.centerIn: parent
                                implicitSize: 18
                                source: Qt.resolvedUrl("assets/icons/power.svg")
                                opacity: powerButtonMouse.containsMouse ? 0.95 : 0.85
                            }

                            MouseArea {
                                id: powerButtonMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: lockScreen.lock()
                            }
                        }
                    }
                }
            }
        }
    }
}

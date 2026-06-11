//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Io
import QtQuick.Layouts
import Quickshell.Widgets

ShellRoot {
    id: root
    property var notificationHistory: []

    property real cpuUsage: 0
    property real memUsage: 0
    property real diskUsage: 0
    property var lastCpuStats: null

    Process {
        id: cpuProcess
        running: false
        command: ["sh", "-c", "head -n1 /proc/stat"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(/\s+/)
                if (parts.length < 5) return
                
                const idle = parseInt(parts[4])
                const total = parts.slice(1).reduce((sum, val) => sum + parseInt(val), 0)
                
                if (root.lastCpuStats) {
                    const idleDelta = idle - root.lastCpuStats.idle
                    const totalDelta = total - root.lastCpuStats.total
                    if (totalDelta > 0) {
                        root.cpuUsage = Math.max(0, Math.min(100, (1 - idleDelta / totalDelta) * 100))
                    }
                }
                root.lastCpuStats = { idle: idle, total: total }
            }
        }
    }

    Process {
        id: memProcess
        running: false
        command: ["sh", "-c", "head -n3 /proc/meminfo"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n')
                let memTotal = 0, memAvail = 0
                
                lines.forEach(line => {
                    const match = line.match(/^(\w+):\s+(\d+)/)
                    if (!match) return
                    const val = parseInt(match[2])
                    if (match[1] === 'MemTotal') memTotal = val
                    else if (match[1] === 'MemAvailable') memAvail = val
                })
                
                if (memTotal > 0) {
                    root.memUsage = Math.max(0, Math.min(100, ((memTotal - memAvail) / memTotal) * 100))
                }
            }
        }
    }

    Process {
        id: diskProcess
        running: false
        command: ["df", "-h", "/"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n')
                if (lines.length < 2) return
                
                const match = lines[1].match(/(\d+)%/)
                if (match) {
                    root.diskUsage = parseInt(match[1])
                }
            }
        }
    }

    function updateSystemStats() {
        cpuProcess.running = false
        cpuProcess.running = true
        
        memProcess.running = false
        memProcess.running = true
        
        diskProcess.running = false
        diskProcess.running = true
    }

    Timer {
        id: systemStatsTimer
        interval: 15000
        running: true
        repeat: true
        onTriggered: root.updateSystemStats()
    }

    Component.onCompleted: {
        root.updateSystemStats()
    }

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
            appIcon: notification.appIcon || "",
            image: notification.image || "",
            summary: notification.summary || "",
            body: notification.body || "",
            urgency: notification.urgency,
            timeText: Qt.formatTime(new Date(), "hh:mm"),
            hasActions: notification.actions && notification.actions.length > 0
        })
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
            property bool mediaPopupOpen: false
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
                cpuUsage: root.cpuUsage
                memUsage: root.memUsage
                diskUsage: root.diskUsage
                onRequestClose: bar.notificationHistoryOpen = false
                onRequestClearAll: root.notificationHistory = []
            }

            MediaPopup {
                targetScreen: bar.screen
                open: bar.mediaPopupOpen
                player: root.activePlayer
                onRequestClose: bar.mediaPopupOpen = false
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
                            onClicked: bar.mediaPopupOpen = !bar.mediaPopupOpen
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

//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick.Layouts
import Quickshell.Widgets

ShellRoot {
    id: root
    property var notificationHistory: []

    function appendNotificationHistory(notification) {
        if (!notification) return

        const historyEntry = {
            appName: notification.appName || "Notification",
            summary: notification.summary || "",
            body: notification.body || "",
            urgency: notification.urgency,
            timeText: Qt.formatTime(new Date(), "hh:mm")
        }

        const updatedHistory = [historyEntry]
        const currentHistory = notificationHistory || []
        const maxItems = 100

        for (let i = 0; i < currentHistory.length && i < (maxItems - 1); ++i) {
            updatedHistory.push(currentHistory[i])
        }

        notificationHistory = updatedHistory
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

                        RowLayout {
                            spacing: 8
                            visible: rightSection.trayGroupExpanded

                            SysTray {
                                parentWindow: bar
                            }
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

                        SettingsButton {
                            icon: "󰂚"
                            tooltip: "Notification History"
                            iconXOffset: 1
                            iconYOffset: -1
                            onClickAction: function() {
                                bar.notificationHistoryOpen = !bar.notificationHistoryOpen
                            }
                        }

                        PowerButton {
                            icon: "󰐥"
                            tooltip: "Power Menu"
                            iconXOffset: 1
                            iconYOffset: -1
                        }
                    }
                }
            }
        }
    }
}

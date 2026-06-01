//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Hyprland
import QtQuick.Layouts
import Quickshell.Widgets

ShellRoot {
    id: root

    // Notification popup
    NotificationPopup {}
    VolumeOSD {}

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: bar
            property var modelData
            property bool quickMenuOpen: false
            screen: modelData
            
            height: 48
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

                        PowerButton {
                            icon: "󰐥"
                            tooltip: "Power Menu"
                            iconYOffset: -1
                        }
                    }
                }
            }
        }
    }
}

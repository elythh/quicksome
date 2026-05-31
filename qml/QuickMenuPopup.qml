import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire

PanelWindow {
    id: quickMenu

    property bool open: false
    property var targetScreen: null
    signal requestClose()

    screen: targetScreen
    visible: open

    implicitWidth: 320
    implicitHeight: 260

    color: "transparent"
    anchors {
        right: true
        bottom: true
    }

    property var defaultAudio: Pipewire.defaultAudio
    property bool btEnabled: false

    function setVolumeFromPosition(xPos, width) {
        if (!defaultAudio || width <= 0) return
        let value = xPos / width
        value = Math.max(0, Math.min(1, value))
        defaultAudio.volume = value
    }

    Rectangle {
        id: menuCard
        width: 300
        height: 220
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: Theme.barHeight + 10
        radius: Theme.borderRadius
        color: Theme.bg
        border.width: 1
        border.color: Theme.bgAlt

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            Text {
                text: "Quick Controls"
                color: Theme.fg
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 1
                font.weight: Font.DemiBold
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.bgAlt
                opacity: 0.8
            }

            Text {
                text: "Volume"
                color: Theme.fgAlt
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 8
                    radius: 4
                    color: Theme.bgAlt

                    Rectangle {
                        width: parent.width * (defaultAudio ? defaultAudio.volume : 0)
                        height: parent.height
                        radius: parent.radius
                        color: Theme.accent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: quickMenu.setVolumeFromPosition(mouse.x, parent.width)
                        onPositionChanged: {
                            if (pressed) {
                                quickMenu.setVolumeFromPosition(mouse.x, parent.width)
                            }
                        }
                    }
                }

                Text {
                    text: defaultAudio ? Math.round(defaultAudio.volume * 100) + "%" : "0%"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.widgetHeight
                    radius: Theme.borderRadius
                    color: Theme.bgAlt

                    Text {
                        anchors.centerIn: parent
                        text: defaultAudio && defaultAudio.muted ? "Unmute" : "Mute"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (defaultAudio) {
                                defaultAudio.muted = !defaultAudio.muted
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Theme.widgetHeight
                    radius: Theme.borderRadius
                    color: Theme.bgAlt

                    Text {
                        anchors.centerIn: parent
                        text: btEnabled ? "Bluetooth On" : "Bluetooth Off"
                        color: btEnabled ? Theme.blue : Theme.fgAlt
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            btEnabled = !btEnabled
                            Quickshell.execDetached({
                                command: ["bluetoothctl", "power", btEnabled ? "on" : "off"]
                            })
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.widgetHeight
                radius: Theme.borderRadius
                color: Theme.bgAlt

                Text {
                    anchors.centerIn: parent
                    text: "Close"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: quickMenu.requestClose()
                }
            }
        }
    }
}

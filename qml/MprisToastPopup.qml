import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

Variants {
    id: toastRoot
    model: Quickshell.screens

    property int toastSequence: 0
    property string appName: ""
    property string title: ""
    property string artist: ""

    PanelWindow {
        id: toastWindow
        property var modelData
        property int seenSequence: 0
        property bool shown: false

        screen: modelData
        visible: shown

        implicitWidth: 360
        implicitHeight: 142
        color: "transparent"

        anchors {
            right: true
            top: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.aboveWindows: true
        WlrLayershell.focusable: false

        onVisibleChanged: {
            if (!visible) return
            opacity = 0
            fadeIn.restart()
        }

        Connections {
            target: toastRoot

            function onToastSequenceChanged() {
                if (toastRoot.toastSequence <= 0 || toastRoot.toastSequence === toastWindow.seenSequence) return
                toastWindow.seenSequence = toastRoot.toastSequence
                toastWindow.shown = true
                hideTimer.restart()
            }
        }

        Timer {
            id: hideTimer
            interval: 3500
            running: false
            repeat: false
            onTriggered: toastWindow.shown = false
        }

        NumberAnimation {
            id: fadeIn
            target: toastWindow
            property: "opacity"
            from: 0
            to: 1
            duration: 220
        }

        Rectangle {
            id: mainCard
            anchors.fill: parent
            anchors.margins: 10
            radius: 8
            color: Theme.bg

            // macOS-style header bar
            Rectangle {
                id: headerBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 32
                radius: 8
                color: Theme.bgAlt

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.radius
                    color: parent.color
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 6

                    Item { Layout.fillWidth: true }

                    // Close button (red dot)
                    Rectangle {
                        Layout.preferredWidth: 12
                        Layout.preferredHeight: 12
                        Layout.alignment: Qt.AlignVCenter
                        radius: 6
                        color: closeMouseArea.containsMouse ? Qt.lighter(Theme.red, 1.2) : Theme.red
                        border.color: closeMouseArea.containsMouse ? Qt.lighter(Theme.red, 1.3) : Qt.darker(Theme.red, 1.1)
                        border.width: 0.5

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        Text {
                            anchors.centerIn: parent
                            font.family: Theme.fontFamilyMono
                            font.pixelSize: 8
                            color: closeMouseArea.containsMouse ? Theme.bg : "transparent"
                            text: "✕"
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            anchors.margins: -4
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: toastWindow.shown = false
                        }
                    }
                }
            }

            RowLayout {
                anchors.top: headerBar.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                spacing: 10

                Text {
                    Layout.alignment: Qt.AlignTop
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 20
                    color: Theme.accent
                    text: "󰎈"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        color: Theme.fgAlt
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        text: toastRoot.appName || "Media"
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 1
                        font.weight: Font.DemiBold
                        text: toastRoot.title || "Now playing"
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        color: Theme.fgAlt
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        text: toastRoot.artist || ""
                        elide: Text.ElideRight
                        visible: text !== ""
                    }
                }
            }
        }
    }
}

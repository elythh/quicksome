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
        implicitHeight: 110
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
            anchors.fill: parent
            anchors.margins: 10
            radius: Theme.borderRadius
            color: Theme.bg
            border.width: 2
            border.color: Theme.accent

            RowLayout {
                anchors.fill: parent
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

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Wayland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: osdWindow
        property var modelData
        screen: modelData

        property var defaultAudio: Pipewire.defaultAudio
        property bool shown: false
        property real volumeLevel: 0
        property bool mutedState: false
        property bool ready: false

        visible: shown
        implicitWidth: 76
        implicitHeight: screen ? screen.height : 210
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay

        anchors {
            right: true
            top: true
        }

        Connections {
            target: defaultAudio ? defaultAudio : null

            function onVolumeChanged() {
                if (!defaultAudio) return
                osdWindow.updateState(defaultAudio.volume, osdWindow.mutedState, true)
            }

            function onMutedChanged() {
                if (!defaultAudio) return
                osdWindow.updateState(osdWindow.volumeLevel, defaultAudio.muted, true)
            }

            function onTargetChanged() {
                if (defaultAudio) {
                    osdWindow.updateState(defaultAudio.volume, defaultAudio.muted, false)
                } else {
                    osdWindow.updateState(0, false, false)
                }
            }
        }

        function updateState(newVolume, newMuted, triggerPopup) {
            let volume = Math.max(0, Math.min(1, newVolume || 0))
            let muted = !!newMuted

            if (!ready) {
                volumeLevel = volume
                mutedState = muted
                ready = true
                return
            }

            const changed = Math.abs(volume - volumeLevel) > 0.0005 || muted !== mutedState
            volumeLevel = volume
            mutedState = muted

            if (triggerPopup && changed) {
                showOsd()
            }
        }

        Process {
            id: wpctlProcess
            running: false
            command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]

            stdout: StdioCollector {
                onStreamFinished: {
                    const out = (text || "").toLowerCase()
                    const match = out.match(/([0-9]*\.?[0-9]+)/)
                    const vol = match ? parseFloat(match[1]) : osdWindow.volumeLevel
                    const muted = out.indexOf("muted") !== -1
                    osdWindow.updateState(vol, muted, true)
                }
            }
        }

        Timer {
            interval: 300
            running: true
            repeat: true
            onTriggered: {
                if (!wpctlProcess.running) {
                    wpctlProcess.running = true
                }
            }
        }

        Component.onCompleted: {
            if (defaultAudio) {
                updateState(defaultAudio.volume, defaultAudio.muted, false)
            }
        }

        function showOsd() {
            shown = true
            hideTimer.restart()
        }

        Timer {
            id: hideTimer
            interval: 1400
            running: false
            repeat: false
            onTriggered: shown = false
        }

        Rectangle {
            width: 56
            height: 210
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            radius: Theme.borderRadius
            color: Theme.bg
            border.width: 1
            border.color: Theme.bgAlt
            opacity: 0.96

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: 16
                    color: Theme.fg
                    text: {
                        if (mutedState) return "󰖁"
                        if (volumeLevel > 0.6) return "󰕾"
                        if (volumeLevel > 0.3) return "󰖀"
                        if (volumeLevel > 0) return "󰕿"
                        return "󰖁"
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 10
                    Layout.fillHeight: true
                    radius: 5
                    color: Theme.bgAlt

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        radius: parent.radius
                        color: !mutedState ? Theme.accent : Theme.fgAlt
                        height: {
                            if (mutedState) return 0
                            return Math.max(0, Math.min(parent.height, parent.height * volumeLevel))
                        }

                        Behavior on height {
                            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.fg
                    text: Math.round(volumeLevel * 100) + "%"
                }
            }
        }
    }
}

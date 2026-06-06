import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland

Loader {
    id: root
    active: false

    function lock() {
        root.active = true
    }

    function unlock() {
        if (root.item) {
            root.item.unlockScreen()
        }
    }

    sourceComponent: Component {
        Item {
            id: lockContainer

            property string username: ""
            property bool pamReady: false
            property string errorMessage: ""
            property string passwordText: ""

            function unlockScreen() {
                lockSession.locked = false
                unlockTimer.start()
            }

            function tryUnlock() {
                if (!pamReady) return

                if (pam.responseRequired) {
                    if (lockContainer.passwordText !== "") {
                        pam.respond(lockContainer.passwordText)
                    }
                } else {
                    pam.start()
                }
            }

            Timer {
                id: unlockTimer
                interval: 300
                onTriggered: root.active = false
            }

            Process {
                id: whoamiProc
                command: ["whoami"]
                running: true

                stdout: StdioCollector {
                    onStreamFinished: {
                        lockContainer.username = String(text || "").trim()
                        lockContainer.pamReady = true
                    }
                }
            }

            PamContext {
                id: pam
                configDirectory: "/etc/pam.d"
                config: "login"
                user: lockContainer.username

            }

            WlSessionLock {
                id: lockSession
                locked: true

                WlSessionLockSurface {
                    Rectangle {
                        id: lockUi
                        anchors.fill: parent
                        color: Theme.bg
                        property date currentTime: new Date()

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: lockUi.currentTime = new Date()
                        }

                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Escape && event.modifiers === (Qt.ControlModifier | Qt.AltModifier)) {
                                lockContainer.unlockScreen()
                                event.accepted = true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.RightButton
                            onClicked: lockContainer.unlockScreen()
                        }

                        Connections {
                            target: pam
                            function onPamMessage() {
                                if (pam.messageIsError) {
                                    lockContainer.errorMessage = pam.message
                                } else if (pam.responseRequired) {
                                    lockContainer.errorMessage = ""
                                    if (lockContainer.passwordText !== "") {
                                        pam.respond(lockContainer.passwordText)
                                    }
                                }
                            }
                        }

                        Connections {
                            target: pam
                            function onCompleted(result) {
                                if (result === PamResult.Success) {
                                    lockContainer.unlockScreen()
                                } else {
                                    lockContainer.errorMessage = "Authentication failed"
                                    passwordInput.text = ""
                                    passwordInput.forceActiveFocus()
                                }
                            }
                        }

                        Connections {
                            target: pam
                            function onError(error) {
                                lockContainer.errorMessage = pam.message || "Authentication error"
                                passwordInput.text = ""
                            }
                        }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 24

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Theme.fontFamilyMono
                                font.pixelSize: 160
                                font.weight: Font.Bold
                                color: Theme.fg
                                text: Qt.formatTime(lockUi.currentTime, "HH:mm")
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Theme.fontFamily
                                font.pixelSize: 24
                                color: Theme.fgAlt
                                text: Qt.formatDate(lockUi.currentTime, "dddd, MMMM d")
                            }

                            Item {
                                Layout.preferredHeight: 32
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 320
                                Layout.preferredHeight: 48
                                radius: 8
                                color: Theme.bgAlt
                                border.color: passwordInput.activeFocus ? Theme.accent : Theme.bgAlt
                                border.width: passwordInput.activeFocus ? 2 : 1

                                Behavior on border.color {
                                    ColorAnimation { duration: 150 }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    Text {
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 18
                                        color: Theme.fgAlt
                                        text: "󰌋"
                                    }

                                    TextInput {
                                        id: passwordInput
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        verticalAlignment: TextInput.AlignVCenter
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 16
                                        color: Theme.fg
                                        echoMode: TextInput.Password
                                        passwordMaskDelay: 0
                                        focus: true
                                        clip: true

                                        onTextChanged: {
                                            lockContainer.errorMessage = ""
                                            lockContainer.passwordText = text
                                        }

                                        Keys.onPressed: function(event) {
                                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                                lockContainer.tryUnlock()
                                                event.accepted = true
                                            }
                                            if (event.key === Qt.Key_Escape) {
                                                passwordInput.text = ""
                                                event.accepted = true
                                            }
                                            if (event.key === Qt.Key_Escape && event.modifiers === (Qt.ControlModifier | Qt.AltModifier)) {
                                                lockContainer.unlockScreen()
                                                event.accepted = true
                                            }
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 36
                                        Layout.alignment: Qt.AlignVCenter
                                        radius: 6
                                        color: submitMouse.containsMouse ? Theme.accent : "transparent"

                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 18
                                            color: submitMouse.containsMouse ? Theme.bg : Theme.accent
                                            text: "󰌑"
                                        }

                                        MouseArea {
                                            id: submitMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: lockContainer.tryUnlock()
                                        }
                                    }
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                                color: Theme.red
                                text: lockContainer.errorMessage
                                visible: lockContainer.errorMessage !== ""
                            }
                        }
                    }
                }
            }
        }
    }
}

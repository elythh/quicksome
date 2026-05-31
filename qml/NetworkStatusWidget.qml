import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: networkStatusWidget
    Layout.preferredWidth: 80
    Layout.preferredHeight: Theme.widgetHeight
    Layout.alignment: Qt.AlignVCenter
    radius: Theme.borderRadius
    color: Theme.bgAlt

    property bool networkConnected: false
    property string networkType: "none" // ethernet, wifi, none
    property string networkName: "Disconnected"
    property bool btEnabled: false

    function refreshNetworkState() {
        networkStateProcess.running = false
        networkStateProcess.command = ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device"]
        networkStateProcess.running = true
    }

    function refreshBluetoothState() {
        bluetoothStateProcess.running = false
        bluetoothStateProcess.command = ["bluetoothctl", "show"]
        bluetoothStateProcess.running = true
    }

    function applyBluetoothPower(enabled) {
        btEnabled = enabled
        Quickshell.execDetached(["bluetoothctl", "power", enabled ? "on" : "off"])
        bluetoothRefreshDelay.restart()
    }

    Process {
        id: bluetoothStateProcess
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const out = (text || "").toLowerCase()
                networkStatusWidget.btEnabled = out.indexOf("powered: yes") !== -1
            }
        }
    }

    Process {
        id: networkStateProcess
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const output = (text || "").trim()
                let connectedType = "none"
                let connectedName = "Disconnected"
                let connected = false

                if (output.length > 0) {
                    const lines = output.split("\n")
                    for (let i = 0; i < lines.length; i++) {
                        const line = lines[i].trim()
                        if (line.length === 0) continue

                        const parts = line.split(":")
                        if (parts.length < 3) continue

                        const type = parts[0]
                        const state = parts[1]
                        const connection = parts.slice(2).join(":")

                        if (state === "connected") {
                            connected = true
                            connectedType = (type === "ethernet") ? "ethernet" : (type === "wifi" ? "wifi" : type)
                            connectedName = connection && connection.length > 0 ? connection : "Connected"
                            break
                        }
                    }
                }

                networkStatusWidget.networkConnected = connected
                networkStatusWidget.networkType = connectedType
                networkStatusWidget.networkName = connectedName
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: {
            networkStatusWidget.refreshBluetoothState()
            networkStatusWidget.refreshNetworkState()
        }
    }

    Timer {
        id: bluetoothRefreshDelay
        interval: 400
        running: false
        repeat: false
        onTriggered: networkStatusWidget.refreshBluetoothState()
    }

    Component.onCompleted: {
        refreshBluetoothState()
        refreshNetworkState()
    }

    MouseArea {
        id: networkWidgetMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            console.log("Network status clicked")
            // TODO: Open network/bluetooth settings
        }
    }

    RowLayout {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        spacing: 8

        // WiFi icon
        Text {
            font.family: Theme.fontFamilyMono
            font.pixelSize: Theme.iconSize
            color: networkConnected ? Theme.green : Theme.fgAlt
            text: {
                if (!networkConnected) return "󰤮"
                if (networkType === "ethernet") return "󰈀"
                return "󰤨"
            }
            verticalAlignment: Text.AlignVCenter
        }

        // Separator dot
        Text {
            font.family: Theme.fontFamilyMono
            font.pixelSize: 8
            color: Theme.fgAlt
            text: "•"
            verticalAlignment: Text.AlignVCenter
            opacity: 0.5
        }

        // Bluetooth icon
        Text {
            font.family: Theme.fontFamilyMono
            font.pixelSize: Theme.iconSize
            color: btEnabled ? Theme.blue : Theme.fgAlt
            text: btEnabled ? "󰂯" : "󰂲"
            verticalAlignment: Text.AlignVCenter
            
            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                onClicked: {
                    mouse.accepted = true
                    networkStatusWidget.applyBluetoothPower(!btEnabled)
                    console.log("Bluetooth power command sent:", btEnabled ? "on" : "off")
                }
                z: 1
            }
        }
    }

    Rectangle {
        visible: networkWidgetMouseArea.containsMouse
        anchors.bottom: parent.top
        anchors.bottomMargin: 6
        anchors.horizontalCenter: parent.horizontalCenter
        radius: Theme.borderRadius
        color: Theme.bg
        border.width: 1
        border.color: Theme.bgAlt
        opacity: 0.95

        width: networkNameText.implicitWidth + 14
        height: networkNameText.implicitHeight + 8

        Text {
            id: networkNameText
            anchors.centerIn: parent
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.fg
            text: networkStatusWidget.networkName
        }
    }
}

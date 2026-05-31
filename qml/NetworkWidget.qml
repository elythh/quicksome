import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: networkWidget
    Layout.preferredWidth: 60
    Layout.preferredHeight: Theme.widgetHeight
    radius: Theme.borderRadius
    color: Theme.bgAlt

    // TODO: Add actual network monitoring when Quickshell.Services.Network is available
    // For now, just show a static icon
    property bool connected: true

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            console.log("Network clicked")
            // TODO: Open network settings
        }
    }

    RowLayout {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        spacing: 4

        Text {
            font.family: Theme.fontFamilyMono
            font.pixelSize: Theme.iconSize
            color: connected ? Theme.green : Theme.fgAlt
            text: "󰤨"  // WiFi icon
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: Theme.fg
            text: connected ? "On" : "Off"
            verticalAlignment: Text.AlignVCenter
        }
    }
}

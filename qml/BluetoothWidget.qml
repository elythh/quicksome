import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: bluetoothWidget
    Layout.preferredWidth: 50
    Layout.preferredHeight: Theme.widgetHeight
    radius: Theme.borderRadius
    color: Theme.bgAlt

    // TODO: Add actual bluetooth monitoring when service is available
    property bool btEnabled: false

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
            color: btEnabled ? Theme.blue : Theme.fgAlt
            text: btEnabled ? "󰂯" : "󰂲"
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: Theme.fg
            text: btEnabled ? "On" : "Off"
            visible: false // Hide text to save space
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            btEnabled = !btEnabled
        }
    }

}

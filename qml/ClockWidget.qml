import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    Layout.preferredWidth: Math.max(120, clockRow.implicitWidth + 16)
    Layout.preferredHeight: Theme.widgetHeight
    Layout.alignment: Qt.AlignVCenter
    radius: Theme.borderRadius
    color: Theme.bgAlt

    property var currentTime: new Date()
    signal clicked()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: parent.currentTime = new Date()
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            parent.clicked()
        }
    }

    RowLayout {
        id: clockRow
        anchors.centerIn: parent
        spacing: 10

        Text {
            Layout.alignment: Qt.AlignVCenter
            font.family: Theme.fontFamilyMono
            font.pixelSize: Theme.fontSize + 3
            font.weight: Font.DemiBold
            color: Theme.fg
            text: Qt.formatTime(currentTime, "hh:mm")
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Font.Medium
            color: Theme.fgAlt
            text: Qt.formatDate(currentTime, "dd MMMM")
            verticalAlignment: Text.AlignVCenter
        }
    }
}

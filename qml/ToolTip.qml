import QtQuick

Rectangle {
    id: tooltip
    property alias text: tooltipText.text
    property bool show: false
    
    width: tooltipText.width + 16
    height: tooltipText.height + 12
    color: Theme.bg
    border.color: Theme.accent
    border.width: 1
    radius: Theme.borderRadius
    z: 1000
    
    visible: show
    opacity: show ? 1 : 0
    
    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }

    Text {
        id: tooltipText
        anchors.centerIn: parent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        color: Theme.fg
    }
}

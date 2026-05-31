import QtQuick
import QtQuick.Layouts

Rectangle {
    id: button
    
    property string icon: ""
    property string tooltip: ""
    property int iconYOffset: -1
    property var onClickAction: null
    
    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: Theme.widgetHeight
    Layout.preferredHeight: Theme.widgetHeight
    radius: Theme.borderRadius
    color: mouseArea.containsMouse ? Theme.accent : Theme.bgAlt

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    Item {
        anchors.fill: parent

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: iconYOffset
            width: Theme.iconSize
            height: Theme.iconSize
            font.family: Theme.fontFamilyMono
            font.pixelSize: Theme.iconSize
            color: mouseArea.containsMouse ? Theme.bg : Theme.fg
            text: icon
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (onClickAction) {
                onClickAction()
            }
        }
    }

}

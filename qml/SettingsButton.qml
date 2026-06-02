import QtQuick
import QtQuick.Layouts

Rectangle {
    id: button
    
    property string icon: ""
    property string tooltip: ""
    property int iconXOffset: 0
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
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenterOffset: iconXOffset
            anchors.verticalCenterOffset: iconYOffset
            font.family: Theme.fontFamilyMono
            font.pixelSize: Theme.iconSize
            color: mouseArea.containsMouse ? Theme.bg : Theme.fg
            text: icon
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

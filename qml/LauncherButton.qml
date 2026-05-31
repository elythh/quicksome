import QtQuick
import QtQuick.Layouts

Rectangle {
    id: button
    
    property string icon: ""
    property string iconSource: ""
    property string tooltip: ""
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

        Image {
            anchors.centerIn: parent
            width: Theme.iconSize
            height: Theme.iconSize
            source: iconSource
            fillMode: Image.PreserveAspectFit
            smooth: true
            visible: iconSource !== ""
        }

        Text {
            anchors.centerIn: parent
            width: Theme.iconSize
            height: Theme.iconSize
            font.family: Theme.fontFamilyMono
            font.pixelSize: Theme.iconSize
            color: mouseArea.containsMouse ? Theme.bg : Theme.fg
            text: icon
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            visible: iconSource === ""
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

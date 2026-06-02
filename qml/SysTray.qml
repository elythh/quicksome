import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

RowLayout {
    id: sysTray
    spacing: 4

    property var parentWindow: null
    property bool itemsExpanded: false
    property bool showToggle: true
    property int trayItemCount: (SystemTray.items && SystemTray.items.values) ? SystemTray.items.values.length : 0

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            required property SystemTrayItem modelData
            required property int index
            
            Layout.preferredWidth: visible ? Theme.widgetHeight : 0
            Layout.preferredHeight: Theme.widgetHeight
            radius: Theme.borderRadius
            color: mouseArea.containsMouse ? Theme.bgAlt : "transparent"
            
            // Show first 3 items always, rest only when expanded
            visible: index < 3 || itemsExpanded
            
            Behavior on Layout.preferredWidth {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Image {
                anchors.centerIn: parent
                width: Theme.iconSize
                height: Theme.iconSize
                source: modelData.icon
                sourceSize.width: Theme.iconSize
                sourceSize.height: Theme.iconSize
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                
                onClicked: (mouse) => {
                    const canShowMenu = modelData.hasMenu && parentWindow

                    if (mouse.button === Qt.LeftButton) {
                        if (!modelData.onlyMenu && modelData.activate) {
                            modelData.activate()
                        } else if (modelData.secondaryActivate) {
                            modelData.secondaryActivate()
                        } else if (canShowMenu) {
                            const menuPoint = mouseArea.mapToItem(parentWindow.contentItem || parentWindow, mouse.x, mouse.y)
                            modelData.display(parentWindow, Math.round(menuPoint.x), Math.round(menuPoint.y))
                        }
                    } else if (mouse.button === Qt.RightButton) {
                        if (canShowMenu) {
                            const menuPoint = mouseArea.mapToItem(parentWindow.contentItem || parentWindow, mouse.x, mouse.y)
                            modelData.display(parentWindow, Math.round(menuPoint.x), Math.round(menuPoint.y))
                        } else if (modelData.secondaryActivate) {
                            modelData.secondaryActivate()
                        } else if (modelData.activate) {
                            modelData.activate()
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        if (modelData.secondaryActivate) {
                            modelData.secondaryActivate()
                        } else if (modelData.activate) {
                            modelData.activate()
                        }
                    }
                }
            }

        }
    }

    // Toggle button - show if there are more than 3 items
    Rectangle {
        Layout.preferredWidth: Theme.widgetHeight
        Layout.preferredHeight: Theme.widgetHeight
        radius: Theme.borderRadius
        color: toggleMouseArea.containsMouse ? Theme.bgAlt : "transparent"
        visible: showToggle && trayItemCount > 3

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        Item {
            anchors.fill: parent

            Text {
                anchors.centerIn: parent
                width: 16
                height: 16
                font.family: Theme.fontFamilyMono
                font.pixelSize: 16
                color: itemsExpanded ? Theme.accent : Theme.fgAlt
                text: itemsExpanded ? "󰅁" : "󰅂"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
        }

        MouseArea {
            id: toggleMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                itemsExpanded = !itemsExpanded
            }
        }
    }
}

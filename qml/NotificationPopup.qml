import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

Variants {
    model: Quickshell.screens
    required property var notificationServer

    PanelWindow {
        id: notificationWindow
        property var modelData
        screen: modelData

        anchors {
            right: true
            top: true
        }

        implicitWidth: 400
        implicitHeight: notificationColumn.implicitHeight
        visible: notificationServer.trackedNotifications.values.length > 0

        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.aboveWindows: true
        WlrLayershell.focusable: false

        ColumnLayout {
            id: notificationColumn
            width: parent.width
            spacing: 12

            Repeater {
                model: notificationServer.trackedNotifications

                Rectangle {
                    required property var modelData

                    property bool hovering: cardHover.hovered || closeMouseArea.containsMouse

                    Layout.fillWidth: true
                    Layout.preferredHeight: notifContent.implicitHeight + 24

                    radius: Theme.borderRadius
                    color: Theme.bg
                    border.color: modelData.urgency === NotificationUrgency.Critical ? Theme.red : Theme.accent
                    border.width: 2

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -4
                        radius: Theme.borderRadius + 2
                        color: Theme.shadow
                        z: -1
                        opacity: 0.4
                    }

                    Timer {
                        id: dismissTimer
                        interval: modelData.expireTimeout > 0 ? modelData.expireTimeout : 5000
                        running: modelData.expireTimeout !== 0 && !parent.hovering
                        repeat: false
                        onTriggered: modelData.dismiss()
                    }

                    RowLayout {
                        id: notifContent
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Rectangle {
                            Layout.preferredWidth: 48
                            Layout.preferredHeight: 48
                            Layout.alignment: Qt.AlignTop
                            radius: Theme.borderRadius
                            color: Theme.bgAlt

                            Image {
                                anchors.centerIn: parent
                                width: 32
                                height: 32
                                source: modelData.appIcon || modelData.image || ""
                                sourceSize.width: 32
                                sourceSize.height: 32
                                visible: source !== ""
                                smooth: true
                                fillMode: Image.PreserveAspectFit
                            }

                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamilyMono
                                font.pixelSize: 24
                                color: Theme.accent
                                text: "󰂚"
                                visible: !modelData.appIcon && !modelData.image
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop
                            spacing: 4

                            Text {
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                                font.weight: Font.Medium
                                color: Theme.fgAlt
                                text: modelData.appName || "Notification"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize + 2
                                font.weight: Font.Bold
                                color: Theme.fg
                                text: modelData.summary || ""
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                                visible: text !== ""
                            }

                            Text {
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                color: Theme.fgAlt
                                text: modelData.body || ""
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                                visible: text !== ""
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                visible: modelData.actions && modelData.actions.length > 0

                                Repeater {
                                    model: modelData.actions || []

                                    Rectangle {
                                        required property var modelData

                                        Layout.preferredHeight: 28
                                        Layout.fillWidth: true
                                        radius: Theme.borderRadius
                                        color: actionMouseArea.containsMouse ? Theme.accent : Theme.bgAlt

                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.weight: Font.Medium
                                            color: actionMouseArea.containsMouse ? Theme.bg : Theme.fg
                                            text: modelData.text || "Action"
                                        }

                                        MouseArea {
                                            id: actionMouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: modelData.invoke()
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignTop
                            radius: 12
                            color: closeMouseArea.containsMouse ? Theme.red : "transparent"

                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            Text {
                                anchors.centerIn: parent
                                font.family: Theme.fontFamilyMono
                                font.pixelSize: 16
                                color: closeMouseArea.containsMouse ? Theme.bg : Theme.fgAlt
                                text: "󰅖"
                            }

                            MouseArea {
                                id: closeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.dismiss()
                            }
                        }
                    }

                    HoverHandler { id: cardHover }

                    NumberAnimation on x {
                        from: 50
                        to: 0
                        duration: 300
                        easing.type: Easing.OutCubic
                        running: true
                    }

                    NumberAnimation on opacity {
                        from: 0
                        to: 1
                        duration: 300
                        running: true
                    }
                }
            }
        }
    }
}

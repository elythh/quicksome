import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

PanelWindow {
    id: historyPopup

    property bool open: false
    property var targetScreen: null
    property var historyItems: []

    signal requestClose()
    signal requestClearAll()

    screen: targetScreen
    visible: open

    implicitWidth: 420
    implicitHeight: historyCard.height + Theme.barHeight + 20

    color: "transparent"

    anchors {
        right: true
        bottom: true
    }

    Rectangle {
        id: historyCard
        width: 400
        height: 440
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: Theme.barHeight + 10
        radius: Theme.borderRadius
        color: Theme.bg
        border.width: 1
        border.color: Theme.bgAlt
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.widgetHeight + 6

                Text {
                    anchors.left: parent.left
                    anchors.right: clearAllButton.left
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Notifications"
                    color: Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize + 2
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Rectangle {
                    id: clearAllButton
                    width: 88
                    height: Theme.widgetHeight
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: 3
                    radius: Theme.borderRadius
                    color: clearMouseArea.containsMouse ? "#ff5c72" : Theme.red
                    visible: historyItems.length > 0

                    Text {
                        anchors.centerIn: parent
                        text: "Clear all"
                        color: Theme.bg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: clearMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: historyPopup.requestClearAll()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.bgAlt
            }

            Flickable {
                id: historyFlick
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: historyColumn.implicitHeight
                clip: true

                ColumnLayout {
                    id: historyColumn
                    width: historyFlick.width
                    spacing: 8

                    Repeater {
                        model: historyItems

                        Rectangle {
                            required property var modelData

                            Layout.fillWidth: true
                            Layout.preferredHeight: itemColumn.implicitHeight + 16
                            radius: Theme.borderRadius
                            color: Theme.bgAlt
                            border.width: 1
                            border.color: modelData.urgency === NotificationUrgency.Critical ? Theme.red : "transparent"

                            ColumnLayout {
                                id: itemColumn
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.appName || "Notification"
                                        color: Theme.fgAlt
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSizeSmall
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.timeText || ""
                                        color: Theme.fgAlt
                                        font.family: Theme.fontFamilyMono
                                        font.pixelSize: Theme.fontSizeSmall
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.summary || ""
                                    color: Theme.fg
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize + 1
                                    font.weight: Font.DemiBold
                                    wrapMode: Text.Wrap
                                    visible: text !== ""
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.body || ""
                                    color: Theme.fgAlt
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                    wrapMode: Text.Wrap
                                    visible: text !== ""
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 100
                        visible: historyItems.length === 0

                        Text {
                            anchors.centerIn: parent
                            text: "No notifications yet"
                            color: Theme.fgAlt
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.widgetHeight
                radius: Theme.borderRadius
                color: closeMouseArea.containsMouse ? Theme.accent : Theme.bgAlt

                Text {
                    anchors.centerIn: parent
                    text: "Close"
                    color: closeMouseArea.containsMouse ? Theme.bg : Theme.fg
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: historyPopup.requestClose()
                }
            }
        }
    }
}

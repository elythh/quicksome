import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

PanelWindow {
    id: historyPopup

    property bool open: false
    property var targetScreen: null
    property var historyItems: []
    property real cpuUsage: 0
    property real memUsage: 0
    property real diskUsage: 0

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

    ClippingRectangle {
        id: historyCard
        width: 400
        height: 700
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: Theme.barHeight + 10
        radius: 8
        color: Theme.bg

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: Theme.bgAlt

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        color: Theme.fg
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 2
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignLeft
                    }

                    Text {
                        font.family: Theme.fontFamilyMono
                        font.pixelSize: 26
                        color: clearHover.containsMouse ? Theme.red : Theme.fgAlt
                        text: "󰎟"
                        visible: historyItems.length > 0

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        MouseArea {
                            id: clearHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: historyPopup.requestClearAll()
                        }
                    }
                }
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

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                    }

                    Repeater {
                        model: historyItems

                        Rectangle {
                            required property var modelData

                            Layout.fillWidth: true
                            Layout.leftMargin: 20
                            Layout.rightMargin: 20
                            Layout.preferredHeight: itemColumn.implicitHeight + 16
                            radius: 4
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
                                    spacing: 10

                                    Rectangle {
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 36
                                        Layout.alignment: Qt.AlignTop
                                        radius: Theme.borderRadius
                                        color: Theme.bgAlt

                                        property bool iconLoaded: false

                                        Image {
                                            id: iconImage
                                            anchors.centerIn: parent
                                            width: 24
                                            height: 24
                                            source: {
                                                var s = modelData.appIcon || modelData.image || ""
                                                if (s.length === 0) return ""
                                                if (s[0] === '/' || s.indexOf('://') > 0) return s
                                                
                                                // Try lowercase for better icon matching
                                                var iconName = s.toLowerCase()
                                                return "image://icon/" + iconName
                                            }
                                            sourceSize.width: 24
                                            sourceSize.height: 24
                                            visible: parent.iconLoaded
                                            smooth: true
                                            fillMode: Image.PreserveAspectFit
                                            
                                            onStatusChanged: {
                                                if (status === Image.Ready) {
                                                    parent.iconLoaded = true
                                                } else if (status === Image.Error || status === Image.Null) {
                                                    parent.iconLoaded = false
                                                }
                                            }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            font.family: Theme.fontFamilyMono
                                            font.pixelSize: 18
                                            color: Theme.accent
                                            text: "󰂚"
                                            visible: !parent.iconLoaded
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

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

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 28
                                            Layout.topMargin: 4
                                            radius: Theme.borderRadius
                                            color: openButtonMouse.containsMouse ? Theme.accent : Theme.bg
                                            visible: modelData.hasActions || false

                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Open"
                                                color: openButtonMouse.containsMouse ? Theme.bg : Theme.fg
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize
                                                font.weight: Font.Medium
                                            }

                                            MouseArea {
                                                id: openButtonMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    const appName = modelData.appName || ""
                                                    const appLower = appName.toLowerCase()
                                                    
                                                    // Try to launch the app
                                                    if (appLower.indexOf("firefox") >= 0) {
                                                        Quickshell.execDetached(["firefox"])
                                                    } else if (appLower.indexOf("chrome") >= 0 || appLower.indexOf("chromium") >= 0) {
                                                        Quickshell.execDetached(["google-chrome-stable"])
                                                    } else if (appLower.indexOf("slack") >= 0) {
                                                        Quickshell.execDetached(["slack"])
                                                    } else if (appLower.indexOf("discord") >= 0) {
                                                        Quickshell.execDetached(["discord"])
                                                    } else if (appLower.indexOf("telegram") >= 0) {
                                                        Quickshell.execDetached(["telegram-desktop"])
                                                    } else {
                                                        // Try launching the app name directly
                                                        Quickshell.execDetached([appName])
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 400
                        visible: historyItems.length === 0

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 20

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "No Notifications"
                                color: Theme.fg
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize + 2
                                horizontalAlignment: Text.AlignHCenter
                            }

                            Image {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 250
                                Layout.preferredHeight: 250
                                source: Qt.resolvedUrl("assets/wedding-bells.png")
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 170
                color: Theme.bgAlt

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 30
                    anchors.rightMargin: 30
                    anchors.topMargin: 30
                    anchors.bottomMargin: 40
                    spacing: 30

                    // CPU
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 30

                        Text {
                            Layout.preferredWidth: 50
                            text: "CPU"
                            color: Theme.fgAlt
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignCenter
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            radius: 5
                            color: "#33f7768e"

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: Math.max(0, Math.min(parent.width * (historyPopup.cpuUsage / 100), parent.width))
                                radius: 5
                                color: Theme.red

                                Behavior on width {
                                    NumberAnimation { duration: 300 }
                                }
                            }
                        }
                    }

                    // MEM
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 30

                        Text {
                            Layout.preferredWidth: 50
                            text: "MEM"
                            color: Theme.fgAlt
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignCenter
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            radius: 5
                            color: "#337aa2f7"

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: Math.max(0, Math.min(parent.width * (historyPopup.memUsage / 100), parent.width))
                                radius: 5
                                color: Theme.accent

                                Behavior on width {
                                    NumberAnimation { duration: 300 }
                                }
                            }
                        }
                    }

                    // DIS
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 30

                        Text {
                            Layout.preferredWidth: 50
                            text: "DIS"
                            color: Theme.fgAlt
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            horizontalAlignment: Text.AlignCenter
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            radius: 5
                            color: "#33bb9af7"

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: Math.max(0, Math.min(parent.width * (historyPopup.diskUsage / 100), parent.width))
                                radius: 5
                                color: "#bb9af7"

                                Behavior on width {
                                    NumberAnimation { duration: 300 }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

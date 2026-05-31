import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

RowLayout {
    id: volumeWidget
    spacing: 6
    visible: defaultAudio !== null

    property var defaultAudio: Pipewire.defaultAudio

    Rectangle {
        Layout.preferredWidth: 60
        Layout.preferredHeight: Theme.widgetHeight
        radius: Theme.borderRadius
        color: Theme.bgAlt

        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("Volume clicked")
                if (defaultAudio) {
                    defaultAudio.muted = !defaultAudio.muted
                }
            }
            cursorShape: Qt.PointingHandCursor
        }

        RowLayout {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            spacing: 4

            Text {
                id: volumeIcon
                font.family: Theme.fontFamilyMono
                font.pixelSize: Theme.iconSize
                color: {
                    if (defaultAudio === null || defaultAudio.muted) return Theme.volumeMuted
                    let vol = defaultAudio.volume
                    if (vol > 0.6) return Theme.volumeHigh
                    else if (vol > 0.3) return Theme.volumeMid
                    else return Theme.volumeLow
                }
                text: {
                    if (defaultAudio === null || defaultAudio.muted) return "󰖁"
                    let vol = defaultAudio.volume
                    if (vol > 0.6) return "󰕾"
                    else if (vol > 0.3) return "󰖀"
                    else if (vol > 0) return "󰕿"
                    else return "󰖁"
                }
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                color: Theme.fg
                text: defaultAudio ? Math.round(defaultAudio.volume * 100) + "%" : "0%"
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
}

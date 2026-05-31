import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: batteryWidget
    Layout.preferredWidth: 70
    Layout.preferredHeight: Theme.widgetHeight
    radius: Theme.borderRadius
    color: Theme.bgAlt
    visible: false  // TODO: Enable when Upower service is available

    // TODO: Add actual battery monitoring when Quickshell.Services.Upower is available
    property int percentage: 75
    property bool charging: false

    RowLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 4

        Text {
            font.family: Theme.fontFamilyMono
            font.pixelSize: Theme.iconSize
            color: {
                if (charging) return Theme.green
                if (percentage > 60) return Theme.batteryHigh
                else if (percentage > 30) return Theme.batteryMid
                else if (percentage > 15) return Theme.batteryLow
                else return Theme.batteryCritical
            }
            text: {
                if (charging) return "󰂄"
                if (percentage >= 90) return "󰁹"
                else if (percentage >= 80) return "󰂂"
                else if (percentage >= 70) return "󰂁"
                else if (percentage >= 60) return "󰂀"
                else if (percentage >= 50) return "󰁿"
                else if (percentage >= 40) return "󰁾"
                else if (percentage >= 30) return "󰁽"
                else if (percentage >= 20) return "󰁼"
                else if (percentage >= 10) return "󰁻"
                else return "󰁺"
            }
        }

        Text {
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: Theme.fg
            text: percentage + "%"
        }
    }
}

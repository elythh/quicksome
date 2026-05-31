import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

RowLayout {
    id: taskbar
    spacing: 4

    function focusAddress(address) {
        if (!address || address.length === 0) return
        const normalized = address.startsWith("0x") ? address : ("0x" + address)
        Hyprland.dispatch("focuswindow address:" + normalized)
    }

    function iconSourceFromName(iconName) {
        if (!iconName || iconName.length === 0) return ""
        if (iconName.indexOf("/") !== -1 || iconName.indexOf(":") !== -1) return iconName
        return "image://icon/" + iconName
    }

    function iconSourceFor(toplevel) {
        if (!toplevel) return ""

        const appId = toplevel.wayland && toplevel.wayland.appId ? toplevel.wayland.appId : ""
        const className = toplevel.lastIpcObject && toplevel.lastIpcObject.class ? toplevel.lastIpcObject.class : ""

        const candidates = []
        if (appId) {
            candidates.push(appId)
            candidates.push(appId.toLowerCase())
        }
        if (className) {
            candidates.push(className)
            candidates.push(className.toLowerCase())
        }

        for (let i = 0; i < candidates.length; i++) {
            const entry = DesktopEntries.heuristicLookup(candidates[i])
            if (entry && entry.icon && entry.icon.length > 0) {
                return iconSourceFromName(entry.icon)
            }
        }

        if (appId) return iconSourceFromName(appId.toLowerCase())
        if (className) return iconSourceFromName(className.toLowerCase())
        return ""
    }

    Repeater {
        model: Hyprland.toplevels

        Rectangle {
            required property HyprlandToplevel modelData
            property string resolvedIconSource: taskbar.iconSourceFor(modelData)
            
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: Theme.borderRadius
            
            property bool isActive: modelData.activated
            
            color: {
                if (isActive) return Theme.accent
                else if (mouseArea.containsMouse) return Theme.bgAlt
                else return "transparent"
            }

            border.width: isActive ? 0 : 1
            border.color: Theme.fgAlt

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            IconImage {
                anchors.centerIn: parent
                implicitSize: 20
                source: resolvedIconSource
                visible: resolvedIconSource !== ""
            }

            Text {
                anchors.centerIn: parent
                font.family: Theme.fontFamilyMono
                font.pixelSize: 16
                color: isActive ? Theme.bg : Theme.fg
                text: {
                    let appId = modelData.wayland && modelData.wayland.appId ? modelData.wayland.appId : ""
                    let className = modelData.lastIpcObject && modelData.lastIpcObject.class ? modelData.lastIpcObject.class : ""
                    let name = appId || className || modelData.title || "?"
                    return name.substring(0, 1).toUpperCase()
                }
                visible: resolvedIconSource === ""
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    taskbar.focusAddress(modelData.address)
                }
            }

        }
    }
}

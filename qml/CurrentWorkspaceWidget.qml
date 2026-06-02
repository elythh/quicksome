import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets

RowLayout {
    id: currentWorkspaceWindows
    spacing: 4

    function currentWorkspaceId() {
        return Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
    }

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

        const aliases = {
            "spotify": "spotify-client",
            "zen-beta": "zen-browser",
            "code-url-handler": "visual-studio-code"
        }

        function pushCandidate(list, raw) {
            if (!raw || raw.length === 0) return
            const trimmed = raw.toLowerCase().trim()
            if (trimmed.length === 0) return
            if (list.indexOf(trimmed) === -1) list.push(trimmed)

            const strippedDesktop = trimmed.endsWith(".desktop") ? trimmed.slice(0, -8) : trimmed
            if (list.indexOf(strippedDesktop) === -1) list.push(strippedDesktop)

            const strippedSuffixes = strippedDesktop
                .replace(/-beta$/g, "")
                .replace(/-bin$/g, "")
                .replace(/-git$/g, "")
                .replace(/-wayland$/g, "")
            if (list.indexOf(strippedSuffixes) === -1) list.push(strippedSuffixes)

            if (aliases[strippedDesktop] && list.indexOf(aliases[strippedDesktop]) === -1) {
                list.push(aliases[strippedDesktop])
            }
        }

        const candidates = []
        pushCandidate(candidates, appId)
        pushCandidate(candidates, className)

        for (let i = 0; i < candidates.length; i++) {
            const entry = DesktopEntries.heuristicLookup(candidates[i])
            if (entry && entry.icon && entry.icon.length > 0) {
                return iconSourceFromName(entry.icon)
            }
        }

        for (let i = 0; i < candidates.length; i++) {
            const iconCandidate = iconSourceFromName(candidates[i])
            if (iconCandidate !== "") return iconCandidate
        }

        return ""
    }

    Repeater {
        model: Hyprland.toplevels

        delegate: Rectangle {
            required property HyprlandToplevel modelData
            
            // Only show if window is in current workspace
            visible: modelData.workspace && modelData.workspace.id === currentWorkspaceWindows.currentWorkspaceId()
            
            Layout.preferredWidth: visible ? 32 : 0
            Layout.preferredHeight: 32
            radius: Theme.borderRadius
            
            property bool isActive: modelData.activated
            property string resolvedIconSource: currentWorkspaceWindows.iconSourceFor(modelData)
            
            color: {
                if (isActive) return Theme.accent
                else return Theme.bgAlt
            }

            border.width: 0

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            IconImage {
                id: appIcon
                anchors.centerIn: parent
                implicitSize: 20
                source: resolvedIconSource
                visible: resolvedIconSource !== ""
            }

            Text {
                anchors.centerIn: parent
                width: 20
                height: 20
                font.family: Theme.fontFamilyMono
                font.pixelSize: 16
                font.weight: Font.Bold
                color: isActive ? Theme.bg : Theme.fg
                text: {
                    let appId = modelData.wayland && modelData.wayland.appId ? modelData.wayland.appId : ""
                    let className = modelData.lastIpcObject && modelData.lastIpcObject.class ? modelData.lastIpcObject.class : ""
                    let name = appId || className || modelData.title || "?"
                    return name.substring(0, 1).toUpperCase()
                }
                visible: resolvedIconSource === ""
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    console.log("Focusing toplevel:", modelData.title, "address:", modelData.address)
                    currentWorkspaceWindows.focusAddress(modelData.address)
                }
            }

        }
    }
}

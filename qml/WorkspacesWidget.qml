import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: workspaceWidget

    property var shellScreen: null
    property int workspaceCount: 5

    Layout.alignment: Qt.AlignVCenter
    Layout.preferredWidth: workspacesRow.implicitWidth + 12
    Layout.preferredHeight: Theme.widgetHeight
    radius: Theme.borderRadius
    color: Theme.bgAlt

    function currentMonitor() {
        return shellScreen ? Hyprland.monitorFor(shellScreen) : null
    }

    function belongsToCurrentMonitor(workspace, monitor) {
        if (!monitor || !workspace || !workspace.monitor) return true

        if (workspace.monitor.id !== undefined && monitor.id !== undefined) {
            return workspace.monitor.id === monitor.id
        }

        if (workspace.monitor.name && monitor.name) {
            return workspace.monitor.name === monitor.name
        }

        return true
    }

    function sortedMonitorWorkspaces(monitor) {
        const all = Hyprland.workspaces && Hyprland.workspaces.values ? Hyprland.workspaces.values : []
        const filtered = []

        for (let i = 0; i < all.length; i++) {
            const ws = all[i]
            if (belongsToCurrentMonitor(ws, monitor)) {
                filtered.push(ws)
            }
        }

        filtered.sort((a, b) => a.id - b.id)
        return filtered
    }

    function baseWorkspaceId(monitor, monitorWorkspaces) {
        if (monitorWorkspaces.length > 0) {
            const minId = monitorWorkspaces[0].id
            return Math.floor((minId - 1) / workspaceCount) * workspaceCount + 1
        }

        if (monitor && monitor.id !== undefined && monitor.id > 0) {
            return ((monitor.id - 1) * workspaceCount) + 1
        }

        return 1
    }

    function workspaceById(list, id) {
        for (let i = 0; i < list.length; i++) {
            if (list[i].id === id) return list[i]
        }
        return null
    }

    function hasWorkspaceWindows(workspaceId) {
        const toplevels = Hyprland.toplevels && Hyprland.toplevels.values ? Hyprland.toplevels.values : []
        for (let i = 0; i < toplevels.length; i++) {
            const tl = toplevels[i]
            if (tl && tl.workspace && tl.workspace.id === workspaceId) {
                return true
            }
        }
        return false
    }

    property var visibleWorkspaces: {
        const monitor = currentMonitor()
        const monitorWorkspaces = sortedMonitorWorkspaces(monitor)
        const startId = baseWorkspaceId(monitor, monitorWorkspaces)
        const slots = []

        for (let i = 0; i < workspaceCount; i++) {
            const id = startId + i
            slots.push({
                id: id,
                workspace: workspaceById(monitorWorkspaces, id)
            })
        }

        return slots
    }

    RowLayout {
        id: workspacesRow
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Repeater {
            model: visibleWorkspaces

            Rectangle {
                required property var modelData

                property var monitor: workspaceWidget.currentMonitor()
                property bool isActive: !!(monitor && monitor.activeWorkspace && monitor.activeWorkspace.id === modelData.id)
                property bool hasWindows: workspaceWidget.hasWorkspaceWindows(modelData.id)

                Layout.preferredWidth: {
                    if (isActive) return 40
                    if (hasWindows) return 30
                    return 18
                }
                Layout.preferredHeight: 12

                radius: height / 2

                color: {
                    if (isActive) return Theme.workspaceActive
                    if (hasWindows) return Theme.workspaceOccupied
                    return Theme.workspaceInactive
                }

                opacity: {
                    if (isActive) return 1.0
                    if (hasWindows) return 0.8
                    return 0.5
                }

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: {
                        console.log("Workspace clicked:", modelData.id)
                        Hyprland.dispatch("workspace " + modelData.id.toString())
                    }

                    onEntered: {
                        parent.opacity = 1.0
                    }

                    onExited: {
                        if (!parent.isActive) {
                            parent.opacity = parent.hasWindows ? 0.8 : 0.5
                        }
                    }
                }
            }
        }
    }
}

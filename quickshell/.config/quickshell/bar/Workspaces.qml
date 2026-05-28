import QtQuick
import Quickshell.Hyprland
import ".."

Row {
    id: root

    readonly property int minWorkspaceCount: 5
    readonly property var workspaceIds: {
        const ids = [];
        for (let i = 1; i <= minWorkspaceCount; i++) ids.push(i);
        const extra = [];
        for (const w of Hyprland.workspaces.values) {
            if (w.id > minWorkspaceCount && extra.indexOf(w.id) === -1) extra.push(w.id);
        }
        extra.sort((a, b) => a - b);
        return ids.concat(extra);
    }

    spacing: 3

    Repeater {
        model: root.workspaceIds

        Item {
            required property var modelData
            readonly property int wsId: modelData
            readonly property var ws: Hyprland.workspaces.values.find(w => w.id === wsId)
            readonly property bool isActive: Hyprland.focusedWorkspace?.id === wsId
            readonly property bool exists: ws !== undefined

            width: Math.max(18, label.implicitWidth + 12)
            height: 22

            Text {
                id: label
                anchors.centerIn: parent
                text: parent.wsId
                color: parent.isActive ? Theme.accentColor : Theme.fgColor
                opacity: parent.isActive ? 1.0 : (parent.exists ? 1.0 : 0.4)
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: parent.isActive
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch('hl.dsp.focus({workspace = ' + parent.wsId + '})')
            }
        }
    }
}

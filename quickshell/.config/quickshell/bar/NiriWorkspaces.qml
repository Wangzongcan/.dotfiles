import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Row {
    id: root

    property var workspaces: []

    spacing: 3

    function refresh() {
        if (!Compositor.isNiri || refreshProc.running) return;
        refreshProc.running = true;
    }

    function applyWorkspaces(text) {
        try {
            const parsed = JSON.parse(text || "[]");
            root.workspaces = parsed
                .map(w => ({
                    id: w.id,
                    idx: w.idx ?? w.index ?? w.id,
                    name: w.name ?? "",
                    active: w.is_active === true || w.is_focused === true,
                    urgent: w.is_urgent === true,
                    output: w.output ?? "",
                }))
                .sort((a, b) => a.idx - b.idx);
        } catch (e) {
            root.workspaces = [];
        }
    }

    Timer {
        running: Compositor.isNiri
        repeat: true
        interval: 1000
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: refreshProc
        command: ["niri", "msg", "-j", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: root.applyWorkspaces(this.text)
        }
    }

    Repeater {
        model: root.workspaces

        Item {
            required property var modelData
            readonly property string labelText: modelData.name !== "" ? modelData.name : String(modelData.idx)

            width: Math.max(18, label.implicitWidth + 12)
            height: 22

            Text {
                id: label
                anchors.centerIn: parent
                text: parent.labelText
                color: parent.modelData.active ? Theme.accentColor : Theme.fgColor
                opacity: parent.modelData.active ? 1.0 : 0.75
                font.pixelSize: Theme.fontSize
                font.family: Theme.fontFamily
                font.bold: parent.modelData.active
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(parent.modelData.idx)]);
                    root.refresh();
                }
            }
        }
    }
}

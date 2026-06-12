import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/wallpapers"
    property var wallpapers: []
    property int currentIndex: 0
    property string currentPath: wallpapers.length > 0 ? wallpaperDir + "/" + wallpapers[currentIndex] : ""
    property int fadeDuration: 700
    property int autoCycleMs: 30 * 60 * 1000   // 30 min; set to 0 to disable

    function next() {
        if (wallpapers.length === 0) return;
        currentIndex = (currentIndex + 1) % wallpapers.length;
    }
    function previous() {
        if (wallpapers.length === 0) return;
        currentIndex = (currentIndex - 1 + wallpapers.length) % wallpapers.length;
    }
    function pickRandom() {
        if (wallpapers.length <= 1) return;
        let i = currentIndex;
        while (i === currentIndex) {
            i = Math.floor(Math.random() * wallpapers.length);
        }
        currentIndex = i;
    }
    function setDir(path) {
        wallpaperDir = path;
        scanProc.running = false;
        scanProc.running = true;
    }

    Process {
        id: scanProc
        command: ["bash", "-c",
            "find \"$DIR\" -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) -printf '%P\\n' | sort"
        ]
        environment: ({ "DIR": root.wallpaperDir })
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const list = text.split("\n").filter(s => s.length > 0);
                root.wallpapers = list;
                if (root.currentIndex >= list.length) root.currentIndex = 0;
            }
        }
    }

    Component.onCompleted: scanProc.running = true

    Timer {
        interval: root.autoCycleMs
        running: root.autoCycleMs > 0 && root.wallpapers.length > 1
        repeat: true
        onTriggered: root.pickRandom()
    }

    IpcHandler {
        target: "wallpaper"
        function next(): void { root.next(); }
        function prev(): void { root.previous(); }
        function random(): void { root.pickRandom(); }
        function setDir(path: string): void { root.setDir(path); }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: wp
            required property var modelData
            screen: modelData

            anchors { top: true; left: true; right: true; bottom: true }
            exclusiveZone: -1
            color: "#000000"
            WlrLayershell.layer: WlrLayershell.Background
            WlrLayershell.keyboardFocus: WlrLayershell.None

            // explicit state, mutated by JS only
            property string sourceA: ""
            property string sourceB: ""
            property real opA: 0
            property real opB: 0
            property string pendingA: ""
            property string pendingB: ""

            function applyPath(path) {
                if (path.length === 0) return;
                // first time
                if (sourceA === "" && sourceB === "") {
                    sourceA = path;
                    pendingA = path;
                    return;
                }
                // pick the inactive layer to load into
                if (opA >= opB) {
                    pendingB = path;
                    sourceB = path;
                } else {
                    pendingA = path;
                    sourceA = path;
                }
            }

            Connections {
                target: root
                function onCurrentPathChanged() { wp.applyPath(root.currentPath); }
            }

            Component.onCompleted: applyPath(root.currentPath)

            Image {
                id: imgA
                anchors.fill: parent
                source: wp.sourceA
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                cache: true
                opacity: wp.opA
                Behavior on opacity {
                    NumberAnimation { duration: root.fadeDuration; easing.type: Easing.InOutQuad }
                }
                onStatusChanged: {
                    if (status === Image.Ready && wp.pendingA !== "" && source.toString().indexOf(wp.pendingA) !== -1) {
                        wp.opA = 1;
                        wp.opB = 0;
                        wp.pendingA = "";
                    }
                }
            }

            Image {
                id: imgB
                anchors.fill: parent
                source: wp.sourceB
                fillMode: Image.PreserveAspectCrop
                smooth: true
                asynchronous: true
                cache: true
                opacity: wp.opB
                Behavior on opacity {
                    NumberAnimation { duration: root.fadeDuration; easing.type: Easing.InOutQuad }
                }
                onStatusChanged: {
                    if (status === Image.Ready && wp.pendingB !== "" && source.toString().indexOf(wp.pendingB) !== -1) {
                        wp.opB = 1;
                        wp.opA = 0;
                        wp.pendingB = "";
                    }
                }
            }
        }
    }
}

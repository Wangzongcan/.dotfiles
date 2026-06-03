import QtQuick
import Quickshell
import Quickshell.Io
import ".."

Item {
    id: root

    required property var bar

    property bool popupOpen: false
    property real anchorRight: 0
    property var monitorInfo: []

    Process {
        id: monitorQuery
        command: ["hyprctl", "monitors", "-j"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.monitorInfo = JSON.parse(text);
                } catch (e) {
                    root.monitorInfo = [];
                }
            }
        }
    }

    function refreshMonitors() {
        monitorQuery.running = false;
        monitorQuery.running = true;
    }

    Connections {
        target: bar
        function onCloseAllPopups() {
            root.popupOpen = false;
        }
    }

    function toggle() {
        if (popupOpen) {
            popupOpen = false;
            return;
        }
        bar.closeAllPopups();
        refreshMonitors();
        const pos = mapToItem(bar.contentItem, width, 0);
        anchorRight = pos.x;
        popupOpen = true;
    }

    Component.onCompleted: refreshMonitors()

    width: Math.max(12, icon.implicitWidth) + 15
    height: 22

    Text {
        id: icon
        anchors.centerIn: parent
        text: "󰍹"
        color: Theme.fgColor
        font.pixelSize: Theme.fontSize + 2
        font.family: Theme.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggle()
    }

    PopupWindow {
        id: popup

        visible: root.popupOpen

        anchor {
            window: root.bar
            rect.x: root.anchorRight - popup.width
            rect.y: root.bar.height
        }

        implicitWidth: 280
        implicitHeight: dispBg.implicitHeight
        color: "transparent"

        Rectangle {
            id: dispBg
            anchors.fill: parent
            color: Theme.bgColor
            border.color: Theme.border
            border.width: 1
            radius: 6
            implicitHeight: dispCol.implicitHeight + 8

            Column {
                id: dispCol
                x: 4
                y: 4
                width: parent.width - 8
                spacing: 0

                Repeater {
                    model: root.monitorInfo

                    Column {
                        id: monBlock
                        required property var modelData
                        width: dispCol.width
                        spacing: 0

                        Text {
                            width: parent.width
                            leftPadding: 8
                            topPadding: 4
                            bottomPadding: 2
                            text: monBlock.modelData.name + "  ·  current: "
                                + monBlock.modelData.width + "x" + monBlock.modelData.height
                                + "@" + Math.round(monBlock.modelData.refreshRate) + "Hz"
                            color: Qt.darker(Theme.fgColor, 1.4)
                            font.pixelSize: Theme.fontSize - 1
                            font.family: Theme.fontFamily
                        }

                        Repeater {
                            model: monBlock.modelData.availableModes

                            Item {
                                id: modeItem
                                required property var modelData
                                readonly property string mode: modelData
                                width: dispCol.width
                                height: 22

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: modeArea.containsMouse
                                        ? Qt.lighter(Theme.bgColor, 1.7)
                                        : "transparent"

                                    Text {
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        leftPadding: 12
                                        text: modeItem.mode
                                        color: Theme.fgColor
                                        font.pixelSize: Theme.fontSize
                                        font.family: Theme.fontFamily
                                    }

                                    MouseArea {
                                        id: modeArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            const expr = 'hl.monitor({output = "'
                                                + monBlock.modelData.name
                                                + '", mode = "' + modeItem.mode
                                                + '", position = "auto", scale = '
                                                + monBlock.modelData.scale + '})';
                                            Quickshell.execDetached(["hyprctl", "eval", expr]);
                                            root.popupOpen = false;
                                            Qt.callLater(root.refreshMonitors);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

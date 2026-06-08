import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."

Item {
    id: root

    required property var bar

    property bool popupOpen: false
    property real anchorRight: 0
    property bool btAvailable: false
    property bool btPowered: false
    property var btDevices: []

    readonly property string scriptPath: Qt.resolvedUrl("bluetooth-info.sh").toString().replace("file://", "")

    readonly property string iconText: {
        if (!btAvailable || !btPowered) return "󰂲";
        for (var i = 0; i < btDevices.length; i++) {
            if (btDevices[i].connected) return "󰂱";
        }
        return "󰂯";
    }

    readonly property bool hasConnection: {
        for (var i = 0; i < btDevices.length; i++) {
            if (btDevices[i].connected) return true;
        }
        return false;
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: refresh()
    }

    Process {
        id: btQuery
        command: [root.scriptPath]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text);
                    root.btAvailable = data.available !== false;
                    root.btPowered = data.powered === true;
                    root.btDevices = data.devices || [];
                } catch (e) {
                    root.btAvailable = false;
                    root.btPowered = false;
                    root.btDevices = [];
                }
            }
        }
    }

    function refresh() {
        btQuery.running = false;
        btQuery.running = true;
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
        refresh();
        const pos = mapToItem(bar.contentItem, width, 0);
        anchorRight = pos.x;
        popupOpen = true;
    }

    Component.onCompleted: refresh()

    width: Math.max(12, icon.implicitWidth) + 15
    height: 22

    Text {
        id: icon
        anchors.centerIn: parent
        text: root.iconText
        color: root.hasConnection
            ? Theme.accentColor
            : (root.btPowered ? Theme.fgColor : Qt.darker(Theme.fgColor, 1.5))
        font.pixelSize: Theme.fontSize + 2
        font.family: Theme.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggle()
    }

    readonly property int popupWidth: 280

    PanelWindow {
        id: popup
        screen: root.bar.screen

        visible: root.popupOpen

        anchors { top: true; left: true; right: true; bottom: true }
        exclusiveZone: -1
        color: "transparent"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: WlrLayershell.None

        MouseArea {
            anchors.fill: parent
            z: 0
            onClicked: root.popupOpen = false
        }

        Rectangle {
            id: bg
            width: root.popupWidth
            height: col.implicitHeight + 12
            x: root.anchorRight - root.popupWidth
            y: root.bar.height + 2
            z: 1
            color: Theme.bgColor
            border.color: Theme.border
            border.width: 1
            radius: 6

            Column {
                id: col
                x: 6
                y: 6
                width: parent.width - 12
                spacing: 2

                Item {
                    width: parent.width
                    height: 26

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Bluetooth"
                        color: Theme.fgColor
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                    }

                    Text {
                        anchors.right: powerToggle.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.btPowered ? "On" : "Off"
                        color: root.btPowered ? Theme.accentColor : Qt.darker(Theme.fgColor, 1.5)
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                    }

                    Item {
                        id: powerToggle
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 22
                        height: 22

                        Text {
                            anchors.centerIn: parent
                            text: root.btPowered ? "󰂯" : "󰂲"
                            color: root.btPowered ? Theme.accentColor : Qt.darker(Theme.fgColor, 1.5)
                            font.pixelSize: Theme.fontSize + 2
                            font.family: Theme.fontFamily
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(root.btPowered
                                    ? ["bluetoothctl", "power", "off"]
                                    : ["bluetoothctl", "power", "on"]);
                                Qt.callLater(root.refresh);
                            }
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.border
                    visible: root.btAvailable
                }

                Item {
                    width: parent.width
                    height: root.btAvailable && root.btDevices.length > 0
                        ? listCol.height
                        : emptyText.height

                    Text {
                        id: emptyText
                        anchors.centerIn: parent
                        text: !root.btAvailable
                            ? "Bluetooth unavailable"
                            : (root.btPowered ? "No paired devices" : "Bluetooth off")
                        color: Qt.darker(Theme.fgColor, 1.5)
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                    }

                    Column {
                        id: listCol
                        width: parent.width
                        spacing: 0
                        visible: root.btAvailable && root.btDevices.length > 0

                        Repeater {
                            model: root.btDevices

                            Item {
                                required property var modelData
                                width: listCol.width
                                height: 28

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: devArea.containsMouse
                                        ? Qt.lighter(Theme.bgColor, 1.7)
                                        : "transparent"
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 8

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData.connected ? "󰂱" : "󰂯"
                                        color: modelData.connected
                                            ? Theme.accentColor
                                            : Qt.darker(Theme.fgColor, 1.5)
                                        font.pixelSize: Theme.fontSize + 2
                                        font.family: Theme.fontFamily
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 22 - 8 - 72 - 8
                                        text: modelData.name || modelData.address
                                        color: Theme.fgColor
                                        opacity: modelData.connected ? 1.0 : 0.85
                                        font.pixelSize: Theme.fontSize
                                        font.family: Theme.fontFamily
                                        font.bold: modelData.connected
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 72
                                        horizontalAlignment: Text.AlignRight
                                        text: modelData.connected ? "Connected" : "Disconnected"
                                        color: modelData.connected
                                            ? Theme.accentColor
                                            : Qt.darker(Theme.fgColor, 1.5)
                                        font.pixelSize: Theme.fontSize - 1
                                        font.family: Theme.fontFamily
                                    }
                                }

                                MouseArea {
                                    id: devArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.connected) {
                                            Quickshell.execDetached(["bluetoothctl", "disconnect", modelData.address]);
                                        } else {
                                            Quickshell.execDetached(["bluetoothctl", "connect", modelData.address]);
                                        }
                                        Qt.callLater(root.refresh);
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

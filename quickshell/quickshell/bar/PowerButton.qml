import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

Item {
    id: root

    required property var bar

    property bool popupOpen: false
    property real anchorRight: 0

    readonly property var actions: [
        { key: "lock",      label: "Lock",      icon: "󰌾", cmd: ["qs", "ipc", "call", "lock", "lock"] },
        { key: "logout",    label: "Log out",   icon: "󰗽", cmd: ["hyprctl", "eval", "hl.dispatch(hl.dsp.exit())"] },
        { key: "suspend",   label: "Suspend",   icon: "󰒲", cmd: ["systemctl", "suspend"] },
        { key: "reboot",    label: "Reboot",    icon: "󰜉", cmd: ["systemctl", "reboot"] },
        { key: "poweroff",  label: "Power off", icon: "⏻", cmd: ["systemctl", "poweroff"] },
    ]

    function toggle() {
        if (popupOpen) {
            popupOpen = false;
            return;
        }
        const pos = mapToItem(bar.contentItem, width, 0);
        anchorRight = pos.x;
        popupOpen = true;
    }

    width: Math.max(12, icon.implicitWidth) + 15
    height: 22

    Text {
        id: icon
        anchors.centerIn: parent
        text: "⏻"
        color: Theme.fgColor
        font.pixelSize: Theme.fontSize + 1
        font.family: Theme.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggle()
    }

    PanelWindow {
        id: popup
        screen: root.bar.screen

        readonly property int rowHeight: 30
        readonly property int popupWidth: 200
        readonly property int popupHeight: root.actions.length * rowHeight + 8

        visible: root.popupOpen || container.opacity > 0.01

        anchors { top: true; left: true; right: true; bottom: true }
        exclusiveZone: -1
        color: "transparent"
        WlrLayershell.layer: WlrLayershell.Top
        WlrLayershell.keyboardFocus: WlrLayershell.None

        MouseArea {
            anchors.fill: parent
            onClicked: root.popupOpen = false
        }

        Rectangle {
            id: container
            width: popup.popupWidth
            height: popup.popupHeight
            x: root.anchorRight - width
            y: root.bar.height + 2
            color: Theme.bgColor
            border.color: Theme.border
            border.width: 1
            radius: 6

            opacity: root.popupOpen ? 1 : 0
            scale: root.popupOpen ? 1 : 0.92
            transformOrigin: Item.Top

            Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            Behavior on scale   { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

            MouseArea { anchors.fill: parent }

            Column {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 0

                Repeater {
                    model: root.actions

                    Item {
                        required property var modelData
                        width: parent.width
                        height: popup.rowHeight

                        readonly property bool danger: modelData.key === "reboot" || modelData.key === "poweroff"

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: rowArea.containsMouse
                                ? (parent.danger ? Theme.dangerBg : Qt.lighter(Theme.bgColor, 1.7))
                                : "transparent"
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            spacing: 10

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 16
                                text: parent.parent.modelData.icon
                                color: rowArea.containsMouse && parent.parent.danger
                                    ? Theme.danger
                                    : Theme.fgColor
                                font.pixelSize: Theme.fontSize + 2
                                font.family: Theme.fontFamily
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: parent.parent.modelData.label
                                color: rowArea.containsMouse && parent.parent.danger
                                    ? Theme.danger
                                    : Theme.fgColor
                                font.pixelSize: Theme.fontSize
                                font.family: Theme.fontFamily
                            }
                        }

                        MouseArea {
                            id: rowArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.popupOpen = false;
                                Quickshell.execDetached(parent.modelData.cmd);
                            }
                        }
                    }
                }
            }
        }
    }
}

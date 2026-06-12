import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."

Item {
    id: root
    required property var bar

    property bool popupOpen: false
    property real anchorRight: 0
    property int screenBrightness: 100

    Timer {
        id: brightnessTimer
        interval: 150
        onTriggered: {
            Quickshell.execDetached(["ddcutil", "setvcp", "10", String(root.screenBrightness)]);
        }
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
        const pos = mapToItem(bar.contentItem, width, 0);
        anchorRight = pos.x;
        popupOpen = true;
    }

    width: Math.max(12, icon.implicitWidth) + 15
    height: 22

    Text {
        id: icon
        anchors.centerIn: parent
        text: Theme.dark ? "󰖔" : "󰖨"
        color: Theme.fgColor
        font.pixelSize: Theme.fontSize + 2
        font.family: Theme.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggle()
    }

    readonly property int rowHeight: 30
    readonly property int sliderHeight: 36
    readonly property int popupWidth: 220
    readonly property int popupHeight: rowHeight + sliderHeight + 8

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
            id: container
            width: root.popupWidth
            height: root.popupHeight
            x: root.anchorRight - root.popupWidth
            y: root.bar.height + 2
            z: 1
            color: Theme.bgColor
            border.color: Theme.border
            border.width: 1
            radius: 6

            Column {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 0

                RowLayout {
                    width: parent.width
                    height: root.rowHeight
                    spacing: 10

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 10
                        Layout.preferredWidth: 16
                        text: Theme.dark ? "󰖔" : "󰖨"
                        color: Theme.fgColor
                        font.pixelSize: Theme.fontSize + 2
                        font.family: Theme.fontFamily
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: "Dark Mode"
                        color: Theme.fgColor
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                    }

                    Item { Layout.fillWidth: true }

                    Switch {
                        id: themeSwitch
                        Layout.alignment: Qt.AlignVCenter
                        Layout.rightMargin: 10
                        checked: Theme.dark
                        onClicked: Theme.toggle()

                        indicator: Rectangle {
                            implicitWidth: 32
                            implicitHeight: 18
                            x: themeSwitch.leftPadding
                            y: parent.height / 2 - height / 2
                            radius: 9
                            color: themeSwitch.checked ? Theme.accentColor : Theme.border

                            Rectangle {
                                x: themeSwitch.checked ? parent.width - width : 0
                                y: 2
                                width: 14
                                height: 14
                                radius: 7
                                color: Theme.fgColor
                                Behavior on x { NumberAnimation { duration: 100 } }
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: root.sliderHeight

                    Text {
                        id: brightIcon
                        anchors.verticalCenter: parent.verticalCenter
                        x: 8
                        width: 16
                        text: "󰃟"
                        color: Theme.fgColor
                        font.pixelSize: Theme.fontSize + 2
                        font.family: Theme.fontFamily
                    }

                    Text {
                        id: pctLabel
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        width: 36
                        horizontalAlignment: Text.AlignRight
                        text: root.screenBrightness + "%"
                        color: Theme.fgColor
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                    }

                    Slider {
                        id: brightSlider
                        anchors.left: brightIcon.right
                        anchors.leftMargin: 8
                        anchors.right: pctLabel.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        height: 22
                        padding: 0
                        from: 0
                        to: 100
                        stepSize: 1
                        value: root.screenBrightness
                        onMoved: {
                            root.screenBrightness = value;
                            brightnessTimer.restart();
                        }

                        background: Rectangle {
                            x: brightSlider.leftPadding
                            y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
                            width: brightSlider.availableWidth
                            height: 4
                            radius: 2
                            color: Theme.border

                            Rectangle {
                                width: brightSlider.visualPosition * parent.width
                                height: parent.height
                                color: Theme.accentColor
                                radius: 2
                            }
                        }

                        handle: Rectangle {
                            x: brightSlider.leftPadding + brightSlider.visualPosition * (brightSlider.availableWidth - width)
                            y: brightSlider.topPadding + brightSlider.availableHeight / 2 - height / 2
                            width: 12
                            height: 12
                            radius: 6
                            color: Theme.fgColor
                            border.color: Theme.accentColor
                            border.width: 1
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import ".."

Item {
    id: root

    required property var bar

    property bool popupOpen: false
    property real anchorRight: 0

    readonly property var audioSinks: Pipewire.nodes.values.filter(n => n.audio && n.isSink && !n.isStream)
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property string iconText: {
        if (!sink || muted) return "󰝟";
        if (volume < 0.34) return "󰕿";
        if (volume < 0.67) return "󰖀";
        return "󰕾";
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

    PwObjectTracker { objects: root.audioSinks }

    Text {
        id: icon
        anchors.centerIn: parent
        text: root.iconText
        color: root.muted ? Theme.danger : Theme.fgColor
        font.pixelSize: Theme.fontSize + 2
        font.family: Theme.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            const s = root.sink;
            if (mouse.button === Qt.LeftButton) {
                root.toggle();
            } else if (mouse.button === Qt.RightButton) {
                if (s?.ready && s?.audio) s.audio.muted = !s.audio.muted;
            }
        }
        onWheel: (wheel) => {
            const s = root.sink;
            if (!s?.ready || !s?.audio) return;
            const step = 0.05;
            const delta = wheel.angleDelta.y > 0 ? step : -step;
            s.audio.muted = false;
            s.audio.volume = Math.max(0, Math.min(1, s.audio.volume + delta));
        }
    }

    PopupWindow {
        id: popup

        readonly property int popupWidth: 300
        readonly property int sinkRowHeight: 26
        readonly property int sliderRowHeight: 36
        readonly property int popupHeight: root.audioSinks.length * sinkRowHeight
            + (root.audioSinks.length > 0 ? 1 : 0)
            + sliderRowHeight + 8

        visible: root.popupOpen

        anchor {
            window: root.bar
            rect.x: root.anchorRight - popup.popupWidth
            rect.y: root.bar.height + 2
        }

        implicitWidth: popup.popupWidth
        implicitHeight: popup.popupHeight
        color: "transparent"

        Rectangle {
            id: container
            anchors.fill: parent
            color: Theme.bgColor
            border.color: Theme.border
            border.width: 1
            radius: 6

            MouseArea { anchors.fill: parent }

            Column {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 0

                Repeater {
                    model: root.audioSinks

                    Item {
                        required property var modelData
                        readonly property bool isActive: root.sink && modelData.id === root.sink.id
                        width: parent.width
                        height: popup.sinkRowHeight

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: sinkArea.containsMouse
                                ? Qt.lighter(Theme.bgColor, 1.7)
                                : (parent.isActive ? Qt.lighter(Theme.bgColor, 1.4) : "transparent")
                        }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 14
                                text: parent.parent.isActive ? "" : ""
                                color: parent.parent.isActive ? Theme.accentColor : Qt.darker(Theme.fgColor, 1.5)
                                font.pixelSize: Theme.fontSize
                                font.family: Theme.fontFamily
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 14 - 8
                                text: parent.parent.modelData.description || parent.parent.modelData.nickname || parent.parent.modelData.name
                                color: Theme.fgColor
                                opacity: parent.parent.isActive ? 1.0 : 0.85
                                font.pixelSize: Theme.fontSize
                                font.family: Theme.fontFamily
                                font.bold: parent.parent.isActive
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            id: sinkArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Pipewire.preferredDefaultAudioSink = parent.modelData;
                            }
                        }
                    }
                }

                Rectangle {
                    visible: root.audioSinks.length > 0
                    width: parent.width
                    height: 1
                    color: Theme.border
                }

                Item {
                    width: parent.width
                    height: popup.sliderRowHeight

                    Item {
                        id: muteBtn
                        x: 6
                        anchors.verticalCenter: parent.verticalCenter
                        width: 22
                        height: 22

                        Text {
                            anchors.centerIn: parent
                            text: root.iconText
                            color: root.muted ? Theme.danger : Theme.fgColor
                            font.pixelSize: Theme.fontSize + 2
                            font.family: Theme.fontFamily
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const s = root.sink;
                                if (s?.ready && s?.audio) s.audio.muted = !s.audio.muted;
                            }
                        }
                    }

                    Text {
                        id: pctLabel
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        width: 36
                        horizontalAlignment: Text.AlignRight
                        text: Math.round(root.volume * 100) + "%"
                        color: Theme.fgColor
                        font.pixelSize: Theme.fontSize
                        font.family: Theme.fontFamily
                    }

                    Slider {
                        id: volSlider
                        anchors.left: muteBtn.right
                        anchors.leftMargin: 8
                        anchors.right: pctLabel.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        height: 22
                        padding: 0
                        from: 0
                        to: 1
                        stepSize: 0.01
                        value: root.volume
                        onMoved: {
                            const s = root.sink;
                            if (!s?.ready || !s?.audio) return;
                            s.audio.muted = false;
                            s.audio.volume = value;
                        }

                        background: Rectangle {
                            x: volSlider.leftPadding
                            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                            width: volSlider.availableWidth
                            height: 4
                            radius: 2
                            color: Theme.border

                            Rectangle {
                                width: volSlider.visualPosition * parent.width
                                height: parent.height
                                color: Theme.accentColor
                                radius: 2
                            }
                        }

                        handle: Rectangle {
                            x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                            y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
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

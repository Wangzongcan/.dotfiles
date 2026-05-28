import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import "."

Scope {
    id: root

    property string wallpaperPath: ""

    property string timeText: ""

    function lock() {
        lockObj.locked = true;
    }

    IpcHandler {
        target: "lock"
        function lock(): void { root.lock(); }
    }

    Timer {
        interval: 1000
        running: lockObj.locked
        repeat: true
        triggeredOnStart: true
        onTriggered: root.timeText = Qt.formatDateTime(new Date(), "HH:mm")
    }

    LockContext {
        id: ctx
        onUnlocked: lockObj.locked = false
    }

    WlSessionLock {
        id: lockObj
        locked: false

        WlSessionLockSurface {
            id: surface

            Image {
                anchors.fill: parent
                source: root.wallpaperPath
                fillMode: Image.PreserveAspectCrop
                smooth: true
                cache: true
                asynchronous: false
            }

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: 0.45
            }

            Text {
                id: clock
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.18
                text: root.timeText
                color: Theme.fgColor
                font.family: Theme.fontFamily
                font.pixelSize: 110
                font.weight: Font.Light
                renderType: Text.NativeRendering
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: clock.bottom
                anchors.topMargin: 4
                text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                color: Theme.fgColor
                opacity: 0.75
                font.family: Theme.fontFamily
                font.pixelSize: 18
            }

            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: parent.height * 0.05
                spacing: 12

                Rectangle {
                    width: 340
                    height: 44
                    radius: 8
                    color: Qt.lighter(Theme.bgColor, 1.4)
                    border.color: passwordBox.activeFocus ? Theme.accentColor : Theme.border
                    border.width: 1

                    TextField {
                        id: passwordBox
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        echoMode: TextInput.Password
                        passwordCharacter: "●"
                        font.family: Theme.fontFamily
                        font.pixelSize: 16
                        color: Theme.fgColor
                        placeholderText: ctx.unlockInProgress ? "Verifying…" : "Enter password"
                        placeholderTextColor: Qt.darker(Theme.fgColor, 1.6)
                        enabled: !ctx.unlockInProgress
                        focus: true
                        background: null
                        verticalAlignment: TextInput.AlignVCenter

                        onTextChanged: ctx.currentText = text
                        onAccepted: ctx.tryUnlock()

                        Connections {
                            target: ctx
                            function onCurrentTextChanged() {
                                if (passwordBox.text !== ctx.currentText) {
                                    passwordBox.text = ctx.currentText;
                                }
                            }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: ctx.showFailure ? "Incorrect password" : ""
                    color: Theme.danger
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    height: 16
                }
            }
        }
    }
}

import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import QtQuick
import "."

Scope {
    id: root

    property int defaultTimeoutMs: 5000
    property int popupWidth: 420
    property int outerMargin: 20
    property int barHeight: 26
    property int paddingH: 15
    property int paddingV: 10
    property int borderSize: 2
    property int iconSize: 32
    property int cardSpacing: 8
    property int fontSize: 14
    property string fontFamily: ""

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        imageSupported: true
        persistenceSupported: false

        onNotification: notif => {
            notif.tracked = true
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: popup
            required property var modelData
            screen: modelData

            visible: server.trackedNotifications.values.length > 0
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay

            anchors {
                top: true
                right: true
            }
            margins {
                top: root.barHeight + root.outerMargin
                right: root.outerMargin
            }

            implicitWidth: root.popupWidth
            implicitHeight: Math.max(1, column.implicitHeight)

            Column {
                id: column
                width: parent.width
                spacing: root.cardSpacing

                Repeater {
                    model: server.trackedNotifications

                    Rectangle {
                        id: card
                        required property var modelData
                        readonly property var notif: modelData
                        readonly property bool critical: notif.urgency === NotificationUrgency.Critical
                        readonly property string iconSource: {
                            if (notif.image && notif.image !== "") return notif.image;
                            if (notif.appIcon && notif.appIcon !== "") return Quickshell.iconPath(notif.appIcon, true);
                            if (notif.desktopEntry && notif.desktopEntry !== "") return Quickshell.iconPath(notif.desktopEntry, true);
                            return "";
                        }

                        width: column.width
                        height: body.implicitHeight + root.paddingV * 2
                        color: Theme.bgColor
                        border.color: card.critical ? Theme.danger : Theme.border
                        border.width: root.borderSize
                        radius: 6

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: card.notif.dismiss()
                        }

                        Column {
                            id: body
                            x: root.paddingH
                            y: root.paddingV
                            width: parent.width - root.paddingH * 2
                            spacing: 8

                            Item {
                                id: contentRow
                                width: parent.width
                                implicitHeight: Math.max(iconImg.visible ? iconImg.height : 0, textCol.implicitHeight)
                                height: implicitHeight

                                Image {
                                    id: iconImg
                                    visible: card.iconSource !== ""
                                    source: card.iconSource
                                    sourceSize.width: root.iconSize
                                    sourceSize.height: root.iconSize
                                    width: visible ? root.iconSize : 0
                                    height: root.iconSize
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    anchors.left: parent.left
                                    anchors.top: parent.top
                                }

                                Column {
                                    id: textCol
                                    anchors.left: iconImg.visible ? iconImg.right : parent.left
                                    anchors.leftMargin: iconImg.visible ? 12 : 0
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4

                                    Text {
                                        width: parent.width
                                        visible: text.length > 0
                                        text: card.notif.appName || ""
                                        color: Theme.accentColor
                                        font.pixelSize: root.fontSize - 2
                                        font.family: root.fontFamily
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        text: card.notif.summary
                                        color: Theme.fgColor
                                        font.pixelSize: root.fontSize
                                        font.family: root.fontFamily
                                        font.bold: true
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        visible: card.notif.body.length > 0
                                        text: card.notif.body
                                        color: Theme.fgColor
                                        opacity: 0.85
                                        font.pixelSize: root.fontSize - 1
                                        font.family: root.fontFamily
                                        wrapMode: Text.Wrap
                                        maximumLineCount: 5
                                        elide: Text.ElideRight
                                        textFormat: Text.PlainText
                                    }
                                }
                            }

                            Flow {
                                id: actionRow
                                width: parent.width
                                spacing: 6
                                visible: card.notif.actions.length > 0

                                Repeater {
                                    model: card.notif.actions

                                    Rectangle {
                                        id: btn
                                        required property var modelData
                                        visible: modelData.identifier !== "default"

                                        radius: 4
                                        color: btnArea.containsMouse
                                            ? Qt.lighter(Theme.bgColor, 1.8)
                                            : Qt.lighter(Theme.bgColor, 1.4)
                                        border.color: Theme.border
                                        border.width: 1

                                        width: btnLabel.implicitWidth + 18
                                        height: btnLabel.implicitHeight + 10

                                        Text {
                                            id: btnLabel
                                            anchors.centerIn: parent
                                            text: btn.modelData.text || btn.modelData.identifier
                                            color: Theme.fgColor
                                            font.pixelSize: root.fontSize - 2
                                            font.family: root.fontFamily
                                        }

                                        MouseArea {
                                            id: btnArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: btn.modelData.invoke()
                                        }
                                    }
                                }
                            }
                        }

                        Timer {
                            running: !card.critical
                            repeat: false
                            interval: card.notif.expireTimeout > 0
                                ? card.notif.expireTimeout * 1000
                                : root.defaultTimeoutMs
                            onTriggered: card.notif.expire()
                        }
                    }
                }
            }
        }
    }
}

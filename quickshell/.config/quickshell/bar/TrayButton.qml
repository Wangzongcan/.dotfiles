import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import ".."

Item {
    id: root

    required property var bar

    property bool listOpen: false
    property real listAnchorRight: 0

    property var menuItem: null
    property real menuAnchorRight: 0

    function toggleList() {
        if (listOpen) {
            listOpen = false;
            return;
        }
        const pos = mapToItem(bar.contentItem, width, 0);
        listAnchorRight = pos.x;
        menuItem = null;
        listOpen = true;
    }

    function activateItem(item) {
        if (!item.hasMenu) {
            item.activate();
            listOpen = false;
            return;
        }
        if (menuItem === item) {
            menuItem = null;
            return;
        }
        menuAnchorRight = listAnchorRight;
        menuItem = item;
    }

    width: Math.max(12, icon.implicitWidth) + 15
    height: 22

    Text {
        id: icon
        anchors.centerIn: parent
        text: "󰇘"
        color: Theme.fgColor
        font.pixelSize: Theme.fontSize + 2
        font.family: Theme.fontFamily
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggleList()
    }

    // hidden preload so icons are in the pixmap cache before popup opens
    Item {
        visible: false
        Repeater {
            model: SystemTray.items
            Image {
                required property var modelData
                source: modelData.icon
                sourceSize.width: 36
                sourceSize.height: 36
                asynchronous: false
                cache: true
            }
        }
    }

    PanelWindow {
        id: listPanel
        screen: root.bar.screen

        readonly property int itemCount: SystemTray.items.values.length
        readonly property int popupWidth: itemCount > 0
            ? itemCount * 18 + (itemCount - 1) * 10 + 16
            : 100
        readonly property int popupHeight: 30

        visible: root.listOpen || container.opacity > 0.01

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }
        exclusiveZone: -1
        color: "transparent"
        WlrLayershell.layer: WlrLayershell.Top
        WlrLayershell.keyboardFocus: WlrLayershell.None

        MouseArea {
            anchors.fill: parent
            onClicked: root.listOpen = false
        }

        Rectangle {
            id: container
            width: listPanel.popupWidth
            height: listPanel.popupHeight
            x: root.listAnchorRight - width
            y: root.bar.height + 2
            color: Theme.bgColor
            border.color: Theme.border
            border.width: 1
            radius: 6

            opacity: root.listOpen ? 1 : 0
            scale: root.listOpen ? 1 : 0.92
            transformOrigin: Item.Top

            Behavior on opacity {
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }
            Behavior on scale {
                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                Repeater {
                    model: SystemTray.items

                    Item {
                        required property var modelData
                        width: 18
                        height: 18

                        Image {
                            width: 18
                            height: 18
                            source: parent.modelData.icon
                            sourceSize.width: 36
                            sourceSize.height: 36
                            smooth: true
                            mipmap: true
                            asynchronous: false
                            cache: true
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => root.activateItem(parent.modelData)
                            onWheel: (wheel) => parent.modelData.scroll(wheel.angleDelta.y, false)
                        }
                    }
                }

                Text {
                    visible: SystemTray.items.values.length === 0
                    anchors.verticalCenter: parent.verticalCenter
                    text: "no tray items"
                    color: Qt.darker(Theme.fgColor, 1.6)
                    font.pixelSize: Theme.fontSize
                    font.family: Theme.fontFamily
                }
            }
        }
    }

    PopupWindow {
        id: menuPopup

        readonly property var item: root.menuItem

        visible: item !== null

        anchor {
            window: root.bar
            rect.x: root.menuAnchorRight - menuPopup.width
            rect.y: root.bar.height
        }

        implicitWidth: 220
        implicitHeight: menuBg.implicitHeight
        color: "transparent"

        QsMenuOpener {
            id: menuOpener
            menu: menuPopup.item ? menuPopup.item.menu : null
        }

        Rectangle {
            id: menuBg
            anchors.fill: parent
            color: Theme.bgColor
            border.color: Theme.border
            border.width: 1
            radius: 6
            implicitHeight: menuCol.implicitHeight + 8

            Column {
                id: menuCol
                x: 4
                y: 4
                width: parent.width - 8
                spacing: 0

                Repeater {
                    model: menuOpener.children

                    Item {
                        id: entryItem
                        required property var modelData
                        readonly property var entry: modelData

                        width: menuCol.width
                        height: entry.isSeparator ? 9 : 24

                        Rectangle {
                            visible: entryItem.entry.isSeparator
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 4
                            anchors.rightMargin: 4
                            height: 1
                            color: Theme.border
                        }

                        Rectangle {
                            visible: !entryItem.entry.isSeparator
                            anchors.fill: parent
                            radius: 4
                            color: entryArea.containsMouse && entryItem.entry.enabled
                                ? Qt.lighter(Theme.bgColor, 1.7)
                                : "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 6

                                Image {
                                    visible: entryItem.entry.icon !== ""
                                    source: entryItem.entry.icon
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                    width: visible ? 14 : 0
                                    height: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - (entryItem.entry.icon !== "" ? 20 : 0)
                                    text: entryItem.entry.text
                                    color: entryItem.entry.enabled
                                        ? Theme.fgColor
                                        : Qt.darker(Theme.fgColor, 1.6)
                                    font.pixelSize: Theme.fontSize
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: entryArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                enabled: entryItem.entry.enabled
                                onClicked: {
                                    entryItem.entry.triggered();
                                    root.menuItem = null;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

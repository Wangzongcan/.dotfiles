import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import "."

Scope {
    id: root

    property bool showing: false
    property string query: ""

    readonly property var entries: {
        const q = query.toLowerCase().trim();
        const matches = DesktopEntries.applications.values.filter(e => {
            if (e.noDisplay) return false;
            if (q === "") return true;
            const name = (e.name || "").toLowerCase();
            const generic = (e.genericName || "").toLowerCase();
            const comment = (e.comment || "").toLowerCase();
            return name.includes(q) || generic.includes(q) || comment.includes(q);
        });
        matches.sort((a, b) => (a.name || "").localeCompare(b.name || ""));
        return matches;
    }

    function show() {
        root.showing = true;
    }
    function hide() {
        root.showing = false;
    }
    function toggle() {
        if (root.showing) hide(); else show();
    }

    IpcHandler {
        target: "launcher"
        function show(): void { root.show(); }
        function hide(): void { root.hide(); }
        function toggle(): void { root.toggle(); }
    }

    PanelWindow {
        id: panel
        visible: root.showing
        screen: Quickshell.primaryScreen

        anchors.top: true
        margins.top: 200
        exclusionMode: ExclusionMode.Ignore

        implicitWidth: 600
        implicitHeight: 480
        color: "transparent"

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.layer: WlrLayer.Overlay

        onVisibleChanged: if (visible) {
            searchBox.clear();
            Qt.callLater(() => searchBox.forceActiveFocus());
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.bgColor
            radius: 12
            border.color: Theme.border
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                Rectangle {
                    width: parent.width
                    height: 44
                    radius: 8
                    color: Qt.lighter(Theme.bgColor, 1.4)
                    border.color: searchBox.activeFocus ? Theme.accentColor : Theme.border
                    border.width: 1

                    TextField {
                        id: searchBox
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        font.family: Theme.fontFamily
                        font.pixelSize: 15
                        color: Theme.fgColor
                        placeholderText: "Search applications…"
                        placeholderTextColor: Qt.darker(Theme.fgColor, 1.6)
                        background: null
                        verticalAlignment: TextInput.AlignVCenter
                        focus: true

                        onTextChanged: {
                            root.query = text;
                            list.currentIndex = 0;
                        }
                        Keys.onEscapePressed: root.hide()
                        Keys.onReturnPressed: list.launchCurrent()
                        Keys.onEnterPressed: list.launchCurrent()
                        Keys.onDownPressed: list.incrementCurrentIndex()
                        Keys.onUpPressed: list.decrementCurrentIndex()
                        Keys.onPressed: (event) => {
                            if (event.modifiers & Qt.ControlModifier) {
                                if (event.key === Qt.Key_N || event.key === Qt.Key_J) {
                                    list.incrementCurrentIndex();
                                    event.accepted = true;
                                } else if (event.key === Qt.Key_P || event.key === Qt.Key_K) {
                                    list.decrementCurrentIndex();
                                    event.accepted = true;
                                }
                            }
                        }
                    }
                }

                ListView {
                    id: list
                    width: parent.width
                    height: parent.height - 54
                    model: root.entries
                    currentIndex: 0
                    clip: true
                    keyNavigationEnabled: false
                    spacing: 2
                    boundsBehavior: Flickable.StopAtBounds

                    function launchCurrent() {
                        if (currentIndex >= 0 && currentIndex < model.length) {
                            model[currentIndex].execute();
                            root.hide();
                        }
                    }

                    delegate: Rectangle {
                        id: delegateRoot
                        required property var modelData
                        required property int index

                        width: ListView.view.width
                        height: 48
                        radius: 6
                        color: ListView.isCurrentItem ? Qt.darker(Theme.accentColor, 1.2) : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 12

                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 32
                                height: 32
                                source: modelData.icon ? Quickshell.iconPath(modelData.icon, "application-x-executable") : ""
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                asynchronous: true
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 56
                                spacing: 1

                                Text {
                                    width: parent.width
                                    text: modelData.name || ""
                                    color: Theme.fgColor
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                }
                                Text {
                                    width: parent.width
                                    text: modelData.comment || modelData.genericName || ""
                                    color: Qt.darker(Theme.fgColor, 1.4)
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 11
                                    elide: Text.ElideRight
                                    visible: text !== ""
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onPositionChanged: list.currentIndex = delegateRoot.index
                            onClicked: {
                                list.currentIndex = delegateRoot.index;
                                list.launchCurrent();
                            }
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import ".."

Item {
    id: root
    required property var bar

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
        onClicked: Theme.toggle()
    }
}

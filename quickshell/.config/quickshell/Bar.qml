import QtQuick
import Quickshell
import "."
import "./bar"

PanelWindow {
    id: bar
    required property var modelData
    screen: modelData

    signal closeAllPopups()

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 26
    color: Theme.bgColor

    Workspaces {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 4
    }

    Clock {
        anchors.centerIn: parent
    }

    Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 9
        spacing: 0

        TrayButton    { bar: bar; anchors.verticalCenter: parent.verticalCenter }
        VolumeButton  { bar: bar; anchors.verticalCenter: parent.verticalCenter }
        BluetoothButton { bar: bar; anchors.verticalCenter: parent.verticalCenter }
        ThemeButton   { bar: bar; anchors.verticalCenter: parent.verticalCenter }
        PowerButton   { bar: bar; anchors.verticalCenter: parent.verticalCenter }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.border
    }
}

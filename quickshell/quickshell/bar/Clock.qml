import QtQuick
import ".."

Text {
    id: root

    property string timeText: ""

    text: timeText
    color: Theme.fgColor
    font.pixelSize: Theme.fontSize
    font.family: Theme.fontFamily
    leftPadding: 9

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.timeText = Qt.formatDateTime(new Date(), "dddd HH:mm")
    }
}

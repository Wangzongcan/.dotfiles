import QtQuick
import ".."

Loader {
    id: root

    source: Qt.resolvedUrl(Compositor.isNiri ? "NiriWorkspaces.qml" : "HyprWorkspaces.qml")
}

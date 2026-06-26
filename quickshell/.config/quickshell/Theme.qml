pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool dark: true
    property bool _initialized: false

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 14

    readonly property color bgColor:     dark ? "#1a1b26" : "#e1e2e7"
    readonly property color fgColor:     dark ? "#c0caf5" : "#3760bf"
    readonly property color accentColor: dark ? "#7aa2f7" : "#2e7de9"
    readonly property color border:      dark ? "#414868" : "#a8aecb"
    readonly property color danger:      dark ? "#f7768e" : "#f52a65"
    readonly property color dangerBg:    dark ? "#3b1f2b" : "#fae0e4"

    function toggle() {
        root._initialized = true;
        root.dark = !root.dark;
        apply();
    }

    function setDark(d) {
        root._initialized = true;
        root.dark = d;
        apply();
    }

    function apply() {
        applySystem();
        applyCompositor();
        applyApps();
    }

    function applySystem() {
        const scheme = root.dark ? "prefer-dark" : "prefer-light";
        const gtk = root.dark ? "Adwaita-dark" : "Adwaita";
        Quickshell.execDetached(["sh", "-c",
            "gsettings set org.gnome.desktop.interface color-scheme '" + scheme + "' 2>/dev/null; "
            + "gsettings set org.gnome.desktop.interface gtk-theme '" + gtk + "' 2>/dev/null"
        ]);
    }

    function applyCompositor() {
        const active = root.dark ? "0xff7aa2f7" : "0xff2e7de9";
        const inactive = root.dark ? "0xaa414868" : "0xaaa8aecb";
        Compositor.applyTheme(active, inactive);
    }

    function applyApps() {
        Quickshell.execDetached(["ghostty", "+reload-config"]);
    }

    readonly property Process initProc: Process {
        running: true
        command: ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!root._initialized) {
                    root.dark = (this.text || "").indexOf("light") < 0;
                }
                root.applyCompositor();
            }
        }
    }

    Component.onCompleted: {
        Compositor.startPortals();
    }
}

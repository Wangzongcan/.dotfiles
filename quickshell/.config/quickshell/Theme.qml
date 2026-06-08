pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool dark: true

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 12

    readonly property color bgColor:     dark ? "#1a1b26" : "#e1e2e7"
    readonly property color fgColor:     dark ? "#c0caf5" : "#3760bf"
    readonly property color accentColor: dark ? "#7aa2f7" : "#2e7de9"
    readonly property color border:      dark ? "#414868" : "#a8aecb"
    readonly property color danger:      dark ? "#f7768e" : "#f52a65"
    readonly property color dangerBg:    dark ? "#3b1f2b" : "#fae0e4"

    function toggle() {
        root.dark = !root.dark;
        applySystem();
        applyHyprland();
    }

    function setDark(d) {
        root.dark = d;
        applySystem();
        applyHyprland();
    }

    function applySystem() {
        const scheme = root.dark ? "prefer-dark" : "prefer-light";
        const gtk = root.dark ? "Adwaita-dark" : "Adwaita";
        Quickshell.execDetached(["sh", "-c",
            "gsettings set org.gnome.desktop.interface color-scheme '" + scheme + "'"
            + " && gsettings set org.gnome.desktop.interface gtk-theme '" + gtk + "'"
        ]);
    }

    function applyHyprland() {
        const active = root.dark ? "rgb(7aa2f7)" : "rgb(2e7de9)";
        const inactive = root.dark ? "rgba(414868aa)" : "rgba(a8aecbaa)";
        Quickshell.execDetached(["sh", "-c",
            "hyprctl keyword general:col.active_border '" + active + "'"
            + " && hyprctl keyword general:col.inactive_border '" + inactive + "'"
        ]);
    }

    readonly property Process initProc: Process {
        running: true
        command: ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.dark = (this.text || "").indexOf("light") < 0;
                root.applyHyprland();
            }
        }
    }
}

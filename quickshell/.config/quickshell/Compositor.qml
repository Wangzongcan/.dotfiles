pragma Singleton
import QtQuick
import Quickshell

QtObject {
    id: root

    readonly property string desktop: (Quickshell.env("XDG_CURRENT_DESKTOP") || "").toLowerCase()
    readonly property bool isNiri: (Quickshell.env("NIRI_SOCKET") || "") !== "" || desktop.indexOf("niri") !== -1
    readonly property bool isHyprland: (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || "") !== "" || desktop.indexOf("hyprland") !== -1

    function logoutCommand() {
        if (isNiri) return ["niri", "msg", "action", "quit"];
        if (isHyprland) return ["hyprctl", "eval", "hl.dispatch(hl.dsp.exit())"];
        return ["sh", "-c", "loginctl terminate-session \"$XDG_SESSION_ID\""];
    }

    function applyTheme(active, inactive) {
        if (!isHyprland) return;

        Quickshell.execDetached(["sh", "-c",
            "hyprctl keyword general:col.active_border '" + active + "' 2>/dev/null"
            + " && hyprctl keyword general:col.inactive_border '" + inactive + "' 2>/dev/null"
        ]);
    }

    function startPortals() {
        const compositorPortal = isHyprland ? "xdg-desktop-portal-hyprland" : "xdg-desktop-portal-gnome";
        Quickshell.execDetached(["sh", "-c",
            "pgrep -x xdg-desktop-portal >/dev/null 2>&1"
            + " || /usr/lib/xdg-desktop-portal &>/dev/null &"
            + " systemctl --user start xdg-desktop-portal-gtk " + compositorPortal + " 2>/dev/null;"
            + " true"
        ]);
    }
}

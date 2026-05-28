//@ pragma IconTheme Adwaita

import Quickshell

Scope {
    Notifications {}

    Wallpaper { id: wallpaper }

    Lock { wallpaperPath: wallpaper.currentPath }

    Launcher {}

    Variants {
        model: Quickshell.screens
        Bar {}
    }
}

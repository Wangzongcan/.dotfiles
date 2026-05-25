import Quickshell

Scope {
    Notifications {}

    Wallpaper { id: wallpaper }

    Lock { wallpaperPath: wallpaper.currentPath }

    Variants {
        model: Quickshell.screens
        Bar {}
    }
}

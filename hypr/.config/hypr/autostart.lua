-- https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function ()
    hl.exec_cmd("fcitx5")
    hl.exec_cmd("clash-party")
    hl.exec_cmd("qs")
end)

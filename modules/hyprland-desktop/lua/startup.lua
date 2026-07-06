-- Runtime startup commands migrated from exec-once.

hl.on("hyprland.start", function()
  hl.exec_cmd("waybar")
  hl.exec_cmd("wlsunset -l 46 -L 14.5")
  hl.exec_cmd("nm-applet --indicator")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("nextcloud")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("pypr")
end)

-- Window rules migrated from the old windowrule list.

local function floating(name, match)
  hl.window_rule({
    name = name,
    match = match,
    float = true,
  })
end

floating("float-pwvucontrol", { class = "^(com.saivert.pwvucontrol)$" })
floating("float-nextcloud", { class = "^(com.nextcloud.desktopclient.nextcloud)$" })
floating("float-blueman", { class = "blueman" })
floating("float-vlc", { class = "^(vlc)$" })
floating("float-keepassxc", { class = "^(org.keepassxc.KeePassXC)$" })
floating("zoom", { initial_class = "^(zoom)$" })

-- Dialogs.
floating("float-all-files-dialog", { initial_title = "(All Files)" })
floating("float-save-dialog", { initial_title = ".*wants to save$" })
floating("float-print-dialog", { initial_title = "^(Print)$" })
floating("float-pycharm-welcome", { initial_title = ".*Welcome to PyCharm" })

-- gsimplecal: use monitor-local expressions.
hl.window_rule({
  name = "float-move-gsimplecal",
  match = { class = "^(gsimplecal)$" },
  float = true,
  move = "(monitor_w*0.45) (monitor_h*0.029)",
})

-- Calc always floats.
floating("float-calc", { title = "^Calc$" })

-- wl-mirror fallback for temporary/unknown displays. wl-mirror itself selects
-- the target output; pinning keeps the fullscreen mirror visible when linked
-- workspaces change.
hl.window_rule({
  name = "projector-mirror",
  match = { initial_title = "^hypr-projector-mirror:.*$" },
  float = true,
  pin = true,
  fullscreen = true,
  no_initial_focus = true,
})

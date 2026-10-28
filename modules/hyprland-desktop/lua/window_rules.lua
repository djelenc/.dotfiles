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

-- Dialogs marked modal by their application float at their preferred size.
hl.window_rule({
  name = "float-modal-dialogs",
  match = { modal = true },
  float = true,
  center = true,
})

-- Some file choosers are not advertised as modal/transient. Match common
-- dialog titles so they stay floating even on monocle workspaces. This is a
-- fallback, not a reliable way to identify every dialog.
hl.window_rule({
  name = "float-common-file-dialogs",
  match = { initial_title = "^((Open|Save|Select|Choose)( .*)?|File [Cc]hooser)$" },
  float = true,
  center = true,
})

-- GTK's portal file chooser can restore a huge saved window geometry from
-- an earlier tiled/monocle session. Float it at a sensible size and cap later
-- client-side resizes, regardless of which application opened the dialog.
hl.window_rule({
  name = "size-gtk-portal-file-chooser",
  match = {
    class = "^xdg-desktop-portal-gtk$",
    initial_title = "^((Open|Save|Select|Choose)( .*)?|File [Cc]hooser|Enter name of file.*)$",
  },
  float = true,
  size = { 1000, 700 },
  max_size = { 1200, 800 },
  center = true,
})

-- Fallbacks for dialogs that do not advertise modal state.
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

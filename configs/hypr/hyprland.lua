-----------------
--- VARIABLES ---
-----------------
-- applications
local terminal = "ghostty"
local files = "nautilus"
local audio = "pavucontrol"
local browser = "flatpak run app.zen_browser.zen"
local music = "flatpak run com.spotify.Client"
local code = "zeditor"

-- colors
local primary = "rgba(ddddddff)"
local white = "rgba(ffffffaa)"
local red = "rgba(de2566aa)"
local border_gray = "rgba(505050bb)"
local shadow = "rgba(10,10,10,0.3)"

-- fonts
local font_family = "Noto Sans"

---------------------
--- CONFIGURATION ---
---------------------
hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        float_gaps = 12,
        border_size = 2,
        col = {
            active_border = { colors = { white } },
            inactive_border = { colors = { border_gray } }
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
        snap = {
            enabled = true,
            respect_gaps = true
        },
    },
    dwindle = {
        force_split = 0,
        preserve_split = true,
        smart_split = false,
        smart_resizing = true
    },
    master = {
        new_status = "master"
    },
    scrolling = {
        fullscreen_on_one_column = true,
        column_width = 0.5,
        focus_fit_method = 1,
        follow_focus = true,
        follow_min_visible = 0.4,
        explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
        direction = "right"
    },
    decoration = {
        rounding = 8,
        rounding_power = 4,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        -- screen_shader = "~/.config/hypr/shaders/example.frag"
        -- screen_shader = "~/.config/hypr/shaders/crt.frag"
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
        shadow = {
            enabled = true,
            scale = 1,
            range = 20,
            render_power = 3,
            offset = "0, 0",
            color = shadow
        },
        glow = {
            enabled = false
        }
    },
    animations = {
        enabled = true
    },
    input = {
        kb_layout      = "us",
        kb_variant     = "",
        kb_model       = "",
        kb_options     = "caps:escape",
        kb_rules       = "",
        follow_mouse   = 1,
        -- Clamped: [-1.0, 1.0]
        sensitivity    = 0,
        accel_profile  = "adaptive",
        natural_scroll = false,
        touchpad       = {
            middle_button_emulation = false,
            natural_scroll = false,
            -- scroll_factor = "",
        }
    },

    gestures = {

    },
    group = {
        insert_after_current = true,
        focus_removed_window = true,
        groupbar = {
            font_size = 10,
            height = 10,
            indicator_height = 6,
            rounding = 3,
        }
    },
    misc = {
        disable_hyprland_logo = false,
        disable_splash_rendering = true,
        font_family = font_family,
        splash_font_family = font_family,
        force_default_wallpaper = -1,
        mouse_move_enables_dpms = true,
        key_press_enables_dpms = true,
        animate_manual_resizes = true,
        animate_mouse_windowdragging = true,
        middle_click_paste = false,
    },
    binds = {},
    xwayland = {},
    opengl = {},
    render = {},
    cursor = {
        enable_hyprcursor = true,
        sync_gsettings_theme = true,
        inactive_timeout = 7,
        zoom_factor = 1.0,
        zoom_rigid = false,
    },
    ecosystem = {
        no_update_news = false,
        no_donation_nag = true,
        enforce_permissions = false,
    },
    quirks = {
        prefer_hdr = 0
    }
})

---------------
--- DEVICES ---
---------------
hl.device({
    name = "logitech-mx-vertical-1",
    sensitivity = -0.6,
})

hl.device({
    name = "logitech-mx-vertical-advanced-ergonomic-mouse-2",
    sensitivity = -0.6,
})

----------------
--- MONITORS ---
----------------
hl.monitor({
    output = "",
    mode = "2560x1440@180",
    position = "0x0",
    scale = "1",
    bitdepth = 16,
    cm = "auto"
})

------------------
--- ANIMATIONS ---
------------------

-- Custom curves ported from old config
hl.curve("windowIn", { type = "bezier", points = { { 0.12, 0.95 }, { 0.08, 1.05 } } })
hl.curve("windowOut", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
hl.curve("workspaceMove", { type = "bezier", points = { { 0.2, 0.9 }, { 0.1, 1 } } })
hl.curve("emphasis", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1 } } })
-- Retained defaults (still referenced below)
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 6, bezier = "default" })
-- Windows
hl.animation({ leaf = "windows", enabled = true, speed = 8, bezier = "windowIn", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 8, bezier = "windowIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "windowOut", style = "popin 72%" })
-- Border
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "emphasis" })
-- Fade
hl.animation({ leaf = "fade", enabled = true, speed = 8, bezier = "windowIn" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 8, bezier = "windowIn" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 7, bezier = "windowOut" })
-- Layers
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "emphasis" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "windowIn", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "windowOut", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
-- Workspaces
hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "workspaceMove", style = "slide" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 7, bezier = "workspaceMove", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 7, bezier = "workspaceMove", style = "slide" })
-- Misc
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

------------------
--- AUTO START ---
------------------

hl.on("hyprland.start", function()
    -- apps --
    hl.exec_cmd(terminal)
    hl.exec_cmd("clipse -listen")
    hl.exec_cmd("qs")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("fcitx5 -d &")
    -- user services --
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("systemctl --user start pipewire.socket")
    hl.exec_cmd("systemctl --user start pipewire-pulse.service")
    hl.exec_cmd("systemctl -- user start wireplumber.service")
    -- Import the full session environment so portals and other D-Bus-activated services
    -- see the same Wayland/toolkit variables as the compositor session.
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
end)

-------------------
--- ENVIRONMENT ---
-------------------
-- hyprland
hl.env("HYPRLAND_TRACE", "1")
-- hyprshot
hl.env("HYPRSHOT_DIR", "$HOME/Pictures/Screenshots")
-- aquamarine
hl.env("AQ_TRACE", "1")
-- backends
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland,x11")
hl.env("CLUTTER_BACKEND", "wayland")
-- xdg
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "HYPRLAND")
-- cursor
hl.env("HYPRCURSOR_THEME", "Adwaita")
hl.env("HYPRCURSOR_SIZE", "22")
hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "22")
-- gtk
hl.env("GTK_CURSOR_THEME", "Adwaita")
hl.env("GTK_CURSOR_SIZE", "22")
-- qt
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
-- nvidia
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GL_VRR_ALLOWED", "0")

--------------------
--- WINDOW RULES ---
--------------------
hl.window_rule({
    name = "clipse",
    float = true,
    center = true,
    size = { "(monitor_w*0.4)", "(monitor_h*0.6)" },
    match = {
        title = "clipse",
    }
})

hl.window_rule({
    name = "portal-hyprland",
    float = true,
    center = true,
    size = { "(monitor_w*0.6)", "(monitor_h*0.6)" },
    match = {
        class = "xdg-desktop-portal-hyprland"
    }
})

hl.window_rule({
    name = "portal-gtk",
    float = true,
    center = true,
    size = { "(monitor_w*0.6)", "(monitor_h*0.6)" },
    match = {
        class = "xdg-desktop-portal-gtk"
    }
})

hl.window_rule({
    name = "portal-gnome",
    float = true,
    center = true,
    size = { "(monitor_w*0.6)", "(monitor_h*0.6)" },
    match = {
        class = "xdg-desktop-portal-gnome"
    }
})

hl.window_rule({
    name = "audio-controls",
    float = true,
    center = true,
    size = { "(monitor_w*0.5)", "(monitor_h*0.5)" },
    match = {
        title = "Volume Control"
    }
})

hl.window_rule({
    name = "steam-settings",
    float = true,
    center = true,
    match = {
        title = "Steam Settings"
    }
})

hl.window_rule({
    name = "godot",
    tile = true,
    match = {
        title = "Godot"
    }
})

hl.window_rule({
    name = "maximize",
    suppress_event = "maximize",
    match = {
        class = ".*"
    }
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Applications
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(files))
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(code))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd(audio))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(music))

-- Hyprland
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + ALT + E", hl.dsp.exit())
hl.bind(mainMod .. " + CTRL + E", hl.dsp.exec_cmd("systemctl suspend"))

-- Dwindle Layout
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("swapsplit"))

-- Hyprpicker
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprpicker -a -f hex"))
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("hyprpicker -a -f rgb"))

-- Screenshots
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -z -m region -o ~/Pictures/Screenshots/"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd("hyprshot -z -m output -o ~/Pictures/Screenshots/"))

-- Wallpaper / Launcher / Lock  (quickshell global dispatches)
hl.bind(mainMod .. " + W", hl.dsp.global("quickshell:wallpaper-selector"))
hl.bind(mainMod .. " + SPACE", hl.dsp.global("quickshell:app-launcher"))
hl.bind(mainMod .. " + L", hl.dsp.global("quickshell:lock-screen"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.global("quickshell:power-menu"))
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.global("quickshell:system-options"))

-- Clipse
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd(terminal .. " --title=clipse -e clipse"))

-- Volume and Media Control
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 2%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- Screen Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +10%"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%- min_value=10%"),
    { repeating = true, locked = true })

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Swap windows
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "down" }))

-- Switch workspaces / move windows with mainMod + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Cycle windows
hl.bind(mainMod .. " + TAB", hl.dsp.window.cycle_next())
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.window.cycle_next("prev"))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Groups (commented out, matching original)
-- hl.bind(mainMod .. " + G",                  hl.dsp.window.toggleGroup())
-- hl.bind(mainMod .. " + TAB",                hl.dsp.window.changeGroupActive())
-- hl.bind(mainMod .. " + CTRL + left",        hl.dsp.window.moveIntoGroup({ direction = "left" }))
-- hl.bind(mainMod .. " + CTRL + right",       hl.dsp.window.moveIntoGroup({ direction = "right" }))
-- hl.bind(mainMod .. " + CTRL + up",          hl.dsp.window.moveIntoGroup({ direction = "up" }))
-- hl.bind(mainMod .. " + CTRL + down",        hl.dsp.window.moveIntoGroup({ direction = "down" }))
-- hl.bind(mainMod .. " + ALT + left",         hl.dsp.window.moveOutOfGroup({ direction = "left" }))
-- hl.bind(mainMod .. " + ALT + right",        hl.dsp.window.moveOutOfGroup({ direction = "right" }))
-- hl.bind(mainMod .. " + ALT + up",           hl.dsp.window.moveOutOfGroup({ direction = "up" }))
-- hl.bind(mainMod .. " + ALT + down",         hl.dsp.window.moveOutOfGroup({ direction = "down" }))

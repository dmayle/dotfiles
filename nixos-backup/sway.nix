{ config, pkgs, lib, ... }:
let

  # Download background image
  bgNixSnowflake = builtins.fetchurl {
    url = "https://i.imgur.com/4Xqpx6R.png";
    sha256 = "bf0d77eceef6d85c62c94084f5450e2125afc4c8eed9f6f81298771e286408ac";
  };
  nvidia-sway = (pkgs.writeShellScriptBin "nvidia-sway" ''
    env \
      MOZ_ENABLE_WAYLAND=1 \
      QT_QPA_PLATFORM=wayland \
      QT_WAYLAND_DISABLE_WINDOWDECORATION="1" \
      SDL_VIDEODRIVER=wayland \
      XDG_CURRENT_DESKTOP="sway" \
      XDG_SESSION_TYPE="wayland" \
      _JAVA_AWT_WM_NONREPARENTING=1 \
      GBM_BACKEND=nvidia-drm \
      GBM_BACKENDS_PATH=/etc/gbm \
      __GLX_VENDOR_LIBRARY_NAME=nvidia \
      WLR_NO_HARDWARE_CURSORS=1 \
      WLR_BACKENDS=libinput,drm \
      VDPAU_DRIVER=va_gl \
      WLR_RENDERER=gles2 \
        sway --unsupported-gpu -d &>/tmp/sway.log
      #WLR_RENDERER=vulkan \
  '');

in
{
  config = {
    environment.systemPackages = [ nvidia-sway ];
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        dmenu
	wofi
	waybar
	grim
	slurp
	tree-sitter
	ddcutil
	i2c-tools
	kitty
	mako
	pamixer
	polkit_gnome
	pulseaudio
	swayidle
	swaylock
	wl-clipboard
	wlsunset
	wev
	wob
	xorg.xhost
	xwayland
	qownnotes
      ];
      extraOptions = [
        "--unsupported-gpu"
        #"--my-next-gpu-wont-be-nvidia"
      ];
      extraSessionCommands = ''
        export MOZ_ENABLE_WAYLAND=1
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        export SDL_VIDEODRIVER=wayland
        export XDG_CURRENT_DESKTOP="sway"
        export XDG_SESSION_TYPE="wayland"
        export _JAVA_AWT_WM_NONREPARENTING=1
        export GBM_BACKEND=nvidia-drm
        export GBM_BACKENDS_PATH=/etc/gbm
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export WLR_NO_HARDWARE_CURSORS=1
	#export WLR_RENDERER=vulkan
        export VDPAU_DRIVER=va_gl
	export WLR_RENDERER=gles2
        export WLR_BACKENDS=libinput,drm
      '';
    };
    #programs.waybar.enable = true;

  systemd.user.targets.sway-session = {
    description = "Sway compositor session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };


  environment.etc."sway/keymap_backtick.xkb".source = ./keymap_backtick.xkb;
  environment.etc."sway/config".text = ''
      # Read `man 5 sway` for a complete reference.

      ### Variables
      #
      # Logo key. Use Mod1 for Alt.
      set $mod Mod4
      # Home row direction keys, like vim
      set $left h
      set $down j
      set $up k
      set $right l
      # Your preferred terminal emulator
      set $term kitty
      # Your preferred application launcher
      # Note: pass the final command to swaymsg so that the resulting window can be opened
      # on the original workspace that the command was run on.
      set $menu dmenu_path | wofi --dmenu | xargs swaymsg exec --

      ### Input configuration

      # Use a UK layout, windows variant
      input * {
          xkb_layout "gb"
          xkb_variant "extd"
          xkb_options "caps:swapescape"
          xkb_numlock enabled
          xkb_file "/etc/sway/keymap_backtick.xkb"
      }
      # output HDMI-A-1 {
      #     scale 1.5
      #     pos 0 0
      #     res 7680x4320
      # }

      # Read `man 5 sway-input` for more information about this section.

      ### Key bindings
      #
      # Basics:
      #
          # Start a terminal
          bindsym $mod+Return exec $term

          # Kill focused window
          bindsym $mod+Shift+q kill

          # Start your launcher
          bindsym $mod+d exec $menu

          # Drag floating windows by holding down $mod and left mouse button.
          # Resize them with right mouse button + $mod.
          # Despite the name, also works for non-floating windows.
          # Change normal to inverse to use left mouse button for resizing and right
          # mouse button for dragging.
          floating_modifier $mod normal

          # Reload the configuration file
          bindsym $mod+Shift+c reload

          # Exit sway (logs you out of your Wayland session)
          bindsym $mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'
      #
      # Moving around:
      #
          # Move your focus around
          bindsym $mod+$left focus left
          bindsym $mod+$down focus down
          bindsym $mod+$up focus up
          bindsym $mod+$right focus right
          # Or use $mod+[up|down|left|right]
          bindsym $mod+Left focus left
          bindsym $mod+Down focus down
          bindsym $mod+Up focus up
          bindsym $mod+Right focus right

          # Move the focused window with the same, but add Shift
          bindsym $mod+Shift+$left move left
          bindsym $mod+Shift+$down move down
          bindsym $mod+Shift+$up move up
          bindsym $mod+Shift+$right move right
          # Ditto, with arrow keys
          bindsym $mod+Shift+Left move left
          bindsym $mod+Shift+Down move down
          bindsym $mod+Shift+Up move up
          bindsym $mod+Shift+Right move right
      #
      # Workspaces:
      #
          # Switch to workspace
          bindsym $mod+1 workspace number 1
          bindsym $mod+2 workspace number 2
          bindsym $mod+3 workspace number 3
          bindsym $mod+4 workspace number 4
          bindsym $mod+5 workspace number 5
          bindsym $mod+6 workspace number 6
          bindsym $mod+7 workspace number 7
          bindsym $mod+8 workspace number 8
          bindsym $mod+9 workspace number 9
          bindsym $mod+0 workspace number 10
          # Move focused container to workspace
          bindsym $mod+Shift+1 move container to workspace number 1
          bindsym $mod+Shift+2 move container to workspace number 2
          bindsym $mod+Shift+3 move container to workspace number 3
          bindsym $mod+Shift+4 move container to workspace number 4
          bindsym $mod+Shift+5 move container to workspace number 5
          bindsym $mod+Shift+6 move container to workspace number 6
          bindsym $mod+Shift+7 move container to workspace number 7
          bindsym $mod+Shift+8 move container to workspace number 8
          bindsym $mod+Shift+9 move container to workspace number 9
          bindsym $mod+Shift+0 move container to workspace number 10
          # Note: workspaces can have any name you want, not just numbers.
          # We just use 1-10 as the default.
      #
      # Layout stuff:
      #
          # You can "split" the current object of your focus with
          # $mod+b or $mod+v, for horizontal and vertical splits
          # respectively.
          bindsym $mod+b splith
          bindsym $mod+v splitv

          # Switch the current container between different layout styles
          bindsym $mod+s layout stacking
          bindsym $mod+w layout tabbed
          bindsym $mod+e layout toggle split

          # Make the current focus fullscreen
          bindsym $mod+f fullscreen

          # Toggle the current focus between tiling and floating mode
          bindsym $mod+Shift+space floating toggle; border normal

          # Swap focus between the tiling area and the floating area
          bindsym $mod+space focus mode_toggle

          # Move focus to the parent container
          bindsym $mod+a focus parent
      #
      # Scratchpad:
      #
          # Sway has a "scratchpad", which is a bag of holding for windows.
          # You can send windows there and get them back later.

          # Move the currently focused window to the scratchpad
          bindsym $mod+Shift+minus move scratchpad

          # Show the next scratchpad window or hide the focused scratchpad window.
          # If there are multiple scratchpad windows, this command cycles through them.
          bindsym $mod+minus scratchpad show
      #
      # Resizing containers:
      #
      mode "resize" {
          # left will shrink the containers width
          # right will grow the containers width
          # up will shrink the containers height
          # down will grow the containers height
          bindsym $left resize shrink width 10px
          bindsym $down resize grow height 10px
          bindsym $up resize shrink height 10px
          bindsym $right resize grow width 10px

          # Ditto, with arrow keys
          bindsym Left resize shrink width 10px
          bindsym Down resize grow height 10px
          bindsym Up resize shrink height 10px
          bindsym Right resize grow width 10px

          # Return to default mode
          bindsym Return mode "default"
          bindsym Escape mode "default"
      }
      bindsym $mod+r mode "resize"


      # Configure Wob (Wayland Overlay Bar)
      exec mkfifo $SWAYSOCK.wob && tail -f $SWAYSOCK.wob | wob

      # Enable polkit for GUI app authorization
      exec "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"

      # Bind print screen key to flameshot
      bindsym Print exec 'flameshot gui'

      # Adjust brightness of external monitor
      bindsym XF86Launch8 exec 'export NEWVOL=$(ddcutil -t getvcp 10 2>/dev/null | awk {print\ \(\$4\<10\)?0:\$4-10}) && (echo $NEWVOL > $SWAYSOCK.wob && ddcutil set 10 $NEWVOL && unset NEWVOL)'
      bindsym XF86Launch9 exec 'export NEWVOL=$(ddcutil -t getvcp 10 2>/dev/null | awk {print\ \(\$4\>90\)?100:\$4+10}) && (echo $NEWVOL > $SWAYSOCK.wob && ddcutil set 10 $NEWVOL && unset NEWVOL)'

      # Volume key bindings
      bindsym XF86AudioRaiseVolume exec 'pamixer -ui 2 && pamixer --get-volume > $SWAYSOCK.wob'
      bindsym XF86AudioLowerVolume exec 'pamixer -ud 2 && pamixer --get-volume > $SWAYSOCK.wob'
      bindsym XF86AudioMute exec 'pamixer --toggle-mute && ( pamixer --get-mute && echo 0 > $SWAYSOCK.wob ) || pamixer --get-volume > $SWAYSOCK.wob'

      # Manually lock session
      bindsym --release $mod+Shift+p exec loginctl lock-session

      # Create terminal as floating
      # bindsym $mod+Shift+Return exec $term --class visor; for_window [class="visor"] move scratchpad, scratchpad show
      #
      # Some rules to prevent screen dim/lock while watching video
      for_window [class="^Firefox$"]                      inhibit_idle fullscreen
      for_window [app_id="^firefox$"]                     inhibit_idle fullscreen
      for_window [class="^Chromium$"]                     inhibit_idle fullscreen
      for_window [class="^Google-chrome$"]                inhibit_idle fullscreen
      for_window [class="^mpv$"]                          inhibit_idle visible
      for_window [app_id="^mpv$"]                         inhibit_idle visible

      # Start sway user session to trigger the start of graphical session
      exec "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK; dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK; systemctl --user start sway-session.target"
    '';

  # This seems to be required by polkit
  environment.pathsToLink = [ "/libexec" ];

  # Setup screensaver / lock with swayidle and swaylock
  systemd.user.services.swayidle = {
    enable = true;
    description = "Screenlock with SwayIdle and SwayLock";
    requiredBy = [ "sway-session.target" ];
    unitConfig = {
      PartOf = [ "sway-session.target" ];
      ConditionGroup = "users";
    };
    serviceConfig = {
      Restart = "always";
      RestartSec = 3;
    };

    path = with pkgs; [ bash swayidle swaylock sway ddcutil ];
    script = ''
      swayidle -w \
        timeout 300 'ddcutil set 10 20' \
          resume 'ddcutil set 10 100' \
        timeout 600 'swaylock -elfF -s fill -i ${bgNixSnowflake}' \
        timeout 900 'swaymsg "output * dpms off"' \
          resume 'swaymsg "output * dpms on" && ddcutil set 10 100' \
        before-sleep 'swaylock -elfF -s fill -i ${bgNixSnowflake}' \
        lock 'swaylock -elfF -s fill -i ${bgNixSnowflake}'
        idlehint 300
    '';
  };

  environment.etc."xdg/waybar/config".text = ''
    // =============================================================================
    //
    // Waybar configuration (https://hg.sr.ht/~begs/dotfiles)
    //
    // Configuration reference: https://github.com/Alexays/Waybar/wiki/Configuration
    //
    // =============================================================================

    {
        // -------------------------------------------------------------------------
        // Global configuration
        // -------------------------------------------------------------------------

        "layer": "top",
        "position": "top",
        "height": 36,

        "modules-left": [
            "sway/mode",
            "sway/workspaces",
            "custom/right-blue-background"
        ],

        "modules-center": [
            "sway/window"
        ],

        "modules-right": [
            "idle_inhibitor",
            "custom/left-yellow-background",
            "pulseaudio",
            "custom/left-magenta-yellow",
            "network",
            "custom/left-base03-magenta",
            "tray",
            "clock#date",
            "custom/left-base3-base03",
            "clock#time"
        ],

        // -------------------------------------------------------------------------
        // Modules
        // -------------------------------------------------------------------------

        "clock#time": {
            "interval": 10,
            "format": "{:%H:%M}",
            "tooltip": false
        },

        "clock#date": {
            "interval": 20,
            "format": "{:%e %b %Y}", // Icon: calendar-alt
            //"tooltip-format": "{:%e %B %Y}"
            "tooltip": false
        },

        "idle_inhibitor": {
            "format": "{icon}",
            "format-icons": {
                "activated": "☕",
                "deactivated": "🥱"
            }
        },

        "network": {
            "interval": 5,
            // TODO: format-icons
            "format-wifi": " {essid} ({signalStrength}%)", // Icon: wifi
            "format-ethernet": "🛰️ {ifname}: {ipaddr}/{cidr}", // Icon: ethernet
            "format-disconnected": "DISCONNECTED",
            "tooltip": false
        },

        "sway/mode": {
            "format": "⚠️ <span style=\"italic\">{}</span>", // Icon: expand-arrows-alt
            "tooltip": false
        },

        "sway/window": {
            "format": "{}",
            "max-length": 30,
            "tooltip": false
        },

        "sway/workspaces": {
            "all-outputs": false,
            "disable-scroll": false,
            "format": " {name} ",
        },

        "pulseaudio": {
            "scroll-step": 2,
            // Format: output sound input sound
            "format": "{icon} {volume}% {format_source}",
            "format-bluetooth": "{icon} {volume}%",
            "format-muted": "🔇 ❌ {format_source}",
            // input sound
            "format-source": "🎙️ {volume}%",
            "format-source-muted": "🎙️ ❌",
            "format-icons": {
                "headphones": "🎧",
                "handsfree": "",
                "headset": "",
                "phone": "",
                "portable": "",
                "car": "",
                "default": ["🔈", "🔉", "🔊"]
            },
            "on-click": "pavucontrol"
        },

        "tray": {
            "icon-size": 21
            //"spacing": 10
        },

        "custom/right-blue-background": {
            "format": "",
            "tooltip": false
        },

        "custom/right-cyan-background": {
            "format": "",
            "tooltip": false
        },

        "custom/left-base3-base03": {
            "format": "",
            "tooltip": false
        },

        "custom/left-base03-magenta": {
            "format": "",
            "tooltip": false
        },

        "custom/left-magenta-yellow": {
            "format": "",
            "tooltip": false
        },

        "custom/left-yellow-background": {
            "format": "",
            "tooltip": false
        },
    }
  '';

  environment.etc."xdg/waybar/style.css".text = ''

    @keyframes blink-warning {
        70% {
            color: @base2;
        }

        to {
            color: @base2;
            background-color: @magenta;
        }
    }

    @keyframes blink-critical {
        70% {
            color: @base2;
        }

        to {
            color: @base2;
            background-color: @red;
        }
    }

    /* Solarized */
    @define-color base03 #002b36;
    @define-color base02 #073642;
    @define-color base01 #586e75;
    @define-color base00 #657b83;
    @define-color base0 #839496;
    @define-color base1 #93a1a1;
    @define-color base2 #eee8d5;
    @define-color base3 #fdf6e3;
    @define-color yellow #b58900;
    @define-color orange #cb4b16;
    @define-color red #dc322f;
    @define-color magenta #d33682;
    @define-color violet #6c71c4;
    @define-color blue #268bd2;
    @define-color cyan #2aa198;
    @define-color green #859900;

    /* Reset all styles */
    * {
        border: none;
        border-radius: 0;
        min-height: 0;
        margin: 0;
        padding: 0;
        font-family: DroidSansMono, Roboto, Helvetica, Arial, sans-serif;
        font-size: 24pt;
    }

    /* The whole bar */
    #waybar {
        background: transparent;
        color: @base2;
        font-family: Terminus, Siji;
        font-size: 30pt;
        /*font-weight: bold;*/
    }

    /* Each module */
    #battery,
    #clock,
    #cpu,
    #language,
    #memory,
    #mode,
    #network,
    #pulseaudio,
    #temperature,
    #custom-alsa,
    #sndio,
    #tray {
        padding-left: 10px;
        padding-right: 10px;
    }

    /* Each module that should blink */
    #mode,
    #memory,
    #temperature,
    #battery {
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
    }

    /* Each critical module */
    #memory.critical,
    #cpu.critical,
    #temperature.critical,
    #battery.critical {
        color: @red;
    }

    /* Each critical that should blink */
    #mode,
    #memory.critical,
    #temperature.critical,
    #battery.critical.discharging {
        animation-name: blink-critical;
        animation-duration: 2s;
    }

    /* Each warning */
    #network.disconnected,
    #memory.warning,
    #cpu.warning,
    #temperature.warning,
    #battery.warning {
        color: @magenta;
    }

    /* Each warning that should blink */
    #battery.warning.discharging {
        animation-name: blink-warning;
        animation-duration: 3s;
    }

    /* And now modules themselves in their respective order */

    #mode { /* Shown current Sway mode (resize etc.) */
        color: @base2;
        background: @mode;
    }

    /* Workspaces stuff */
    #workspaces button {
        /*font-weight: bold;*/
        padding-left: 4px;
        padding-right: 4px;
        color: @base3;
        background: @cyan;
    }

    #workspaces button.focused {
        background: @blue;
    }

    /*#workspaces button.urgent {
        border-color: #c9545d;
        color: #c9545d;
    }*/

    #window {
        margin-right: 40px;
        margin-left: 40px;
    }

    #custom-alsa,
    #pulseaudio,
    #sndio {
        background: @yellow;
        color: @base2;
    }

    #network {
        background: @magenta;
        color: @base2;
    }

    #memory {
        background: @memory;
        color: @base03;
    }

    #cpu {
        background: @cpu;
        color: @base2;
    }

    #temperature {
        background: @temp;
        color: @base03;
    }

    #language {
        background: @layout;
        color: @base2;
    }

    #battery {
        background: @battery;
        color: @base03;
    }

    #tray {
        background: @date;
    }

    #clock.date {
        background: @base03;
        color: @base2;
    }

    #clock.time {
        background: @base3;
        color: @base03;
    }

    #pulseaudio.muted {
        /* No styles */
    }

    #custom-right-blue-background {
        font-size: 38px;
        color: @blue;
        background: transparent;
    }

    #custom-right-cyan-background {
        font-size: 38px;
        color: @cyan;
        background: transparent;
    }

    #custom-left-base3-base03 {
        font-size: 38px;
        color: @base3;
        background: @base03;
    }

    #custom-left-base03-magenta {
        font-size: 38px;
        color: @base03;
        background: @magenta;
    }

    #custom-left-magenta-yellow {
        font-size: 38px;
        color: @magenta;
        background: @yellow;
    }

    #custom-left-yellow-background {
        font-size: 38px;
        color: @yellow;
        background: transparent;
    }
  '';

  };
}


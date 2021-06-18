# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  # Import recent version of unstable for one-off uses
  #unstable = builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/71dc8325680ecfaf145de4f27eed2b9d02477bb5;
  #unstable = builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/bd249526ff5fdfa797673e8f42a99a97c9179c45;
  unstable = builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/83f6711464e03a856fb554693fe2e0f3af2ab0d5;
  unstablePkgs = import unstable { config.allowUnfree = true; };

  # Import NUR user package archive
  nur-no-pkgs = builtins.fetchTarball https://github.com/nix-community/NUR/archive/master.tar.gz;
  nur = import nur-no-pkgs { inherit pkgs; };

  # Download background image
  bgNixSnowflake = builtins.fetchurl {
    url = "https://i.imgur.com/4Xqpx6R.png";
    sha256 = "bf0d77eceef6d85c62c94084f5450e2125afc4c8eed9f6f81298771e286408ac";
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # "${unstable}/nixos/modules/config/xdg/portal.nix"

      # Management if i2c group is in unstable
      #"${unstable}/nixos/modules/hardware/i2c.nix"

      # Working Pipewire is in unstable
      #"${unstable}/nixos/modules/services/desktops/pipewire/pipewire.nix"
      #"${unstable}/nixos/modules/services/desktops/pipewire/pipewire-media-session.nix"

      # Controlling neovim tree-sitter parsers is in unstable
      "${unstable}/nixos/modules/programs/neovim.nix"
    ];
  disabledModules = [
    # "config/xdg/portal.nix"
    #"services/desktops/pipewire.nix"
    "programs/neovim.nix"
  ];

  security.rtkit.enable = true;
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import
      (builtins.fetchTarball https://github.com/nix-community/NUR/archive/master.tar.gz) {
        inherit pkgs;
    };
  };
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  # Since /boot is a separate partition, copy linux kernels
  boot.loader.grub.copyKernels = true;

  # Use EFI boot
  boot.loader.grub.efiSupport = true;

  # Since this is EFI boot, we don't install grub to the partition
  boot.loader.grub.device = "nodev"; # or "nodev" for efi only

  # I shouldn't need more than this, especially since I'll be versioning this file.
  boot.loader.grub.configurationLimit = 50;

  # Required for UEFI... not sure why also grub
  boot.loader.systemd-boot.enable = true;

  # This is true when booting from UEFI
  boot.loader.efi.canTouchEfiVariables = true;

  # Use 5.10 kernel (latest RTS as of 2/2021) for 2.5Gbe support
  boot.kernelPackages = pkgs.linuxPackages_5_10;
  #boot.extraModulePackages = with config.boot.kernelPackages; [ r8169 ];
  #boot.kernelModules = [ "r8169" ];

  # Add i2c-dev so we can use DDC to talk with the monitor
  hardware.i2c.enable = true;
  boot.extraModprobeConfig = ''
    #options i915 enable_fbc=0 enable_dc=0 enable_psr=0
    # Still flickering
    # options i915 enable_fbc=0 enable_psr=0
    # This wasn't enough to stop screen flickering
    # options i915 enable_psr=0
  '';

  # Disable the Gnome3/GDM auto-suspend feature
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Monaco";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # The two detected interfaces on this machine
  networking.interfaces.enp2s0.useDHCP = true;
  # networking.interfaces.eno1.useDHCP = true;
  # networking.interfaces.wlp1s0.useDHCP = true;
  # networking.interfaces.enp2s0 = {
  #   useDHCP = false;
  #   ipv4.addresses = [ {
  #     address = "192.168.88.2";
  #     prefixLength = 24;
  #   } ];
  # };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      fira-code
      freefont_ttf
      fira-code-symbols
      (nerdfonts.override { fonts = [ "DroidSansMono" ]; })
    ];
  };

  # This is a DBUS standard for desktop access, it's used by Flameshot to get
  # screenshot data from wayland
  xdg.portal.enable = true;
  xdg.portal.gtkUsePortal = true;
  xdg.portal.extraPortals = with pkgs; [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
  #xdg.portal.extraPortals = with unstablePkgs;
  #  [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];
  #systemd.user.services.xdg-desktop-portal.environment = {
  #  XDG_DESKTOP_PORTAL_DIR = config.environment.variables.XDG_DESKTOP_PORTAL_DIR;
  #};

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME 3 Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome3.enable = true;


  # Install lorri for better/faster direnv nix integration
  services.lorri.enable = true;

  # Until I can get Ly or Qingy or TBSM working
  services.xserver.displayManager.defaultSession = "sway";
  services.xserver.displayManager.sddm.enable = true;

  # Don't know why this is setup
  services.xserver.libinput.enable = true;

  # Install useful man pages
  documentation.enable = true;
  documentation.man.enable = true;
  documentation.dev.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;
  services.printing.drivers = [ pkgs.brgenml1cupswrapper ];

  # Enable sound, but use Pipewire instead of a hardware pulseaudio
  sound.enable = true;
  hardware.pulseaudio.enable = false;

  # Enable PipeWire Audio System
  services.pipewire = {
    #package = unstablePkgs.pipewire;
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    #media-session.package = unstablePkgs.pipewire.mediaSession;
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.douglas = {
    isNormalUser = true;

    # Group explanations:
    # wheel: sudo access
    # audio: playing sound on desktop
    # sway: Using and controlling SwayWM
    # i2c: Adjust brightness on external display
    # video: Might be unnecessary
    extraGroups = [ "wheel" "audio" "sway" "video" "i2c" ];
  };

  # Enable unfree (for Google Chrome)
  nixpkgs.config.allowUnfree = true;

  # Allow Home Manager
  nix.allowedUsers = [ "@wheel" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Best open source diff GUI and the theme it requires, and colored diff CLI
    meld
    gnome3.adwaita-icon-theme
    colordiff

    manpages

    # Development tools
    gnumake
    git
    universal-ctags
    direnv
    #stdenv.cc.cc.lib
    #pkgs.cc.cc.lib
    gdb
    valgrind

    # Disk management
    gparted

    # systool for debugging i915 issues
    libsysfs

    # Terminals
    alacritty

    # Useful tools
    binutils-unwrapped
    wget
    file
    fzf # Fuzzy Finder
    ripgrep # RipGrep
    pciutils # lspci
    ethtool
    doxygen
    doxygen_gui

    # Brother laser printer driver
    brgenml1cupswrapper

    # 3D Modelling
    openscad
    octave

    # NUR caching
    cachix

    # Maybe try out directfb
    directfb

    # Both browsers are useful
    firefox
    google-chrome
    (unstablePkgs.linkFarm "chrome-without-stable" [
      { name = "bin/google-chrome"; path = google-chrome + /bin/google-chrome-stable; }
    ])

    # Screen capture utility
    unstablePkgs.flameshot

    # Occasional graphics needs
    gimp

    # flutter for development
    unstablePkgs.flutter

    clang-tools

    gnupg

    # Video recording
    unstablePkgs.obs-studio

    # Partiioning
    gparted

    # System/process inspection
    htop
    lsof

    mcfly

    # Pipewire audio inspection
    patchage

    pavucontrol
    qjackctl

    # File Manager
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin

    # My terminal toolkit
    tmux
    neovim

    # Bazel for building software
    unstablePkgs.bazel
    # Utility to allow bazel toolchains to work on NixOS
    patchelf
    # Indexing tool to easily find bazel toolchains that need patching
    nix-index
    # Find replacement used by one-line
    fd

    # Video player
    vlc

    # Handy tools for darting in and out of k8s namespaces
    kubectx

    # Language servers (always latest)
    # Missing dart and SQL
    unstablePkgs.gopls
    unstablePkgs.terraform-ls
    unstablePkgs.rnix-lsp
    unstablePkgs.nodePackages.yaml-language-server
    unstablePkgs.nodePackages.vim-language-server
    unstablePkgs.nodePackages.bash-language-server
    unstablePkgs.nodePackages.dockerfile-language-server-nodejs
    unstablePkgs.python-language-server

    # Languages
    go
    gcc
    dotnet-sdk
    #python3Full
  ];

  # Google Chrome uses the binary google-chrome-stable, but we need google-chrome for flutter to work

  programs.neovim = {
    enable = true;
    runtime."parser/bash.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-bash}/parser";
    runtime."parser/c.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-c}/parser";
    runtime."parser/cpp.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-cpp}/parser";
    runtime."parser/go.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-go}/parser";
    runtime."parser/html.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-html}/parser";
    runtime."parser/javascript.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-javascript}/parser";
    runtime."parser/python.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-python}/parser";
  };

  # Overlays are useful for mucking with config generated by other modules
  nixpkgs.overlays = [
    # Setup xsel and xclip proxy to wl-clipboard
    (self: super: {
      wl-clipboard-x11 = super.stdenv.mkDerivation rec {
        pname = "wl-clipboard-x11";
        version = "5";

        src = super.fetchFromGitHub {
          owner = "brunelli";
          repo = "wl-clipboard-x11";
          rev = "v${version}";
          sha256 = "1y7jv7rps0sdzmm859wn2l8q4pg2x35smcrm7mbfxn5vrga0bslb";
        };

        dontBuild = true;
        dontConfigure = true;
        propagatedBuildInputs = [ super.wl-clipboard ];
        makeFlags = [ "PREFIX=$(out)" ];
      };

      xsel = self.wl-clipboard-x11;
      xclip = self.wl-clipboard-x11;
    })

    # Use nightly neovim because 0.5 has tree sitter!
    (import (builtins.fetchTarball {
          url = https://github.com/nix-community/neovim-nightly-overlay/tarball/5e3737ae3243e2e206360d39131d5eb6f65ecff5;
    }))

    # For when I need to straight up override package with unstable
    (self: super: {
      #xdg-desktop-portal = unstablePkgs.xdg-desktop-portal;

      # Use nightly neovim as the basis for my regular neovim package
      neovim-unwrapped = self.neovim-nightly;
    })

    # Use neovim in the place of vi and vim
    (self: super: {
      neovim = super.neovim.override {
        viAlias = true;
        vimAlias = true;
      };
    })
  ];

  services.upower = {
    enable = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Create a sway user session in systemd that can be used to trigger the
  # graphical session
  systemd.user.targets.sway-session = {
    description = "Sway compositor session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };

  environment.variables.EDITOR = "nvim";

  # Setup Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      # Menu popup (I'm using wofi UI with dmenu for command search)
      dmenu
      wofi

      # Waybar bar replace with idle inhibit support
      waybar

      # Screen capture utils (to be replaced with flameshot)
      grim
      slurp

      # Testing tree sitter parsers
      tree-sitter

      # Brightness (let me know that lock is coming)
      unstablePkgs.ddcutil
      i2c-tools

      # Useful for changing monitor config when docking
      # kanshi

      # Try kitty as terminal
      kitty

      # Wayland notification daemon
      mako

      # Used for controlling volume
      pamixer

      # UI for authorizing root access to apps (e.g. GParted)
      polkit_gnome

      # Don't know if this is necessary
      pulseaudio

      # Used to screen saver / lock
      swayidle
      swaylock

      # Handle clipboard
      wl-clipboard

      # No blue light after sunset
      unstablePkgs.wlsunset

      # Event tester (button press, etc.)
      wev

      # Wayland Overlay Bar (volume change)
      wob

      xorg.xhost

      # Allow X programs to work
      xwayland

      # Simple notes
      qownnotes

      # Gettys
      nur.repos.dmayle.tbsm
    ];
    extraSessionCommands = ''
      export MOZ_ENABLE_WAYLAND=1
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export SDL_VIDEODRIVER=wayland
      export XDG_CURRENT_DESKTOP="sway"
      export XDG_SESSION_TYPE="wayland"
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };

  programs.waybar.enable = true;

  # Additional Sway Config
  # 1. Have sway start this systemd session
  # 2. Configure keyboard media shortcuts for volume
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
      exec "systemctl --user import-environment; systemctl --user start sway-session.target"
    '';

  # This seems to be required by polkit
  environment.pathsToLink = [ "/libexec" ];

  # Setup screensaver / lock with swayidle and swaylock
  systemd.user.services.swayidle = {
    enable = true;
    description = "Screenlock with SwayIdle and SwayLock";
    requiredBy = [ "graphical-session.target" ];
    unitConfig = {
      PartOf = [ "graphical-session.target" ];
      ConditionGroup = "users";
    };
    serviceConfig = {
      Restart = "always";
      RestartSec = 3;
    };

    path = with pkgs; [ bash swayidle swaylock sway unstablePkgs.ddcutil ];
    script = ''
      swayidle -w \
        timeout 3000 'ddcutil set 10 20' \
          resume 'ddcutil set 10 100' \
        timeout 6000 'swaylock -elfF -s fill -i ${bgNixSnowflake}' \
        timeout 9000 'swaymsg "output * dpms off"' \
          resume 'swaymsg "output * dpms on" && ddcutil set 10 100' \
        before-sleep 'swaylock -elfF -s fill -i ${bgNixSnowflake}' \
        lock 'swaylock -elfF -s fill -i ${bgNixSnowflake}'
        idlehint 3000
    '';
  };

  #environment.etc."xdg/waybar/config".text = ''
  #'';
  environment.etc."xdg/waybar/style.css".text = ''
    /* List of colors */

    /* {
        --base03:    #002b36;
        --base02:    #073642;
        --base01:    #586e75;
        --base00:    #657b83;
        --base0:     #839496;
        --base1:     #93a1a1;
        --base2:     #eee8d5;
        --base3:     #fdf6e3;
        --yellow:    #b58900;
        --orange:    #cb4b16;
        --red:       #dc322f;
        --magenta:   #d33682;
        --violet:    #6c71c4;
        --blue:      #268bd2;
        --cyan:      #2aa198;
        --green:     #859900;
    } */

    * {
        border: none;
        border-radius: 0;
        font-family: Hack, Helvetica, Arial, sans-serif;
        font-size: 13px;
        min-height: 0;
    }

    window#waybar {
        background-color: #002b36;
        color: #d33682;
        transition-property: background-color;
        transition-duration: .5s;
    }

    window#waybar.hidden {
        opacity: 0.2;
    }

    /*
    window#waybar.empty {
        background-color: transparent;
    }
    window#waybar.solo {
        background-color: #FFFFFF;
    }
    */

    window#waybar.termite {
        background-color: #3F3F3F;
    }

    window#waybar.chromium {
        background-color: #000000;
        border: none;
    }

    #workspaces {
        border-bottom: 1px solid #586e75;
    }

    /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
    #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #657b83;
        border-bottom: 3px solid transparent;
    }

    #workspaces button.focused {
        background-color: #073642;
        border-bottom: 1px solid #ff0;
    }

    #workspaces button.urgent {
        background-color: #d33682;
    }

    #mode {
        background-color: #002b36;
        border-bottom: 1px solid #dc322f;
    }

    #clock, #battery, #cpu, #memory, #temperature, #backlight, #network, #pulseaudio, #custom-media, #tray, #mode, #idle_inhibitor {
        padding: 0 10px;
        margin: 0 2px;
        color: #657b83;
    }
    /*
    #clock {
        background-color: #073642;
    }
    */
    #battery {
        background-color: #073642;
    }

    #battery.charging {
        color: #eee8d5;
        background-color: #859900;
    }

    @keyframes blink {
        to {
            background-color: #d33682;
            color: #93a1a1;
        }
    }

    #battery.critical:not(.charging) {
        background-color: #dc322f;
        color: #93a1a1;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
    }

    label:focus {
        background-color: #073642;
    }

    #cpu {
        background-color: #073642;
    }

    #memory {
        background-color: #073642;
    }

    #backlight {
        background-color: #073642;
    }

    #network {
        background-color: #073642;
    }

    #network.disconnected {
        background-color: #002b36;
    }

    #pulseaudio {
        background-color: #073642;
    }

    #pulseaudio.muted {
        background-color: #002b36;
    }

    #custom-media {
        background-color: #66cc99;
        color: #2a5c45;
        min-width: 100px;
    }

    #custom-media.custom-spotify {
        background-color: #66cc99;
    }

    #custom-media.custom-vlc {
        background-color: #ffa000;
    }

    #temperature {
        background-color: #073642;
    }

    #temperature.critical {
        background-color: #dc322f;
    }

    #tray {
        background-color: #002b36;
    }

    #idle_inhibitor {
        background-color: #002b36;
    }

    #idle_inhibitor.activated {
        background-color: #073642;
    }
  '';

  environment.etc.inputrc.text = (builtins.readFile "${unstable}/nixos/modules/programs/bash/inputrc") + ''
    set editing-mode vi
    set keymap vi
  '';

  # Setup for Ly Getty/Display Manager
  environment.etc."xdg/tbsm/sway.desktop".source = "${pkgs.sway-unwrapped}/share/wayland-sessions/sway.desktop";
  environment.etc."xdg/tbsm/whitelist/sway.desktop".source = "${pkgs.sway-unwrapped}/share/wayland-sessions/sway.desktop";
  environment.etc."xdg/tbsm/tbsm.conf".text = ''
    verboseLevel="3"  # 0=quiet, 1=silent, 2=info, 3=verbose
    configDir=/etc/xdg/tbsm
    defaultSession="${pkgs.sway-unwrapped}/share/wayland-sessions/sway.desktop"
  '';
  environment.etc."ly/config.ini".text = ''
    animate = true
    tty = 2
    path = /run/current-system/sw/bin
    waylandsessions = ${pkgs.sway-unwrapped}/share/wayland-sessions
    mcookie_cmd = mcookie
    restart_cmd = reboot
    save_file = /tmp/ly-save
    shutdown = shutdown -h now
    # term_reset_cmd = echo tput
  '';
  environment.etc."ly/lang".source = "${pkgs.ly}/etc/ly/lang";

  # programs.ly.enable = true;
  # services.xserver.displayManager.ly.enable = true;
  # systemd.services.ly = {
  #   enable = true;
  #   description = "TUI display manager";
  #   documentation = [ "https://github.com/nullgemm/ly" ];
  #   conflicts = [ "getty@tty2.service" ];
  #   after = [
  #     "systemd-user-sessions.service"
  #     "plymouth-quit-wait.service"
  #     "getty@tty2.service"
  #     "user.slice"
  #   ];
  #   aliases = [ "display-manager.service" ];
  #   requires = [ "user.slice" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "idle";
  #     ExecStart = "${pkgs.nur.repos.fgaz.ly}/bin/ly";
  #     StandardInput = "tty";
  #     TTYPath = "/dev/tty2";
  #     TTYReset = "yes";
  #     TTYVHangup = "yes";
  #   };
  # };
  # systemd.services.tbsm = {
  #   enable = true;
  #   description = "TUI display manager";
  #   documentation = [ "https://github.com/loh-tar/tbsm" ];
  #   conflicts = [ "getty@tty2.service" ];
  #   after = [
  #     "systemd-user-sessions.service"
  #     "plymouth-quit-wait.service"
  #     "getty@tty2.service"
  #     "user.slice"
  #   ];
  #   aliases = [ "display-manager.service" ];
  #   requires = [ "user.slice" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "idle";
  #     ExecStart = "${pkgs.nur.repos.dmayle.tbsm}/bin/tbsm";
  #     StandardInput = "tty";
  #     TTYPath = "/dev/tty2";
  #     TTYReset = "yes";
  #     TTYVHangup = "yes";
  #   };
  # };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}


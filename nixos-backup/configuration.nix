# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  # Import recent version of unstable for one-off uses
  unstable = builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/0b876eaed3ed4715ac566c59eb00004eca3114e8;
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
      "${unstable}/nixos/modules/hardware/i2c.nix"

      # Working Pipewire is in unstable
      "${unstable}/nixos/modules/services/desktops/pipewire/pipewire.nix"
      "${unstable}/nixos/modules/services/desktops/pipewire/pipewire-media-session.nix"
    ];
  disabledModules = [
    # "config/xdg/portal.nix"
    "services/desktops/pipewire.nix"
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

  # Add i2c-dev so we can use DDC to talk with the monitor
  #boot.kernelModules = [ "i2c-dev" ];
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
  networking.interfaces.eno1.useDHCP = true;
  # networking.interfaces.wlp1s0.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  # This is a DBUS standard for desktop access, it's used by Flameshot to get
  # screenshot data from wayland
  xdg.portal.enable = true;
  xdg.portal.gtkUsePortal = true;
  xdg.portal.extraPortals = with unstablePkgs;
    [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME 3 Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome3.enable = true;
  

  # Until I can get Ly or Qingy or TBSM working
  services.xserver.displayManager.defaultSession = "sway";
  services.xserver.displayManager.sddm.enable = true;

  # Don't know why this is setup
  services.xserver.libinput.enable = true;

  # Configure keymap in X11 (not the fully correct one)
  services.xserver.layout = "gb";
  services.xserver.xkbOptions = "caps:swapescape";

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
    package = unstablePkgs.pipewire;
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    media-session.package = unstablePkgs.pipewire.mediaSession;
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.douglas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "sway" "video" "i2c" ]; # Enable ‘sudo’ for the user.
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

    # Development tools
    gnumake
    git
    universal-ctags

    # Add upower for power management
    # unstablePkgs.upower

    # systool for debugging i915 issues
    libsysfs

    # Terminals
    alacritty

    # Useful tools
    binutils-unwrapped
    wget

    # Brother laser printer driver
    brgenml1cupswrapper

    # NUR caching
    cachix

    # Maybe try out directfb
    directfb

    # Both browsers are useful
    firefox
    google-chrome

    # Screen capture utility
    unstablePkgs.flameshot

    # Occasional graphics needs
    gimp

    gnupg

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

    # My terminal toolkit
    tmux
    vim

    # Video player
    vlc
  ];

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

    # For when I need to straight up override package with unstable
    (self: super: {
      xdg-desktop-portal = unstablePkgs.xdg-desktop-portal;
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

  environment.variables.EDITOR = "vim";

  # Setup Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      # Menu bar (using dmenu_path to support wofi)
      dmenu
      wofi

      # Screen capture utils (to be replaced with flameshot)
      grim
      slurp

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
      export XKB_DEFAULT_LAYOUT=gb
      export XKB_DEFAULT_OPTIONS="caps:swapescape"
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };

  # Additional Sway Config
  # 1. Have sway start this systemd session
  # 2. Configure keyboard media shortcuts for volume
  environment.etc."sway/config".text = builtins.replaceStrings [ "alacritty" "dmenu " ] [ "kitty" "wofi --dmenu " ] (builtins.readFile "${pkgs.sway}/etc/sway/config") + ''
      # Start sway user session to trigger the start of graphical session
      exec "systemctl --user import-environment; systemctl --user start sway-session.target"

      # Configure Wob (Wayland Overlay Bar)
      exec mkfifo $SWAYSOCK.wob && tail -f $SWAYSOCK.wob | wob

      # Enable polkit for GUI app authorization
      exec "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"

      # Bind print screen key to flameshot
      bindsym Print exec 'flameshot gui'

      bindsym XF86Launch8 exec 'export NEWVOL=$(ddcutil -t getvcp 10 2>/dev/null | awk {print\ \(\$4\<10\)?0:\$4-10}) && (echo $NEWVOL > $SWAYSOCK.wob && ddcutil set 10 $NEWVOL && unset NEWVOL)'
      bindsym XF86Launch9 exec 'export NEWVOL=$(ddcutil -t getvcp 10 2>/dev/null | awk {print\ \(\$4\>90\)?100:\$4+10}) && (echo $NEWVOL > $SWAYSOCK.wob && ddcutil set 10 $NEWVOL && unset NEWVOL)'
      #bindsym XF86Launch8 exec 'export NEWVOL=$(ddcutil -t getvcp 10 2>/dev/null | awk {print\ \(\$4\<10\)?0:\$4-10}) && (ddcutil set 10 $NEWVOL && echo $NEWVOL > $SWAYSOCK.wob && unset NEWVOL)'
      #bindsym XF86Launch9 exec 'export NEWVOL=$(ddcutil -t getvcp 10 2>/dev/null | awk {print\ \(\$4\>90\)?100:\$4+10}) && (ddcutil set 10 $NEWVOL && echo $NEWVOL > $SWAYSOCK.wob && unset NEWVOL)'

      # Volume key bindings
      bindsym XF86AudioRaiseVolume exec 'pamixer -ui 2 && pamixer --get-volume > $SWAYSOCK.wob'
      bindsym XF86AudioLowerVolume exec 'pamixer -ud 2 && pamixer --get-volume > $SWAYSOCK.wob'
      bindsym XF86AudioMute exec 'pamixer --toggle-mute && ( pamixer --get-mute && echo 0 > $SWAYSOCK.wob ) || pamixer --get-volume > $SWAYSOCK.wob'
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

    path = with pkgs; [ bash swayidle swaylock sway ];
    script = ''
      swayidle -w \
        timeout 300 'swaylock -elfF -s fill -i ${bgNixSnowflake}' \
        timeout 600 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
        before-sleep 'swaylock -elfF -s fill -i ${bgNixSnowflake}' \
        lock 'swaylock -elfF -s fill -i ${bgNixSnowflake}'
        idlehint 300
    '';
  };

  environment.etc.inputrc.text = (builtins.readFile "${unstable}/nixos/modules/programs/bash/inputrc") + ''
    set editing-mode vi
    set keymap vi
  '';

  # Setup for Ly Getty/Display Manager
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


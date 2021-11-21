# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:
let
  nvidia-acceleration-overlay = (self: super: {
    linuxPackages = super.linuxPackages.extend (final: prev: {
      nvidia_x11.args = [ "-e" ./nvidia_x11_builder.sh ];
      #nvidia_x11.libPath = super.pkgs.lib.makeLibraryPath [ super.pkgs.libdrm super.pkgs.xorg.libXext super.pkgs.xorg.libX11 super.pkgs.xorg.libXv super.pkgs.xorg.libXrandr super.pkgs.xorg.libxcb super.pkgs.zlib super.pkgs.stdenv.cc.cc super.pkgs.wayland super.pkgs.mesa super.pkgs.libglvnd ];
      #nvidia_x11.libPath32 = super.pkgsi686Linux.lib.makeLibraryPath [ super.pkgsi686Linux.libdrm super.pkgsi686Linux.xorg.libXext super.pkgsi686Linux.xorg.libX11 super.pkgsi686Linux.xorg.libXv super.pkgsi686Linux.xorg.libXrandr super.pkgsi686Linux.xorg.libxcb super.pkgsi686Linux.zlib super.pkgsi686Linux.stdenv.cc.cc super.pkgsi686Linux.wayland super.pkgsi686Linux.mesa super.pkgsi686Linux.libglvnd ];
    });
    glxinfo = super.glxinfo.overrideAttrs ( old: {
      buildInputs = with super.pkgs; [ xorg.libX11 libglvnd ];
    });
    # glmark2 = super.glmark2.overrideAttrs ( old: {
    #   buildInputs = with super.pkgs; [ xorg.libX11 libglvnd ];
    # });
    #mesa = super.mesa.overrideAttrs ( old: {
    #  mesonFlags = super.mesa.mesonFlags ++ [ "-Dgbm-backends-path=/run/opengl-driver/lib/gbm:${placeholder "out"}/lib/gbm:${placeholder "out"}/lib" ];
    #});
    # steamPackages = super.steamPackages.overrideAttrs (old1: {
    #   steam-runtime = old1.steamPackages.steam-runtime.overrideAttrs ( old2: {
    #   });
    # });
    xdg-desktop-portal-wlr = super.xdg-desktop-portal-wlr.overrideAttrs ( old: rec {
      pname = "xdg-desktop-portal-wlr";
      version = "0.5.0";
      src = super.fetchFromGitHub {
        owner = "emersion";
	repo = pname;
	rev = "v${version}";
	sha256 = "sha256:1ipg35gv8ja39ijwbyi96qlyq2y1fjdggl40s38rv68bsya8zry1";
      };
    });
    meson59 = super.meson.overrideAttrs ( old: rec {
      pname = "meson";
      version = "0.59.0";
      patches = builtins.filter (elem: elem != (builtins.elemAt super.meson.patches 2)) super.meson.patches ++ [ ./gir-fallback-path-59.patch ];
      src = super.python3.pkgs.fetchPypi {
        inherit pname version;
	sha256 = "sha256:0xp45ihjkl90s4crzh9qmaajxq7invbv5k0yw3gl7dk4vycc4xp3";
      };
    });
    wlroots = super.wlroots.overrideAttrs( old: {
      # version = "0.14.2";
      # nativeBuildInputs = with super.pkgs; [ meson59 ninja pkg-config xwayland ];
      # buildInputs = with super.pkgs; [
      #   libGL
      #   libglvnd
      #   wayland
      #   wayland-protocols
      #   libinput
      #   libxkbcommon
      #   pixman
      #   xorg.xcbutilwm
      #   xorg.libX11
      #   libcap
      #   xorg.xcbutilimage
      #   xorg.xcbutilerrors
      #   mesa
      #   libpng
      #   ffmpeg
      #   xorg.xcbutilrenderutil
      #   #super.pkgs.seatd
      #   libseat
      #   libdrm
      #   libuuid
      #   vulkan-headers
      #   vulkan-loader
      #   glslang
      # ];
      # src = super.fetchFromGitLab {
      #   domain = "gitlab.freedesktop.org";
      #   owner = "wlroots";
      #   repo = "wlroots";
      #   rev = "02a1ae169e66f53f2174add581c19d165d8ba882";
      #   sha256 = "sha256:1rkhpkylm3gdxksmdjgbaknn2yf7bbyhd77p9ajz79bfks5l7sli";
      # };
      postPatch = ''
        sed -i 's/assert(argb8888 &&/assert(true || argb8888 ||/g' 'render/wlr_renderer.c'
        #sed -i 's/\(EGL_EXT_device_enumeration")\)/\1 || check_egl_ext(client_exts_str, "EGL_EXT_device_base")/' 'render/egl.c'
        #sed -i 's/\(EGL_EXT_device_query")\)/\1 || check_egl_ext(client_exts_str, "EGL_EXT_device_base")/' 'render/egl.c'
      '';
    });
    # sway
    # fc25e4944efdc5bc7e33a81180908927dba93ee6
    # sway-unwrapped = super.sway-unwrapped.overrideAttrs ( old: {
    #   version = "1.6.2";
    #   nativeBuildInputs = with super.pkgs; [ meson59 ninja pkg-config wayland-scanner scdoc ];
    #   buildInputs = with super.pkgs; [
    #     wayland
    #     libxkbcommon
    #     pcre
    #     json_c
    #     dbus
    #     libevdev
    #     pango
    #     cairo
    #     libinput
    #     libcap
    #     pam
    #     gdk-pixbuf
    #     librsvg
    #     wayland-protocols
    #     libdrm
    #     wlroots
    #   ];
    #   src = super.fetchFromGitHub {
    #     owner = "swaywm";
    #     repo = "sway";
    #     rev = "fc25e4944efdc5bc7e33a81180908927dba93ee6";
    #     sha256 = "sha256:1y0ara7hvg88qd9avida1cji3hgpxazl92n294rw6bmnyzc4y1nj";
    #   };
    # });
    # libdrm = super.libdrm.overrideAttrs ( old: rec {
    #   pname = "libdrm";
    #   version = "2.4.108";
    #   src = super.fetchurl {
    #     url = "https://dri.freedesktop.org/${pname}/${pname}-${version}.tar.xz";
    #     sha256 = "sha256-odeUjLxTZ2P94UtL615Np4Z2B5ZtTPRjAQh+i4/j1qA=";
    #   };
    # });
    xwayland = super.xwayland.overrideAttrs (old: rec {
      pname = "xwayland";
      version = "21.1.3";
      src = super.fetchurl {
        url = "mirror://xorg/individual/xserver/${pname}-${version}.tar.xz";
        sha256 = "sha256-68J1fzn9TH2xZU/YZZFYnCEaogFy1DpU93rlZ87b+KI=";
      };
      buildInputs = with super.pkgs; [
        egl-wayland
        epoxy
        xorg.fontutil
        libglvnd
        xorg.libX11
        xorg.libXau
        xorg.libXaw
        xorg.libXdmcp
        xorg.libXext
        xorg.libXfixes
        xorg.libXfont2
        xorg.libXmu
        xorg.libXpm
        xorg.libXrender
        xorg.libXres
        xorg.libXt
        libdrm
        libtirpc
        libunwind
        xorg.libxcb
        xorg.libxkbfile
        xorg.libxshmfence
        mesa
        openssl
        pixman
        wayland
        wayland-protocols
        xorg.xkbcomp
        xorg.xorgproto
        xorg.xtrans
        zlib
      ];
    });
  });

in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./sound.nix
      ./sway.nix
      ./nvidia-wayland.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  nixpkgs.config.packageOverrides = superPkgs: {
    pkgsi686Linux = superPkgs.pkgsi686Linux.extend (final: prev: {
      glxinfo = prev.glxinfo.overrideAttrs ( old: {
        buildInputs = with prev.pkgsi686Linux; [ xorg.libX11 libglvnd ];
      });
    });
    steam-runtime = superPkgs.steam-runtime.overrideAttrs ( old: {
        buildCommand = ''
          echo STAGE 1
          mkdir -p $out
          echo STAGE 2
          tar -C $out --strip=1 -x -J -f $src
          echo STAGE 3
        '';
    });
  };

  #programs.steam.enable = true;
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp6s18.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
# Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };
  # xkbmodel
  # layout
  # xkboptions
  # xkbvariantk

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

  xdg.portal.enable = true;
  xdg.portal.gtkUsePortal = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-wlr
    #xdg-desktop-portal-gtk
    #xdg-desktop-portal-kde
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  documentation.enable = true;
  documentation.man.enable = true;
  documentation.dev.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  #services.xserver.displayManager.defaultSession = "sway";
  #services.xserver.desktopManager.gnome.enable = true;
  services.xserver.libinput.enable = true;

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.upower = {
    enable = true;
  };



  # Configure keymap in X11
  services.xserver.layout = "gb";
  # Command separated options
  services.xserver.xkbOptions = "caps:swapescape";
  services.xserver.xkbVariant = "extd";
  services.xserver.xkbModel = "pc105";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
  users.users.douglas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "sway" "video" "i2c" ];
  };
  nixpkgs.config.allowUnfree = true;
  nix.allowedUsers = [ "@wheel" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  #   firefox
  # ];
  environment.systemPackages = with pkgs; [
    steamPackages.steam-runtime
    glxinfo
    glmark2
    meld
    colordiff
    anki
    gnumake
    git
    universal-ctags
    direnv
    gdb
    valgrind
    gparted
    libsysfs
    fzf
    ripgrep
    pciutils
    ethtool
    doxygen
    doxygen_gui
    nix-du
    graphviz
    openscad
    octave
    flameshot
    gimp
    flutter
    clang-tools
    gnupg
    mcfly
    xfce.thunar
    xfce.thunar-volman
    xfce.thunar-archive-plugin
    bazel
    bazel-buildtools
    nix-index
    fd
    vlc
    gopls
    terraform-ls
    rnix-lsp
    nodePackages.yaml-language-server
    nodePackages.vim-language-server
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    python-language-server
    go
    gcc
    dotnet-sdk

    manpages
    git
    kitty
    binutils-unwrapped
    wget
    flameshot
    htop
    lsof
    tmux
    google-chrome
    file
  ];

  nixpkgs.overlays = [
    nvidia-acceleration-overlay
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
	propagateBuildInputs = [ super.wl-clipboard ];
	makeFlags = [ "PREFIX=$(out)" ];
      };

      xsel = self.wl-clipboard-x11;
      xclip = self.wl-clipboard-x11;
    })
  ];

  environment.etc.inputrc.text = lib.mkAfter ''
    set editing-mode vi
    set keymap vi
  '';
  environment.variables.EDITOR = "nvim";

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}


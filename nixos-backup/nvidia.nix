{ config, pkgs, lib, ... }:
let
  #nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;
  colemickens = builtins.fetchTarball {
    name = "cmpkgs";
    #url = "https://github.com/colemickens/nixpkgs/archive/816de73e8163ee28c79965e0ae2d7a6a976db5ca.tar.gz";
    #sha256 = "sha256:1i2g88mkh3mkg0gwm4r22rycifhcnh09060qlj7xamnv24jywdyl";
    url = "https://github.com/colemickens/nixpkgs/archive/696822355521b2e33b6d166011f930cc80291bed.tar.gz";
    sha256 = "sha256:07bbkysihw7151ng6np8sz5xqxwxza4djjkw6vi8g63n6k91sqvq";
  };
  cmPkgs = import colemickens { config.allowUnfree = true; };
  overlayCMP = (self: super: {
    nvidia-x11 = cmPkgs.nvidia-x11;
    linuxPackages = super.linuxPackages.extend (final: prev: {
      nvidiaPackages = prev.nvidiaPackages // {
        stable = cmPkgs.linuxPackages.nvidiaPackages.stable;
      };
    });
    pkgsi686Linux = super.pkgsi686Linux.extend (final: prev: {
      mesa = cmPkgs.pkgsi686Linux.mesa;
      libva-minimal = cmPkgs.libva-minimal;
      libvdpau = cmPkgs.libvdpau;
    });
    # steamPackages = super.steamPackages // {
    #   steam = cmPkgs.steamPackages.steam;
    #   steamcmd = cmPkgs.steamPackages.steamcmd;
    #   steam-runtime = cmPkgs.steamPackages.steam-runtime;
    #   steam-fonts = cmPkgs.steamPackages.steam-fonts;
    #   steam-runtime-wrapped = cmPkgs.steamPackages.steam-runtime-wrapped;
    # };
    # gst_all_1 = super.gst_all_1 // {
    #   gst-plugins-base = cmPkgs.gst_all_1.gst-plugins-base;
    #   gst-plugins-ugly = cmPkgs.gst_all_1.gst-plugins-ugly;
    # };
    # steam = cmPkgs.steam;
    # steam-run = cmPkgs.steam-run;
    # wine = cmPkgs.wine;
    # faudio = cmPkgs.faudio;
    #gtk3 = cmPkgs.gtk3;
    #libva = cmPkgs.libva;
    #wayland = cmPkgs.wayland;
    #SDL2 = cmPkgs.SDL2;
    #libxkbcommon = cmPkgs.libxkbcommon;
    #vaapiVdpau = cmPkgs.vaapiVdpau;
    #libvdpau-va-gl = cmPkgs.libvdpau-va-gl;
    #wayland-protocols = cmPkgs.wayland-protocols;
    #vulkan-loader = cmPkgs.vulkan-loader;
    mesa = cmPkgs.mesa;
    #ffmpeg = cmPkgs.ffmpeg;
    #libva = cmPkgs.libva;
    libva-minimal = cmPkgs.libva-minimal;
    libvdpau = cmPkgs.libvdpau;
    #pipewire = cmPkgs.pipewire;
    xwayland = super.xwayland.overrideAttrs (old: rec {
      version = "21.1.3";
      src = super.fetchFromGitLab {
        domain = "gitlab.freedesktop.org";
        owner = "xorg";
        repo = "xserver";
        rev = "21e3dc3b5a576d38b549716bda0a6b34612e1f1f";
        sha256 = "sha256-i2jQY1I9JupbzqSn1VA5JDPi01nVA6m8FwVQ3ezIbnQ=";
      };
    });
  });

  # nvidia-sway = (pkgs.writeShellScriptBin "nvidia-sway" ''
  #   env \
  #     GBM_BACKEND=nvidia-drm \
  #     GBM_BACKENDS_PATH=/etc/gbm \
  #     __GLX_VENDOR_LIBRARY_NAME=nvidia \
  #     WLR_NO_HARDWARE_CURSORS=1 \
  #       sway --unsupported-gpu -d &>/tmp/sway.log
  # '');
  nvidia-wlroots-overlay = (final: prev: {
    wlroots = prev.wlroots.overrideAttrs(old: {
      postPatch = ''
        sed -i 's/assert(argb8888 &&/assert(true || argb8888 ||/g' 'render/wlr_renderer.c'
      '';
    });
  });
in
{
  # Want head sway
  imports = [
    ./wayland-tweaks.nix
  ];

  config = {
    #programs.steam.enable = true;
    #boot.kernelPackages = cmPkgs.linuxPackages_5_10;
    environment.etc."gbm/nvidia-drm_gbm.so".source = "${nvidiaPackage}/lib/libnvidia-allocator.so";
    environment.etc."egl/egl_external_platform.d".source = "/run/opengl-driver/share/egl/egl_external_platform.d/";
    hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;
    hardware.opengl.driSupport32Bit = false;
    hardware.pulseaudio.support32Bit = false;
    #hardware.opengl.extraPackages = with pkgs; [
    #  vaapiVdpau
    #  libvdpau-va-gl
    #  libva
    #];
    #hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [
    #  vaapiVdpau
    #  libvdpau-va-gl
    #  xorg.libXrender
    #  xorg.libXi
    #  #libpulseaudio
    #  libva
    #];
    nixpkgs.overlays = [ nvidia-wlroots-overlay overlayCMP ];
    environment.systemPackages = with pkgs; [
      #(steam.override {
      #  extraPkgs = pkgs: [ libva ];
      #}).run
      #steam.run
      #wineWowPackages.staging
      #winetricks
      #mesa-demos
      #xwayland
      #firefox
      vulkan-tools
      #sway
      libva-utils
    ];

    hardware.nvidia.modesetting.enable = true;
    hardware.nvidia.package = nvidiaPackage;
    hardware.nvidia.powerManagement.enable = false;

    services.xserver = {
      videoDrivers = [ "nvidia" ];
      displayManager.gdm.wayland = true;
      displayManager.gdm.nvidiaWayland = true;
    };
  };
}

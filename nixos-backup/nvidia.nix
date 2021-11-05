{ config, pkgs, lib, ... }:
let
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.beta;
  colemickens = builtins.fetchTarball {
    name = "cmpkgs";
    #url = "https://github.com/colemickens/nixpkgs/archive/f2424637430b0cefece0481a3648c41871f0f663.tar.gz";
    #sha256 = "130r5252b9q420swrd50fc2ak5c5ayyaf7jpp0hdlzki8imag7s7";
    url = "https://github.com/colemickens/nixpkgs/archive/816de73e8163ee28c79965e0ae2d7a6a976db5ca.tar.gz";
    #sha256 = lib.fakeSha256;
    sha256 = "sha256:1i2g88mkh3mkg0gwm4r22rycifhcnh09060qlj7xamnv24jywdyl";
  };
  cmPkgs = import colemickens { config.allowUnfree = true; };
  overlayCMP = (self: super: {
    nvidia-x11 = cmPkgs.nvidia-x11;
    linuxPackages = super.linuxPackages.extend (final: prev: {
      nvidiaPackages = prev.nvidiaPackages // {
        beta = cmPkgs.linuxPackages.nvidiaPackages.beta;
      };
    });
    mesa = cmPkgs.mesa;
    libva-minimal = cmPkgs.libva-minimal;
    ffmpeg = cmPkgs.ffmpeg;
    #wayland = cmPkgs.wayland;
    SDL2 = cmPkgs.SDL2;
    pipewire = cmPkgs.pipewire;
    libvdpau = cmPkgs.libvdpau;
    libxkbcommon = cmPkgs.libxkbcommon;
    vaapiVdpau = cmPkgs.vaapiVdpau;
    libvdpau-va-gl = cmPkgs.libvdpau-va-gl;
    wayland-protocols = cmPkgs.wayland-protocols;
    vulkan-loader = cmPkgs.vulkan-loader;
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

  nvidia-sway = (pkgs.writeShellScriptBin "nvidia-sway" ''
    env \
      GBM_BACKEND=nvidia-drm \
      GBM_BACKENDS_PATH=/etc/gbm \
      __GLX_VENDOR_LIBRARY_NAME=nvidia \
      WLR_NO_HARDWARE_CURSORS=1 \
        sway --unsupported-gpu -d &>/tmp/sway.log
  '');
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
    environment.etc."gbm/nvidia-drm_gbm.so".source = "${nvidiaPackage}/lib/libnvidia-allocator.so";
    #environment.etc."egl/egl_external_platform.d".source = "/run/opengl-driver/share/egl/egl_external_platform.d/";
    hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;
    hardware.opengl.driSupport32Bit = true;
    hardware.opengl.extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
    ];
    hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiVdpau
      libvdpau-va-gl
    ];
    nixpkgs.overlays = [ nvidia-wlroots-overlay overlayCMP ];
    environment.systemPackages = with pkgs; [
      #steam
      #steam.run
      #wineWowPackages.staging
      #winetricks
      mesa-demos
      vulkan-tools
      nvidia-sway
      xwayland
      libva-utils
      firefox
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

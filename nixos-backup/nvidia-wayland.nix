{ config, pkgs, lib, ... }:
let
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;

  # nvidia-sway = (pkgs.writeShellScriptBin "nvidia-sway" ''
  #   env \
  #     GBM_BACKEND=nvidia-drm \
  #     GBM_BACKENDS_PATH=/etc/gbm \
  #     __GLX_VENDOR_LIBRARY_NAME=nvidia \
  #     WLR_NO_HARDWARE_CURSORS=1 \
  #       sway --unsupported-gpu -d &>/tmp/sway.log
  # '');
in
{
  # Want head sway
  imports = [
    ./wayland-tweaks.nix
    #./sway.nix
  ];
  # libPathFor for nvidia_x11
  # mesonFlags append for mesa
  # builder.sh for nvidia_x11

  config = {
    environment.etc."gbm/nvidia-drm_gbm.so".source = "${nvidiaPackage}/lib/libnvidia-allocator.so";
    environment.etc."egl/egl_external_platform.d".source = "/run/opengl-driver/share/egl/egl_external_platform.d/";
    hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;
    hardware.opengl.driSupport32Bit = true;
    hardware.pulseaudio.support32Bit = true;
    #programs.steam.enable = true;
    hardware.opengl.extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      libvdpau
      libva
      vdpauinfo
    ];
    hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiVdpau
      libvdpau-va-gl
      libvdpau
      xorg.libXrender
      xorg.libXi
      libpulseaudio
      libva
      vdpauinfo
    ];
    environment.systemPackages = with pkgs; [
      #(steam.override {
      #  extraPkgs = pkgs: [ libva ];
      #}).run
      #steam.run
      #wineWowPackages.staging
      #winetricks
      #mesa-demos
      xwayland
      #nvidia-sway
      firefox
      vulkan-tools
      #sway
      libva-utils
      vdpauinfo
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

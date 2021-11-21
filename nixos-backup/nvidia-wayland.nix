{ config, pkgs, lib, ... }:
let
  nvidiaPackage = config.boot.kernelPackages.nvidiaPackages.stable;

in
{
  imports = [
    ./wayland-tweaks.nix
    #./sway.nix
  ];

  config = {
    environment.etc."gbm/nvidia-drm_gbm.so".source = "${nvidiaPackage}/lib/libnvidia-allocator.so";
    environment.etc."egl/egl_external_platform.d".source = "/run/opengl-driver/share/egl/egl_external_platform.d/";
    #hardware.opengl.enable = true;
    hardware.opengl.driSupport = true;
    hardware.opengl.driSupport32Bit = true;
    #programs.steam.enable = true;
    environment.systemPackages = with pkgs; [
      #mesa-demos
      xwayland
      firefox
      vulkan-tools
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

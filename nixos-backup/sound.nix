{ config, pkgs, lib, ... }:

{
  security.rtkit.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  environment.systemPackages = with pkgs; [
    patchage
    pavucontrol
    qjackctl
  ];
}

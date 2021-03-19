{ config, pkgs, ... }:
let
  unstableHomeManager = fetchTarball https://github.com/nix-community/home-manager/tarball/07f6c6481e0cbbcaf3447f43e964baf99465c8e1;
  unstable = builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/0b876eaed3ed4715ac566c59eb00004eca3114e8;
  unstablePkgs = import unstable { config.allowUnfree = true; };
in
{
  imports =
    [
      "${unstableHomeManager}/modules/services/wlsunset.nix"
    ];
  # disabledModules = [ "services/desktops/pipewire.nix" ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "douglas";
  home.homeDirectory = "/home/douglas";

  services.wlsunset = {
    package = unstablePkgs.wlsunset;
    enable = true;
    # Nice, France
    latitude = "43.7";
    longitude = "7.2";
  };

  programs.readline = {
    enable = true;
    extraConfig = ''
      set editing-mode vi
      set keymap vi
    '';
  };

  systemd.user.services.wlsunset.Service = {
    Restart = "always";
    RestartSec = 3;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}

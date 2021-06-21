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

  programs.neovim.withPython = false;

  services.wlsunset = {
    package = unstablePkgs.wlsunset;
    enable = true;
    # Nice, France
    latitude = "43.7";
    longitude = "7.2";
  };

  systemd.user.services.wlsunset.Service = {
    Restart = "always";
    RestartSec = 3;
  };
}

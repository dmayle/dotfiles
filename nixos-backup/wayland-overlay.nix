{ config, lib, pkgs, ... }:
let
  rev = "master";
  url = "https://github.com/nix-community/nixpkgs-wayland/archive/${rev}.tar.gz";
  waylandOverlay = (import "${builtins.fetchTarball url}/overlay.nix");
in
{
  nixpkgs.overlays = [ waylandOverlay ];
}

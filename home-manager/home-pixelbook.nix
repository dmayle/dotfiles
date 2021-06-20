{ config, pkgs, ... }:

{
  imports = [
    ./other-linux.nix
    ./home.nix
  ];
}


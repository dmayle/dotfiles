{ config, pkgs, ... }:

{
  imports = [
    ./nixos.nix
    ./common.nix
    ./fonts.nix
    ./neovim.nix
    ./sway.nix
    ./tmux.nix
  ];
}



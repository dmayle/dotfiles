{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./neovim.nix
    ./other-linux.nix
    ./tmux.nix
  ];
}


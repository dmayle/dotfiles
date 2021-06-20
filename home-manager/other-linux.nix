{ config, pkgs, ... }:

{
  home.file."${config.xdg.configHome}/nvim/parser/bash.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-bash}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/c.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-c}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/cpp.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-cpp}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/go.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-go}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/html.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-html}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/javascript.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-javascript}/parser";
  home.file."${config.xdg.configHome}/nvim/parser/python.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-python}/parser";

  home.packages = with pkgs; [
    clang-tools
    bazel-buildtools
    colordiff
    git
    universal-ctags
    direnv
    kitty
    fzf
    ripgrep
    gnupg
    mcfly

    # System/process inspection
    htop
    lsof
    tmux
    fd
    gopls
    terraform-ls
    rnix-lsp
    nodePackages.yaml-language-server
    nodePackages.vim-language-server
    nodePackages.bash-language-server
    nodePackages.dockerfile-language-server-nodejs
    python-language-server
    dotnet-sdk
  ];
}


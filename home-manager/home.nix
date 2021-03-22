{ config, pkgs, ... }:
let
  unstableHomeManager = fetchTarball https://github.com/nix-community/home-manager/tarball/07f6c6481e0cbbcaf3447f43e964baf99465c8e1;
  unstable = builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/0b876eaed3ed4715ac566c59eb00004eca3114e8;
  unstablePkgs = import unstable { config.allowUnfree = true; };

  # Custom neovim plugins
  vim-maximizer = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-maximizer";
    src = pkgs.fetchFromGitHub {
      owner = "szw";
      repo = "vim-maximizer";
      rev = "2e54952fe91e140a2e69f35f22131219fcd9c5f1";
      sha256 = "031brldzxhcs98xpc3sr0m2yb99xq0z5yrwdlp8i5fqdgqrdqlzr";
    };
    meta = {
      homepage = https://github.com/szw/vim-maximizer;
      maintainers = [ "szw" ];
    };
  };
  nvim-colorizer = pkgs.vimUtils.buildVimPlugin rec {
    name = "nvim-colorizer";
    src = pkgs.fetchFromGitHub {
      owner = "norcalli";
      repo = "nvim-colorizer.lua";
      rev = "36c610a9717cc9ec426a07c8e6bf3b3abcb139d6";
      sha256 = "0gvqdfkqf6k9q46r0vcc3nqa6w45gsvp8j4kya1bvi24vhifg2p9";
    };
    meta = {
      homepage = https://github.com/norcalli/nvim-colorizer.lua;
      maintainers = [ "norcalli" ];
    };
  };
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

  # Setup vi keybinding with readline
  programs.readline = {
    enable = true;
    extraConfig = ''
      set editing-mode vi
      set keymap vi
    '';
  };

  # Configure solarized light color scheme for kitt
  programs.kitty = {
    enable = true;
    extraConfig = ''
      # Solarized Light Colorscheme

      background              #fdf6e3
      foreground              #657b83
      cursor                  #586e75

      selection_background    #475b62
      selection_foreground    #eae3cb

      color0                #073642
      color8                #002b36

      color1                #dc322f
      color9                #cb4b16

      color2                #859900
      color10               #586e75

      color3                #b58900
      color11               #657b83

      color4                #268bd2
      color12               #839496

      color5                #d33682
      color13               #6c71c4

      color6                #2aa198
      color14               #93a1a1

      color7                #eee8d5
      color15               #fdf6e3

      # Choose Powerline Symbols
      symbol_map U+E0A0-U+E0A2,U+E0B0-U+E0B3,U+1F512 PowerlineSymbols

      # Setup font size controls
      map kitty_mod+0 set_font_size 11
      map kitty_mod+equal change_font_size all +2.0
      map kitty_mod+minux change_font_size all -2.0
    '';
  };

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    clock24 = true;
    keyMode = "vi";
    shortcut = "a";
    extraConfig = ''
      # Use tmux TERM for more features, and 256color for true color
      set -g default-terminal "tmux-256color"

      # Enable italic support
      #set -as terminal-overrides ',*:sitm=\E[3m'

      # Enable undercurl support
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'

      # Enable colored underline support
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

      # This tmux statusbar config was created by tmuxline.vim
      # on Fri, 14 Feb 2020

      set -g status-justify "left"
      set -g status "on"
      set -g status-left-style "none"
      set -g message-command-style "fg=#eee8d5,bg=#93a1a1"
      set -g status-right-style "none"
      set -g pane-active-border-style "fg=#657b83"
      set -g status-style "none,bg=#eee8d5"
      set -g message-style "fg=#eee8d5,bg=#93a1a1"
      set -g pane-border-style "fg=#93a1a1"
      set -g status-right-length "100"
      set -g status-left-length "100"
      setw -g window-status-activity-style "none"
      setw -g window-status-separator ""
      setw -g window-status-style "none,fg=#93a1a1,bg=#eee8d5"
      set -g status-left "#[fg=#eee8d5,bg=#657b83,bold] #S #[fg=#657b83,bg=#eee8d5,nobold,nounderscore,noitalics]"
      set -g status-right "#[fg=#93a1a1,bg=#eee8d5,nobold,nounderscore,noitalics]#[fg=#eee8d5,bg=#93a1a1] %Y-%m-%d  %H:%M #[fg=#657b83,bg=#93a1a1,nobold,nounderscore,noitalics]#[fg=#eee8d5,bg=#657b83] #h "
      setw -g window-status-format "#[fg=#93a1a1,bg=#eee8d5] #I #[fg=#93a1a1,bg=#eee8d5] #W "
      setw -g window-status-current-format "#[fg=#eee8d5,bg=#93a1a1,nobold,nounderscore,noitalics]#[fg=#eee8d5,bg=#93a1a1] #I #[fg=#eee8d5,bg=#93a1a1] #W #[fg=#93a1a1,bg=#eee8d5,nobold,nounderscore,noitalics]"
    '';
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      # File explorer
      nerdtree

      # Source code class explorer
      tagbar

      # Status bar with coloring
      vim-airline
      vim-airline-themes

      # Toggle between maximizing current split, and then restoring previous
      # split state
      vim-maximizer

      # Configure fuzzy finder integration
      fzf-vim

      # solarized
      NeoSolarized

      # Configurable text colorizing
      # unstablePkgs.vimPlugins.vim-hexokinase
      nvim-colorizer

      # Nix Filetype support
      vim-nix

      # Code commenting
      vim-commentary

      # Vim Git UI
      vim-fugitive
      vim-signify
    ];

    extraConfig = ''
      " Remember, all autocommand should be in autogroups

      " Enable 24-bit color support
      set termguicolors

      " Make sure we use Solarized light
      set background=light
      colorscheme NeoSolarized

      " Turn on true-color highlighting
      " let g:Hexokinase_highlighters = ["backgroundfull"]

      function! s:InitColoring()
        lua require'colorizer'.setup()
        lua require'colorizer'.attach_to_buffer(0)
      endfunction

      augroup MyColoring
        au!
        autocmd VimEnter * call <SID>InitColoring()
      augroup END

      " Personal Shortcuts (leader)
      nnoremap <Space> <Nop>
      let mapleader = ' '

      " Searches
      nnoremap <silent> <leader><space> :GFiles<CR>
      nnoremap <silent> <leader>ff :Rg<CR>
      inoremap <expr> <c-x><c-f> fzf#vim#complete#path(
        \ "find . -path '*/\.*' -prune -o print \| sed '1d;s:%..::'",
        \ fzf#wrap({'dir': expand('%:p:h')}))

      " Load Git UI
      nnoremap <silent> <leader>gg :G<cr>

      " #######################################################################
      " ****** LINE NUMBERING ******
      " #######################################################################

      " Show line numbers relative to the current cursor line to make repeated
      " commands easier to compose. We only do this while in the buffer.  When
      " focused in another buffer, we use standard numbering.

      function! s:InitLineNumbering()
        " Keep track of current window, since 'windo' chances current window
        let l:my_window = winnr()

        " Global line number settings
        set relativenumber
        set number
        set list
        set signcolumn=auto

        " Setup all windows for line numbering
        windo call <SID>SetLineNumberingForWindow(0)

        " Go back to window
        exec l:my_window . 'wincmd w'
        "
        " Set special (relative) numbering for focused window
        call <SID>SetLineNumberingForWindow(1)
      endfunction

      function! s:SetLineNumberingForWindow(entering)
        " Excluded buffers
        if &ft == "help" || exists("b:NERDTree")
          return
        endif
        if a:entering
          setlocal number
          setlocal relativenumber
          setlocal list
          setlocal signcolumn=auto
        else
          setlocal number
          setlocal norelativenumber
          setlocal list
          setlocal signcolumn=auto
        endif
      endfunction

      augroup MyLineNumbers
        au!
        autocmd VimEnter * call <SID>InitLineNumbering()
        autocmd BufEnter,WinEnter * call <SID>SetLineNumberingForWindow(1)
        autocmd WinLeave * call <SID>SetLineNumberingForWindow(0)
      augroup END
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

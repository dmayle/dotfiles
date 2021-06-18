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

  indent-blankline = pkgs.vimUtils.buildVimPlugin rec {
    name = "indent-blankline";
    src = pkgs.fetchFromGitHub {
      owner = "lukas-reineke";
      repo = "indent-blankline.nvim";
      rev = "d925b80b3f57c8e2bf913a36b37aa63b6ed75205";
      sha256 = "1h1jsjn6ldpx0qv7vk3isqs7hrfz1srv5q6vrf44lv2r5di1gr65";
    };
    meta = {
      homepage = https://github.com/lukas-reineke/indent-blankline.nvim;
      maintainers = [ "lukas-reineke" ];
    };
  };

  vim-glaive = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-glaive";
    src = pkgs.fetchFromGitHub {
      owner = "google";
      repo = "vim-glaive";
      rev = "c17bd478c1bc358dddf271a13a4a025efb30514d";
      sha256 = "0py6wqqnblr4n1xz1nwlxp0l65qmd76448gz0bf5q9a1sf0mkh5g";
    };
    meta = {
      homepage = https://github.com/google/vim-glaive;
      maintainers = [ "google" ];
    };
  };

  vim-syncopate = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-syncopate";
    src = pkgs.fetchFromGitHub {
      owner = "google";
      repo = "vim-syncopate";
      rev = "cc68632a72c269e8d75f1f22a6fa588fd5b46e02";
      sha256 = "0vb68h07wkqlwfr24s4nsxyclla60sii7lbg6wlgwhdn837hiqyx";
    };
    meta = {
      homepage = https://github.com/google/vim-syncopate;
      maintainers = [ "google" ];
    };
  };

  vim-fakeclip = pkgs.vimUtils.buildVimPlugin rec {
    name = "vim-fakeclip";
    src = pkgs.fetchFromGitHub {
      owner = "kana";
      repo = "vim-fakeclip";
      rev = "59858dabdb55787d7f047c4ab26b45f11ebb533b";
      sha256 = "1jrfi1vc7svhypvg2gizx40vracr91m9d912b61j0c7z8swix908";
    };
    meta = {
      homepage = https://github.com/kana/vim-fakeclip;
      maintainers = [ "kana" ];
    };
  };

  conflict-marker = pkgs.vimUtils.buildVimPlugin rec {
    name = "conflict-marker";
    src = pkgs.fetchFromGitHub {
      owner = "rhysd";
      repo = "conflict-marker.vim";
      rev = "6a9b8f92a57ea8a90cbf62c960db9e5894be2d7a";
      sha256 = "0vw5kvnmwwia65gni97vk42b9s47r3p5bglrhpcxsvs3f4s250vq";
    };
    meta = {
      homepage = https://github.com/rhysd/conflict-marker.vim;
      maintainers = [ "rhysd" ];
    };
  };
in
{
  imports =
    [
      "${unstableHomeManager}/modules/services/wlsunset.nix"
    ];

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/tarball/0f13d55e4634ca7fcf956df0c76d1c1ffefb62a3;
      #url = https://github.com/nix-community/neovim-nightly-overlay/tarball/5e3737ae3243e2e206360d39131d5eb6f65ecff5;
    }))

    # For when I need to straight up override packages
    (self: super: {
      # Use nightly neovim as the basis for my regular neovim package
      neovim-unwrapped = self.neovim-nightly;
    })
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.clang-tools
  ];

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

  programs.dircolors = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableNixDirenvIntegration = true;
  };

  programs.bash = {
    enable = true;
    historyControl = [ "ignoredups" "ignorespace" "erasedups" ];
    historyFileSize = 20000;
    # Still need to setup prompt.rc
    initExtra = ''
      # Command hashing is used by various shell scripts, so enable it
      set -h

      function tmux() {
        TMUX_CMD=$(which tmux)
        if [[ $# != 0 ]]; then
          # Don't break existing commands
          $TMUX_CMD "$@"
          return
        fi

        # TMUX_SOCKET=
        # if [[ -n "$TMUX" ]]; then
        #   TMUX_SOCKET=$(basename $(tmux display-message -p '#{socket_path}'))
        #   TMUX_CMD="''${TMUX_CMD} -L ''${TMUX_SOCKET} -f ~/.tmux-''${TMUX_SOCKET}.conf"
        # fi
        # Extract the session name, group number, and attached state from a session
        # line that looks like:
        # name: session_details [width x height] (optional group) (optional attached)
        SESSION_REGEX='^([^:]*):[^[]*\[[^]]*\] ?(\([^)]*[0-9]\))? ?(\(attached\))?'
        # Actually, the default output for list-sessions has changed, so I use
        # the -F FORMAT option below to simulate the parts we care about
        # Just check if the session is attached or not
        ATTACHED_REGEX='\(attached\)$'
        # Look for words of the form 'word0' and extract the word and the number
        TRAILING_NUMBER_REGEX='^(.*[^0-9])?([0-9]+)$'
        # Reading the value directly into the array requires newer bash.  OSX ships
        # with an old enough bash that I'm using a manual loop to read the sessions
        # into the array.
        unset SESSIONS
        while IFS= read -r line; do SESSIONS+=("$line"); done <<< "$($TMUX_CMD list-sessions -F '#S:[]#{?session_group, (#{session_group}),}#{?session_attached, (attached),}' 2>/dev/null)"
        if [[ ''${#SESSIONS[@]} -eq 1 ]]; then
          if [[ -z "''${SESSIONS[0]}" ]]; then
            # No existing session, so start tmux with a specially named session
            $TMUX_CMD new -s group0
          elif [[ ''${SESSIONS[0]} =~ $ATTACHED_REGEX ]]; then
            # Existing, attached session, so create a new session that groups to it
            [[ ''${SESSIONS[0]} =~ $SESSION_REGEX ]] || return -1
            SESSION_NAME="''${BASH_REMATCH[1]}"
            [[ "''${SESSION_NAME}" =~ $TRAILING_NUMBER_REGEX ]] \
              && $TMUX_CMD new-session -t "$SESSION_NAME" -s "''${BASH_REMATCH[1]}$((''${BASH_REMATCH[2]} + 1))" \
              || $TMUX_CMD new-session -t "$SESSION_NAME" -s "''${SESSION_NAME}0"
          else
            # Default behavior is to attach to an existing session, no matter the name
            $TMUX_CMD attach
          fi
          return
        fi
        # With multiple existing sessions, we have to get the name of the existing
        # group (like the highlander, there can be only one), and either attach to
        # the first free session, or create a new one if none are free.
        GROUP_NAME=
        FREE_GROUP_SESSION=
        MAX_SESSION_NAME=
        MAX_SESSION_NUM=
        for SESSION in "''${SESSIONS[@]}"; do
          [[ ''${SESSION} =~ $SESSION_REGEX ]] || return -1
          if [[ -n "$GROUP_NAME" && -n "''${BASH_REMATCH[2]}" && "$GROUP_NAME" != "''${BASH_REMATCH[2]}" ]]; then
            echo "ERROR: More than one group found"
            $TMUX_CMD list-sessions
            return
          fi
          # Get the name of the group
          if [[ -n "''${BASH_REMATCH[2]}" ]]; then
            GROUP_NAME="''${BASH_REMATCH[2]}"
            SESSION_NAME="''${BASH_REMATCH[1]}"
            if [[ "''${SESSION_NAME}" =~ $TRAILING_NUMBER_REGEX ]]; then
              if [[ ''${BASH_REMATCH[2]} > $MAX_SESSION_NUM ]]; then
                MAX_SESSION_NUM=''${BASH_REMATCH[2]}
                MAX_SESSION_NAME="''${BASH_REMATCH[1]}"
              fi
            elif [[ -z "$MAX_SESSION_NAME" ]]; then
              MAX_SESSION_NAME="$SESSION_NAME"
              MAX_SESSION_NUM=0
            fi
            # else we already have a session at level 0, so MAX_SESSION isn't affected
            if [[ ! $SESSION =~ $ATTACHED_REGEX ]]; then
              # In the case of multiple free sessions, this just picks the one
              # closest to the bottom of the list
              FREE_GROUP_SESSION="$SESSION_NAME"
            fi
          fi
          # else this is ungrouped session.  If that's the case, and all sessions are
          # ungrouped, we can't choose which one to join, so we will happily fall
          # through to the end.
        done
        if [[ -n "$FREE_GROUP_SESSION" ]]; then
          $TMUX_CMD attach -t "$FREE_GROUP_SESSION"
        elif [[ -n "$GROUP_NAME" ]]; then
          # We are guaranteed to have a max session by the time we get here
          $TMUX_CMD new-session -t "$SESSION_NAME" -s "''${MAX_SESSION_NAME}$((''${MAX_SESSION_NUM} + 1))"
        else
          # We can only get here if we have no existing session group, and multiple
          # ungrouped sessions, so we don't know which to join.  Let the user
          # manually decide.
          echo "ERROR: No group, but multiple sessions.  You must manually attach to a group"
          return -1
        fi
      }

      # Use ssh-reagent to share agents between sessions (screen, etc.)
      ssh-reagent () {
        [[ -n "$SSH_AUTH_SOCK" ]] && return
        for agent in $(ls {/tmp,/var/run/ssh-agent}/ssh-*/agent.* 2>/dev/null); do
          export SSH_AUTH_SOCK=$agent
          if ssh-add -l 2>&1 > /dev/null; then
            echo Found working SSH Agent:
            ssh-add -l
            return
          fi
        done
        echo Cannot find ssh agent - restarting...
        eval $(ssh-agent)
        ssh-add
      }
      ssh-reagent

      [[ -f ~/src/dotfiles/bash/prompt.rc ]] && source ~/src/dotfiles/bash/prompt.rc

      eval "$(direnv hook bash)"
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
    withPython = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      #######################################################################
      # ****** BASIC TOOLING ******
      #######################################################################

      # Plugin libraries
      vim-maktaba
      vim-glaive

      #######################################################################
      # ****** ENHANCE EXISTING FUNCTIONALITY ******
      #######################################################################

      # Make % command (jump to matching pair) work better
      matchit-zip

      # Make . command (repeat) work better
      vim-repeat

      # Ensure quotes and brackets are added together
      auto-pairs

      # Allow number increment (Ctrl-A, Ctrl-X) to work for dates
      vim-speeddating

      # Additional copy/paste buffer '&' for tmux
      vim-fakeclip

      # Start using treesitter
      nvim-treesitter
      #unstable can install maintained parsers but can't use them
      #unstablePkgs.vimPlugins.nvim-treesitter

      # Automate the update and connection of tags files
      vim-gutentags

      # Ensure increment operator (Ctrl-A, Ctrl-X) works in visual/block mode
      vim-visual-increment

      # Live search/replace preview
      vim-over

      #######################################################################
      # ****** LOOK AND FEEL ******
      #######################################################################

      # solarized
      NeoSolarized

      # Configurable text colorizing
      nvim-colorizer

      # Both Indent guides plugins
      indent-blankline

      # Font for airline
      # powerline-fonts

      #######################################################################
      # ****** UPDATED TEXT/COMMAND FEATURES ******
      #######################################################################

      # Code commenting
      vim-commentary

      # Toggle between maximizing current split, and then restoring previous
      # split state
      vim-maximizer

      # Tools for working with doxygen comments
      DoxygenToolkit-vim

      # For converting camelCase to snake_case mostly
      vim-abolish

      # Delete, update, insert quotes, brackets, tags, parentheses, etc.
      vim-surround

      # Bracket mappings mostly for navigation
      vim-unimpaired

      # Add text object for indentation level (mostly for python)
      vim-indent-object

      # Add bracket mappings for diff conflict markers ]x [x
      conflict-marker

      #######################################################################
      # ****** UPDATED UI FEATURES ******
      #######################################################################

      # Explorer for Vim's tree-based undo history
      undotree

      # File explorer
      # NvimTree (faster NerdTree replacement)
      unstablePkgs.vimPlugins.nvim-tree-lua

      # Simple buf list/navigate
      bufexplorer

      # Source code class explorer
      tagbar

      # Status bar with coloring
      vim-airline
      vim-airline-themes

      # Built-in debugger
      vimspector

      # Tag/source code explorer
      tagbar

      # Vim Git UI
      vim-fugitive
      vim-signify

      # Configure fuzzy finder integration
      fzf-vim

      #######################################################################
      # ****** FILETYPE SPECIFIC PLUGINS ******
      #######################################################################

      # Nix Filetype support
      vim-nix

      # Vim browser markdown preview
      unstablePkgs.vimPlugins.vim-markdown-composer

      # Better YAML support
      vim-yaml

      # Dart language support
      dart-vim-plugin

      # Working on introducing
      # vim-pyenv (depends on environments)
      # Rename (maybe replaced by NvimTree rename)

      # bazel build file support
      vim-bazel

      #######################################################################
      # ****** CODE ENHANCEMENT ******
      #######################################################################

      # Autoformatting plugin (to someday be replaced with LSP formatter)
      # https://www.reddit.com/r/neovim/comments/jvisg5/lets_talk_formatting_again/
      vim-codefmt

      # Builtin Nvim LSP support
      unstablePkgs.vimPlugins.nvim-lspconfig

      # Lightweight autocompletion
      unstablePkgs.vimPlugins.completion-nvim
    ];

    extraConfig = ''
      " VimScript Reminders:
      " 1) All autocommands should be in autogroups
      " 2) All functions should be prefixed with 's:' but use '<SID>' when
      "    calling from mappings or commands

      " #######################################################################
      " ****** OVERALL SETTINGS ******
      " #######################################################################

      " I don't want files overriding my settings
      set modelines=0

      " I don't like beeping
      set visualbell

      " Enable 24-bit color support
      set termguicolors

      " I like to be able to occasionally use the mouse
      set mouse=a

      " Make sure we use Solarized light
      set background=light
      colorscheme NeoSolarized

      " Allow more-responsive async code
      set updatetime=100

      " Always show available completion options, but selection must be manual
      set completeopt=menuone,noinsert,noselect,longest

      " Don't show useless match messages while matching
      set shortmess+=c

      " Visual reminders of file width
      set colorcolumn=+1,+21,+41

      " Set visual characters for tabs and trailing whitespace.
      augroup VisualChars
        au!
        autocmd FileType * set listchars=tab:▸\ ,trail:☐
        autocmd FileType go set listchars=tab:\|\ ,trail:☐
      augroup END

      " Make sure that trailing whitespace is Red
      match errorMsg /\s\+$/

      " Make sure there is always at least 3 lines of context on either side of
      " the cursor (above and below).
      set scrolloff=3

      " These are my format options, use :help fo-table to understand
      set formatoptions+=rcoqnl1j

      " Make Y yank to the end of line, similar to D and C
      nnoremap Y y$

      " If w! doesn't work (because you're editing a root file), use w!! to save
      cnoremap <silent> w!! :exec ":echo ':w!!'"<CR>:%!sudo tee > /dev/null %

      " Add an insert mode mapping to reflow the current line.
      inoremap <C-G>q <C-O>gqq<C-O>A

      " I prefer my diffs vertical for side-by-side comparison
      set diffopt+=vertical

      " Default to case insensitive searching
      set ignorecase

      " Unless I use case in my search string, then case matters
      set smartcase

      " Keep unsaved files open with ther changes, even when switching buffers
      set hidden

      " Show the length of the visual selection while making it
      set showcmd

      " I speak english and french
      " set spell
      set spelllang=en_us,fr

      " Make backspace more powerful
      set backspace=indent,eol,start

      " Make tabs insert 'indents' when used at the beginning of the line
      set smarttab

      " Reasonable defaults for indentation
      set autoindent nocindent nosmartindent

      " Default to showing the current line (useful for long terminals)
      set cursorline

      " I find it useful to have lots of command history
      set history=1000

      " When joining lines, don't insert unnecessary whitespace
      set nojoinspaces

      " Have splits appear "after" current buffer
      set splitright splitbelow

      " #######################################################################
      " ****** BACKUP SETTINGS ******
      " #######################################################################

      " Use backup settings safe for NFS userdir mounts
      let $HOST=hostname()
      let $MYBACKUPDIR=$HOME . '/.vimbak-' . $HOST
      let $MYUNDODIR=$HOME . '/.vimundo-' . $HOST

      if !isdirectory(fnameescape($MYBACKUPDIR))
        silent! execute '!mkdir -p ' . shellescape($MYBACKUPDIR)
        silent! execute '!chmod 700 ' . shellescape($MYBACKUPDIR)
      endif

      if !isdirectory(fnameescape($MYUNDODIR))
        silent! execute '!mkdir -p ' . shellescape($MYUNDODIR)
        silent! execute '!chmod 700 ' . shellescape($MYUNDODIR)
      endif

      " Set directory for swap files
      set directory=$MYBACKUPDIR

      " Set directory for undo files
      set undodir=$MYUNDODIR

      " Save the current undo state between launches
      set undofile
      set undolevels=1000
      set undoreload=10000

      " Set to only keep one (current) backup
      set backup writebackup

      " Set directory for backup files
      set backupdir=$MYBACKUPDIR

      " Sensible list of files we don't want backed up
      set backupskip=/tmp/*,/private/tmp/*,/var/tmp/tmp/*,$TMPDIR/*,$TMP/*,$TEMP/*

      " #######################################################################
      " ****** PLUGIN SETTINGS ******
      " #######################################################################

      " %%%%% Airline Status Line %%%%%
      " Match to overall vim theme
      let g:airline_theme='solarized'

      " %%%%% Promptline Bash Prompt Generator %%%%%
      " I only install Promptline when I update Airline, run this, then uninstall
      let g:promptline_theme = 'airline'
      " Solarized Bash Color Table For Theme:
      " 0 base2 (beige)
      " 1 red
      " 2 green
      " 3 yellow
      " 4 blue
      " 5 magenta
      " 6 cyan
      " 7 base02 (black)
      " 8 base3 (bright beige)
      " 9 orange
      " 10 base1 (lightest grey)
      " 11 base0 (light grey)
      " 12 base00 (dark grey)
      " 13 violet
      " 14 base01 (darkest grey)
      " 15 base03 (darkest black)
      " Colors I like:
      " Background: blue(4)  > yellow(3) > magenta(5) > bright beige(8)
      " Foreground: beige(0) > beige(0)  > beige(0)   > grey(11)
      " let g:promptline_preset = {
      "     \'a' : [ '\w' ],
      "     \'b' : [ '$(echo $(printf \\xE2\\x8E\\x88) $(kubectx -c)$(echo :$(kubens -c) | sed -e s@^:default\$@@))' ],
      "     \'c' : [ promptline#slices#vcs_branch() ],
      "     \'warn' : [ promptline#slices#last_exit_code() ]}

      " %%%%%%%%%% Indent Blankline %%%%%%%%%%
      " Enable treesitter support
      let g:indent_blankline_use_treesitter = v:true

      " %%%%%%%%%% NvimTree %%%%%%%%%%
      let g:nvim_tree_ignore = [ '.git', '^bazel-.*$' ]

      " %%%%% GutenTags %%%%%
      " Explanaiton of all this at https://www.reddit.com/r/vim/comments/d77t6j
      let g:gutentags_ctags_tagfile = '.tags'

      let g:gutentags_exclude_filetypes = [
            \ 'dart',
            \ ]

      " let g:gutentags_project_info = [
      "       \ {'type': 'dart', 'file': 'pubspec.yaml'},
      "       \ ]

      " let g:gutentags_ctags_executable_dart = '/home/douglas/.bin/flutter_ctags'

      let g:gutentags_ctags_extra_args = [
            \ '--tag-relative=yes',
            \ '--fields=+ailmnS',
            \ ]

      let g:gutentags_ctags_exclude = [
            \ '*.git', '*.svg', '*.hg',
            \ '*/tests/*',
            \ 'build',
            \ 'dist',
            \ '*sites/*/files/*',
            \ 'bazel-bin',
            \ 'bazel-out',
            \ 'bazel-projects',
            \ 'bazel-testlogs',
            \ 'bazel-*',
            \ 'bin',
            \ 'node_modules',
            \ 'bower_components',
            \ 'cache',
            \ 'compiled',
            \ 'docs',
            \ 'example',
            \ 'bundle',
            \ 'vendor',
            \ '*.md',
            \ '*-lock.json',
            \ '*.lock',
            \ '*bundle*.js',
            \ '*build*.js',
            \ '.*rc*',
            \ '*.json',
            \ '*.min.*',
            \ '*.map',
            \ '*.bak',
            \ '*.zip',
            \ '*.pyc',
            \ '*.class',
            \ '*.sln',
            \ '*.Master',
            \ '*.csproj',
            \ '*.tmp',
            \ '*.csproj.user',
            \ '*.cache',
            \ '*.pdb',
            \ 'tags*',
            \ 'cscope.*',
            \ '*.css',
            \ '*.less',
            \ '*.scss',
            \ '*.exe', '*.dll',
            \ '*.mp3', '*.ogg', '*.flac',
            \ '*.swp', '*.swo',
            \ '*.bmp', '*.gif', '*.ico', '*.jpg', '*.png',
            \ '*.rar', '*.zip', '*.tar', '*.tar.gz', '*.tar.xz', '*.tar.bz2',
            \ '*.pdf', '*.doc', '*.docx', '*.ppt', '*.pptx',
            \ ]

      " #######################################################################
      " ****** FILETYPE SETTINGS ******
      " #######################################################################

      " Default to bash support in shell scripts
      let g:is_bash = 1

      augroup PersonalFileTypeSettings
        au!
        " Set up default spacing and tabs for a few filetypes.  I've left off Go,
        " since the filetype plugin handles it for me.
        autocmd FileType mail,text,python,gitcommit,c,cpp,java,sh,vim,puppet,xml,json,javascript,html,yaml,dart setlocal tabstop=8 shiftwidth=2 expandtab

        " Fix the comment handling, which is set to c-style by default
        autocmd FileType puppet setlocal commentstring=#\ %s

        " Standard GO tab settings (tabs, not spaces)
        autocmd FileType go setlocal tabstop=4 shiftwidth=4 noexpandtab

        " Turn on spellchecking in these file types.
        autocmd FileType mail,text,python,gitcommit,cpp setlocal spell

        " Help files trigger the 'text' filetype autocommand, but we don't want
        " spellchecking in the help buffer, so we manually disable it.
        autocmd FileType help setlocal nospell

        " Don't hide markdown punctuation
        autocmd FileType markdown set conceallevel=0

        " Teach vim-commentary about nasm comments
        autocmd FileType asm set commentstring=;\ %s

        " Ensure that we autowrap git commits to 72 characters, per tpope's guidelines
        " for good git comments.
        autocmd FileType gitcommit setlocal textwidth=72

        " I use 80-column lines in mail, plain text, C++ files, and my vimrc.
        autocmd FileType mail,text,vim,cpp,c setlocal textwidth=80

        " I use 100-column lines in Java files
        autocmd FileType java setlocal textwidth=100

        " Change line continuation rules for Java. j1 is for Java anonymous classes,
        " +2s says indent 2xshiftwidth on line continuations.
        autocmd FileType java setlocal cinoptions=j1,+2s
      augroup END

      augroup codefmt_autoformat_settings
        au!
        autocmd VimEnter * Glaive codefmt plugin[mappings]
        autocmd FileType bzl AutoFormatBuffer buildifier
        autocmd FileType c,cpp,proto,javascript,arduino AutoFormatBuffer clang-format
        autocmd FileType dart AutoFormatBuffer dartfmt
        autocmd FileType go AutoFormatBuffer gofmt
        autocmd FileType gn AutoFormatBuffer gn
        autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
        autocmd FileType java AutoFormatBuffer google-java-format
        autocmd FileType python AutoFormatBuffer yapf
        " Alternative: autocmd FileType python AutoFormatBuffer autopep8
        autocmd FileType rust AutoFormatBuffer rustfmt
        autocmd FileType vue AutoFormatBuffer prettier
      augroup END

      " #######################################################################
      " ****** PERSONAL SHORTCUTS (LEADER) ******
      " #######################################################################

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

      nnoremap <silent> <leader>pp :call <SID>TogglePaste()<cr>
      nnoremap <silent> <leader>sc :call <SID>ToggleScreenMess()<cr>

      " replace the current buffer (delete) with bufexplorer
      nnoremap <silent> <leader>bd :call <SID>BufDelete()<cr>

      " Jump in and out of nvim tree
      nnoremap <silent> <leader>nt :NvimTreeToggle<CR>
      nnoremap <silent> <leader>nf :NvimTreeFindFile<CR>
      nnoremap <silent> <leader>nn :call <SID>NvimTreeFocus()<cr>

      " (C)reate (F)ile under cursor (for when `gf` doesn't work)
      nnoremap <silent> <leader>cf :call writefile([], expand("<cfile>"), "t")<cr>

      nnoremap <silent> <leader>tt :TagbarToggle<CR>

      " base64 encode encode and decode visual selection
      vnoremap <leader>6d c<c-r>=system('base64 --decode', @")<cr><esc>
      vnoremap <leader>6e c<c-r>=system('base64 -w 0', @")<cr><esc>

      " Push and close git interface
      nnoremap <silent> <leader>gp :call <SID>GitPushAndClose()<CR>

      nnoremap <silent> <leader>ut :UndotreeToggle<CR>

      " #######################################################################
      " ****** PERSONAL FUNCTIONS ******
      " #######################################################################

      function! s:TogglePaste()
        if &paste
          set nopaste
        else
          set paste
        endif
      endfunction

      " When copying from the buffer in tmux, we wan't to get rid of visual
      " aids like indent lines, line numbering, gutter
      function! s:ToggleScreenMess()
        if &signcolumn ==? "auto"
          " Turn off
          set nonumber nolist norelativenumber signcolumn=no
          exe 'IndentBlanklineDisable'
        else
          " Turn on
          set number list signcolumn=auto
          setlocal relativenumber
          exe 'IndentBlanklineEnable'
        endif
      endfunction

      " Function so that we can push directly from Fugitive git index
      function! s:GitPushAndClose()
        exe ":Gpush"
        if getbufvar("", "fugitive_type") ==? "index"
          exe "wincmd c"
        endif
      endfunction

      " We make a persistent hidden buffer so that we have somewhere to go
      " while deleting the current buffer
      let s:BufDeleteBuffer = -1

      function! s:BufDelete()
        if s:BufDeleteBuffer == -1
          let s:BufDeleteBuffer = bufnr("BufDelete_".matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:], 1)
          call setbufvar(s:BufDeleteBuffer, "&buftype", "nofile")
        endif

        let l:cur_buffer = bufnr('%')
        exe "b ".s:BufDeleteBuffer
        exe "bdelete ".l:cur_buffer
        exe "BufExplorer"
      endfunction

      function! s:NvimTreeFocus()
        " This function is meant to be used if NvimTree is already open, but
        " let's assume I meant to open it when trying to focus it.
        exe ":NvimTreeOpen"
        let l:nvim_tree_buffer = bufwinnr("NvimTree")
        if l:nvim_tree_buffer != -1
          exe l:nvim_tree_buffer."wincmd w"
        endif
      endfunction

      " #######################################################################
      " ****** COLORING CONTENT ******
      " #######################################################################

      function! s:InitColoring()
        lua require'colorizer'.setup()
        lua require'colorizer'.attach_to_buffer(0)
      endfunction

      augroup MyColoring
        au!
        autocmd VimEnter * call <SID>InitColoring()
      augroup END

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
        windo call s:SetLineNumberingForWindow(0)

        " Go back to window
        exec l:my_window . 'wincmd w'
        "
        " Set special (relative) numbering for focused window
        call s:SetLineNumberingForWindow(1)
      endfunction

      function! s:SetLineNumberingForWindow(entering)
        " Excluded buffers
        if &ft ==? "help" || exists("b:NERDTree")
          return
        endif
        if a:entering
          if &signcolumn ==? "auto"
            " Normal state, turn on relative number
            setlocal relativenumber
          else
            " Visual Indicators Disabled
            setlocal norelativenumber
          endif
        else
          setlocal norelativenumber
        endif
      endfunction

      augroup MyLineNumbers
        au!
        autocmd VimEnter * call <SID>InitLineNumbering()
        autocmd BufEnter,WinEnter * call <SID>SetLineNumberingForWindow(1)
        autocmd WinLeave * call <SID>SetLineNumberingForWindow(0)
      augroup END

      " #######################################################################
      " ****** LSP Configuration ******
      " #######################################################################

      " Use <Tab> and <S-Tab> to navigate through popup menu
      inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
      inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

      function! s:InitLSP()
      lua << EOLUA
        local nvim_lsp = require('lspconfig')
        local on_attach = function(client, bufnr)
          local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
          local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

          buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

          -- Mappings.
          local opts = { noremap=true, silent=true }
          buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
          buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
          buf_set_keymap('n', 'gH', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
          buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
          buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
          buf_set_keymap('n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
          buf_set_keymap('n', '<space>wa', '<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
          buf_set_keymap('n', '<space>wr', '<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
          buf_set_keymap('n', '<space>wl', '<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
          buf_set_keymap('n', '<space>D', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
          buf_set_keymap('n', '<space>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
          buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
          buf_set_keymap('n', '<space>e', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
          buf_set_keymap('n', '[d', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
          buf_set_keymap('n', ']d', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
          buf_set_keymap('n', '<space>q', '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

          -- Set some keybinds conditional on server capabilities
          if client.resolved_capabilities.document_formatting then
            buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
          elseif client.resolved_capabilities.document_range_formatting then
            buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.range_formatting()<CR>', opts)
          end

          -- Set autocommands conditional on server_capabilities
          if client.resolved_capabilities.document_highlight then
            vim.api.nvim_exec([[
              hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
              hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
              hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
              augroup lsp_document_highlight
                autocmd! * <buffer>
                autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
              augroup END
            ]], false)
          end
        end

        -- Use a loop to simply setup all language servers
        local servers = { 'bashls', 'dockerls', 'gopls', 'terraformls', 'vimls', 'yamlls' }
        -- Also: { 'sqls', 'rnix', 'efm', 'dartls' }
        for _, lsp in ipairs(servers) do
          nvim_lsp[lsp].setup { on_attach = on_attach }
        end

        -- MS Python language server needs customized config
        nvim_lsp['pyls_ms'].setup {
          on_attach = on_attach,
          InterpreterPah = "${pkgs.python3Full}/bin/python",
          Version = "3.8",
          cmd = { "${pkgs.dotnet-sdk}/bin/dotnet", "exec", "${unstablePkgs.python-language-server}/lib/Microsoft.Python.LanguageServer.dll" }
        }
      EOLUA

        " Re-trigger filetype detection so LSP works on first file
        let &ft=&ft
      endfunction

      augroup MyLSPConfig
        au!
        autocmd VimEnter * call <SID>InitLSP()
        autocmd BufEnter * lua require'completion'.on_attach()
      augroup END
    '';
  };

  # home.file."${config.xdg.configHome}/nvim/parser/bash.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-bash}/parser";
  # home.file."${config.xdg.configHome}/nvim/parser/c.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-c}/parser";
  # home.file."${config.xdg.configHome}/nvim/parser/cpp.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-cpp}/parser";
  # home.file."${config.xdg.configHome}/nvim/parser/go.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-go}/parser";
  # home.file."${config.xdg.configHome}/nvim/parser/html.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-html}/parser";
  # home.file."${config.xdg.configHome}/nvim/parser/javascript.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-javascript}/parser";
  # home.file."${config.xdg.configHome}/nvim/parser/python.so".source = "${pkgs.tree-sitter.builtGrammars.tree-sitter-python}/parser";

  systemd.user.services.wlsunset.Service = {
    Restart = "always";
    RestartSec = 3;
  };

  #services.lorri.enable = true;

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

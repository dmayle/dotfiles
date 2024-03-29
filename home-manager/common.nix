{ config, pkgs, lib, ... }:

{

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "douglas";
  home.homeDirectory = "/home/douglas";

  # Setup vi keybinding with readline
  programs.readline = {
    enable = true;
    extraConfig = ''
      set editing-mode vi
      set keymap vi
    '';
  };

  home.sessionVariables = {
    EDITOR = "vi";
  };

  home.packages = with pkgs; [
    # List of packages that may need to be inherited from a non-nixos OS
    # git # Has custom protocol

    # Easier to read diffs
    colordiff

    # Source code indexing for non-google3 code
    universal-ctags

    # Per-directory setup (handles pyenv)
    direnv

    # Linux tools to learn
    fzf
    ripgrep
    mcfly
    fd

    # Better process inspection than top
    htop

    # Terminal session management
    tmux

    # Fantastic interface for breaking up commits into better units
    git-crecord

    # Volume control used when clicking waybar
    pavucontrol

  ];

/*
  home.file."${config.xdg.configHome}/nvim/spell/en.utf-8.spl".source = nvim-spell-en-utf8-dictionary;
  home.file."${config.xdg.configHome}/nvim/spell/en.utf-8.sug".source = nvim-spell-en-utf8-suggestions;
  home.file."${config.xdg.configHome}/nvim/spell/en.ascii.spl".source = nvim-spell-en-ascii-dictionary;
  home.file."${config.xdg.configHome}/nvim/spell/en.ascii.sug".source = nvim-spell-en-ascii-suggestions;
  home.file."${config.xdg.configHome}/nvim/spell/en.latin1.spl".source = nvim-spell-en-latin1-dictionary;
  home.file."${config.xdg.configHome}/nvim/spell/en.latin1.sug".source = nvim-spell-en-latin1-suggestions;
  home.file."${config.xdg.configHome}/nvim/spell/fr.utf-8.spl".source = nvim-spell-fr-utf8-dictionary;
  home.file."${config.xdg.configHome}/nvim/spell/fr.utf-8.sug".source = nvim-spell-fr-utf8-suggestions;
  home.file."${config.xdg.configHome}/nvim/spell/fr.latin1.spl".source = nvim-spell-fr-latin1-dictionary;
  home.file."${config.xdg.configHome}/nvim/spell/fr.latin1.sug".source = nvim-spell-fr-latin1-suggestions;
*/

  programs.dircolors = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    package = pkgs.writeTextDir "/git" "";
    userName = "Douglas Mayle";
    userEmail = "douglas@mayle.org";
  };

  programs.bash = {
    enable = true;
    historyControl = [ "ignoredups" "ignorespace" "erasedups" ];
    historyFileSize = 20000;
    # Still need to setup prompt.rc
    initExtra = ''
      # Prep GPG Agent for this terminal
      [[ -n "$(which gpg)" ]] && export GPG_TTY=$(tty)

      [ -f ~/.nix-profile/etc/profile.d/nix.sh ] && source ~/.nix-profile/etc/profile.d/nix.sh;
      # Command hashing is used by various shell scripts, so enable it
      set -h

      # A number of support functions to make tmux work the way I want it to
      function _inside_local_tmux() {
        if [ -n "$TMUX" ]; then
          return 0 # TRUE
        fi;
        return 1 # FALSE
      }

      function _inside_any_tmux() {
        case "$TERM" in
        screen*|tmux*)
          return 0 # TRUE
        esac
        return 1 # FALSE
      }

      function _get_tmux_socket() {
        if [ -z "$TMUX" ]; then
          return
        fi;
        echo $(basename $(command tmux display-message -p '#{socket_path}'))
      }

      function _ensure_tmux_socket() {
        command tmux -L "$1" -f ${config.xdg.configHome}/tmux/tmux-''${1}.conf list-sessions &> /dev/null && return
        tmux -L "$1" -f ${config.xdg.configHome}/tmux/tmux-''${1}.conf new -d -t group -s 0
      }

      function _ensure_tmux_free_session() {
        if [ -z "$1" ]; then
          _TMUX_SOCKET=$(_get_tmux_socket)
        else
          _TMUX_SOCKET="$1"
        fi;

        # Let's get a bash array variable containing all of the sessions on this tmux socket
        unset _SESSIONS
        while IFS= read -r _line; do _SESSIONS+=("$_line"); done <<< "$(command tmux -L $_TMUX_SOCKET list-sessions -F '#S#{?session_attached,(attached),}' 2>/dev/null)"

        # If there is an unattached session, we're done, otherwise create a new
        # session with MAX_VALUE+1
        _MAX_SESSION_NUM=-1
        for _SESSION in "''${_SESSIONS[@]}"; do
          if [[ "''${_SESSION}" == "''${_SESSION%(attached)}" ]]; then
            # The existing sessions isn't attached so our job is done
            return
          fi;

          if [[ ''${_SESSION%(attached)} -gt ''${_MAX_SESSION_NUM} ]]; then
            _MAX_SESSION_NUM="''${_SESSION%(attached)}"
          fi
        done

        # All sessions already attached, so add a new one
        command tmux -L "$_TMUX_SOCKET" new -d -t group -s $((_MAX_SESSION_NUM + 1))
      }

      function _join_tmux_socket() {
        if [ -z "$1" ]; then
          _TMUX_SOCKET=$(_get_tmux_socket)
        else
          _TMUX_SOCKET="$1"
        fi;

        # Let's get a bash array variable containing all of the sessions on this tmux socket
        unset _SESSIONS
        while IFS= read -r _line; do _SESSIONS+=("$_line"); done <<< "$(command tmux -L $_TMUX_SOCKET list-sessions -F '#S#{?session_attached, (attached),}' 2>/dev/null)"

        # Find the first unattached sessions and join it
        for _SESSION in "''${_SESSIONS[@]}"; do
          if [[ "''${_SESSION}" == "''${_SESSION%(attached)}" ]]; then
            # The existing sessions isn't attached so join it
            command tmux -L "$_TMUX_SOCKET" attach -t "$_SESSION"
            return
          fi;
        done
      }

      function tmux() {
        # This function doesn't take arguments, so instead call the underlying tmux
        if [ $# != 0 ]; then
          command tmux "$@"
          return;
        fi;

        if _inside_any_tmux; then
          if _inside_local_tmux; then
            TMUX_SOCKET=$(_get_tmux_socket)
            if [ "$TMUX_SOCKET" = "inner" ]; then
              echo Already inside of TMUX
              return;
            fi;
          fi;
          _ensure_tmux_socket inner
          _ensure_tmux_free_session inner
          _join_tmux_socket inner
          return;
        fi;

        _ensure_tmux_socket outer
        _ensure_tmux_free_session outer
        _join_tmux_socket outer
      }

      function ensure() {
        gcertstatus || gcert && ssh -t atuin.c.googlers.com bash -c 'gcertstatus || gcert'
      }

      # SSH works best with an agent, so first attempt to find and connect to
      # an existing agent, and if needed, start one up. `gnome-keyring-daemon`
      # can handle ssh agent duties, but it can't handle the key types we use
      # on corp, so we don't use it.
      function _ssh_socket_works() {
        if env SSH_AUTH_SOCK=$1 ssh-add -l &>/dev/null; then
          return 0 # TRUE
        fi;
        return 1 # FALSE
      }

      function _found_working_ssh_agent() {
        # Check existing environment
        if [ -n "$SSH_AUTH_SOCK" ] && _ssh_socket_works "$SSH_AUTH_SOCK"; then
          return 0 # TRUE
        fi

        # Check systemd user service ssh-agent
        if _ssh_socket_works ''${XDG_RUNTIME_DIR}/ssh-agent.socket; then
          export SSH_AUTH_SOCK=''${XDG_RUNTIME_DIR}/ssh-agent.socket
          return 0 # TRUE
        fi

        # SSH Agent socket locations/patterns:
        # ~/.cache/agent-tty (console agent, no GUI)
        # $DIR/ssh-agent.XXXXXXXXXX/agent
        for agent in $(ls {{/tmp,/var/run/ssh-agent}/ssh-*,''${XDG_CACHE_DIR:-$HOME/.cache},$XDG_RUNTIME_DIR}/{ssh-,}agent{,.*,-tty}{,.socket} 2>/dev/null); do
          if _ssh_socket_works $agent; then
            export SSH_AUTH_SOCK="$agent"
            return 0 # TRUE
          fi
        done

        return 1 # FALSE
      }

      function _start_ssh_agent() {
        if systemctl --user list-unit-files ssh-agent.service &>/dev/null; then
          systemctl --user restart ssh-agent.service
          if _ssh_socket_works ''${XDG_RUNTIME_DIR}/ssh-agent.socket; then
            export SSH_AUTH_SOCK=''${XDG_RUNTIME_DIR}/ssh-agent.socket
            return
          fi
        fi

        echo Starting manual ssh-agent session
        eval $(ssh-agent)
        ssh-add
      }

      ssh-reagent () {
        if _found_working_ssh_agent; then
          return
        fi

        echo Cannot find ssh agent - restarting...

        _start_ssh_agent
      }
      ssh-reagent

      [[ -f ~/src/dotfiles/bash/prompt.rc ]] && source ~/src/dotfiles/bash/prompt.rc
    '';
  };

  # Add a systemd service for ssh-agent
  systemd.user.services.ssh-agent = {
    Unit = {
      PartOf = [ "graphical-session.target" ];
      Description = "SSH key agent";
    };
    Install = {
      WantedBy = [ "sway-session.target" ];
    };
    Service = {
      type = "Simple";
      Environment = [ "SSH_AUTH_SOCK=%t/ssh-agent.socket" ];
      ExecStart = "ssh-agent -D -a $SSH_AUTH_SOCK";
      Restart = "always";
      RestartSec = 3;
    };
  };

  # Configure solarized light color scheme for kitty
  programs.kitty = {
    enable = true;
    extraConfig = ''
      enable_audio_bell no
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
      font_size 10.0
      map kitty_mod+0 set_font_size 10.0
      map kitty_mod+equal change_font_size all +2.0
      map kitty_mod+minus change_font_size all -2.0
    '';
  };
/*
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
    # withPython = false;
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
          cmd = { "${pkgs.dotnet-sdk}/bin/dotnet", "exec", "${pkgs.python-language-server}/lib/Microsoft.Python.LanguageServer.dll" }
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
*/
  home.activation = {
    gitCheckoutAction = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p ~/src
      $DRY_RUN_CMD sh -c 'test -d ~/src/rules_docker || git clone git@github.com:dmayle/rules_docker.git ~/src/rules_docker'
      $DRY_RUN_CMD sh -c 'test -d ~/src/dotfiles || git clone git@github.com:dmayle/dotfiles.git ~/src/dotfiles'
      $DRY_RUN_CMD sh -c 'test -d ~/src/chrometiler || git clone git@github.com:dmayle/chrometiler.git ~/src/chrometiler'
    '';
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

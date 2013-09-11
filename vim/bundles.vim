" ##############################################################################
" ****** VUNDLE ******
" I'm in the process of migrating to Vundle.  Below is my Vundle config (to some
" extent, it replaces pathogen)
" ##############################################################################
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'

Bundle 'Lokaltog/vim-easymotion'
Bundle 'Raimondi/delimitMate'
Bundle 'altercation/vim-colors-solarized'
Bundle 'bufexplorer.zip'
Bundle 'dmayle/vim-powerline'
Bundle 'gmarik/vundle'
Bundle 'kien/ctrlp.vim'
Bundle 'lilydjwg/colorizer'
Bundle 'majutsushi/tagbar'
Bundle 'mattn/zencoding-vim'
Bundle 'michaeljsmith/vim-indent-object'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'rson/vim-conque'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/syntastic'
Bundle 'sjbach/lusty'
Bundle 'sjl/gundo.vim'
Bundle 'tpope/vim-commentary'
Bundle 'tpope/vim-dispatch'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-speeddating'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-unimpaired'
Bundle 'triglav/vim-visual-increment'
Bundle 'vim-scripts/a.vim'
Bundle 'vim-scripts/python.vim--Vasiliev'
Bundle 'vim-scripts/sessionman.vim'
Bundle 'vimoutliner/vimoutliner'
Bundle 'kana/vim-textobj-user'
Bundle 'Julian/vim-textobj-variable-segment'

" Set the basics and start with the shared config.
filetype plugin indent on

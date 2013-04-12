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

Bundle 'scrooloose/nerdtree'
Bundle 'rson/vim-conque'
Bundle 'altercation/vim-colors-solarized'
Bundle 'sjbach/lusty'
Bundle 'vimoutliner/vimoutliner'
Bundle 'tpope/vim-surround'
Bundle 'michaeljsmith/vim-indent-object'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'mattn/zencoding-vim'
Bundle 'lilydjwg/colorizer'
Bundle 'majutsushi/tagbar'
Bundle 'tpope/vim-unimpaired'
Bundle 'lukasz/vim-web-indent'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-commentary'
Bundle 'tpope/vim-speeddating'
Bundle 'tpope/vim-repeat'
Bundle 'dmayle/vim-powerline'
Bundle 'vim-scripts/python.vim--Vasiliev'
Bundle 'scrooloose/syntastic'
Bundle 'vim-scripts/sessionman.vim'
Bundle 'triglav/vim-visual-increment'
Bundle 'sjl/gundo.vim'
Bundle 'Raimondi/delimitMate/'
Bundle 'vim-scripts/a.vim'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'kien/ctrlp.vim'
Bundle 'Valloric/YouCompleteMe'
Bundle 'gmarik/vundle'

" Set the basics and start with the shared config.
filetype plugin indent on

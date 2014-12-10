" ##############################################################################
" ****** VUNDLE ******
" Chicken and Egg problem:
" vim -u bundles.vim +BundleInstall +q
" ##############################################################################
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'

Bundle 'bufexplorer.zip'
Bundle 'Conque-Shell'

"Bundle 'rson/vim-conque'
Bundle 'Rename'
Bundle 'altercation/vim-colors-solarized'
Bundle 'dmayle/vim-powerline'
Bundle 'gmarik/vundle'
Bundle 'Julian/vim-textobj-variable-segment'
Bundle 'kana/vim-textobj-user'
Bundle 'kien/ctrlp.vim'
Bundle 'lilydjwg/colorizer'
Bundle 'Lokaltog/vim-easymotion'
Bundle 'majutsushi/tagbar'
Bundle 'mattn/emmet-vim'
Bundle 'michaeljsmith/vim-indent-object'
Bundle 'nathanaelkane/vim-indent-guides'
Bundle 'Raimondi/delimitMate'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/syntastic'
Bundle 'sjbach/lusty'
Bundle 'sjl/gundo.vim'
Bundle 'tpope/vim-abolish'
Bundle 'tpope/vim-commentary'
Bundle 'tpope/vim-dispatch'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-repeat'
Bundle 'tpope/vim-speeddating'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-unimpaired'
Bundle 'triglav/vim-visual-increment'
Bundle 'vim-scripts/a.vim'
Bundle 'vim-scripts/Buffer-grep'
Bundle 'vim-scripts/python.vim--Vasiliev'
Bundle 'vim-scripts/sessionman.vim'
Bundle 'vimoutliner/vimoutliner'
Bundle 'puppetlabs/puppet-syntax-vim'
Bundle 'google/vim-syncopate'

" Set the basics and start with the shared config.
filetype plugin indent on

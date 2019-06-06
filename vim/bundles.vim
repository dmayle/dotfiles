" ##############################################################################
" ****** VUNDLE ******
" Chicken and Egg problem:
" vim -u bundles.vim +BundleInstall +q
" ##############################################################################
set nocompatible
filetype off
" set rtp+=~/.vim/bundle/vundle/
" call vundle#begin()
set rtp+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))

" Letting Vundle manage itself
" Bundle 'gmarik/vundle'
" Letting NeoBundle manage itself
NeoBundleFetch 'Shougo/neobundle.vim'


NeoBundle 'bufexplorer.zip'
NeoBundle 'Conque-Shell'

"Bundle 'rson/vim-conque'
NeoBundle 'bitbucket:ludovicchabant/vim-lawrencium'
NeoBundle 'Julian/vim-textobj-variable-segment'
NeoBundle 'Lokaltog/vim-easymotion'
NeoBundle 'Raimondi/delimitMate'
NeoBundle 'Rename'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'vim-airline/vim-airline'
NeoBundle 'google/vim-maktaba'
NeoBundle 'google/vim-syncopate'
" NeoBundle 'hsanson/vim-android'
NeoBundle 'jceb/vim-orgmode'
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'lilydjwg/colorizer'
NeoBundle 'majutsushi/tagbar'
NeoBundle 'mattn/emmet-vim'
NeoBundle 'michaeljsmith/vim-indent-object'
" NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'sjl/gundo.vim'
NeoBundle 'tpope/vim-abolish'
NeoBundle 'tpope/vim-commentary'
NeoBundle 'tpope/vim-dispatch'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-speeddating'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'triglav/vim-visual-increment'
NeoBundle 'vim-scripts/Buffer-grep'
NeoBundle 'vim-scripts/a.vim'
NeoBundle 'vim-scripts/python.vim--Vasiliev'
NeoBundle 'vim-scripts/sessionman.vim'
NeoBundle 'vimoutliner/vimoutliner'
NeoBundle 'peterhoeg/vim-qml'

" Set the basics and start with the shared config.
" call vundle#end()
call neobundle#end()
filetype plugin indent on
NeoBundleCheck

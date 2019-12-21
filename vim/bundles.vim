" ##############################################################################
" ****** NEOBUNDLE ******
" Chicken and Egg problem:
" vim -u bundles.vim +BundleInstall +q
" ##############################################################################
set nocompatible
filetype off

set rtp+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))

" Letting NeoBundle manage itself
NeoBundleFetch 'Shougo/neobundle.vim'


NeoBundle 'bufexplorer.zip'

NeoBundle 'mrk21/yaml-vim'
NeoBundle 'Julian/vim-textobj-variable-segment'
NeoBundle 'Raimondi/delimitMate'
NeoBundle 'Rename'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'vim-airline/vim-airline'
NeoBundle 'google/vim-maktaba'
NeoBundle 'google/vim-syncopate'
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'lilydjwg/colorizer'
"NeoBundle 'majutsushi/tagbar'
NeoBundle 'michaeljsmith/vim-indent-object'
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
"NeoBundle 'vim-scripts/sessionman.vim'
NeoBundle 'vimoutliner/vimoutliner'

" Set the basics and start with the shared config.
call neobundle#end()
filetype plugin indent on
NeoBundleCheck

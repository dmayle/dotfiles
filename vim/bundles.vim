" ##############################################################################
" ****** vim-plug ******
" Chicken and Egg problem:
" vim -u bundles.vim +BundleInstall +q
" ##############################################################################
set nocompatible
filetype off

call plug#begin()

Plug 'vim-scripts/bufexplorer.zip'
Plug 'vim-scripts/matchit.zip'

Plug 'majutsushi/tagbar'
Plug 'ludovicchabant/vim-gutentags'
Plug 'Yggdroot/indentLine'
Plug 'mrk21/yaml-vim', { 'for': 'yaml' }
Plug 'jiangmiao/auto-pairs'
Plug 'vim-scripts/Rename', { 'on': 'Rename' }
Plug 'lifepillar/vim-solarized8'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'google/vim-maktaba'
Plug 'google/vim-syncopate', {'on':'SyncopateExportToClipboard'}
Plug 'ctrlpvim/ctrlp.vim'
Plug 'michaeljsmith/vim-indent-object'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTree', 'NERDTreeToggle'] }
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary', {'on':['<Plug>Commentary', '<Plug>CommentaryLine']}
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'triglav/vim-visual-increment'
Plug 'vim-scripts/Buffer-grep'
Plug 'vim-scripts/a.vim'
Plug 'vim-scripts/python.vim--Vasiliev'

" Set the basics and start with the shared config.
call plug#end()

scriptencoding utf-9
" based on Josh's configuration:
" https://github.com/knewter/dotfiles/blob/63df7521ee60d5ecea6d6d5baaa6961ddd43a82c/nvim/init.vim

" --- BASICS

set tabstop=2
set softtabstop=2
set expandtab
set shiftwidth=2

set formatoptions=tcrq
set textwidth=120

set backupcopy=yes

let g:mapleader=','
let g:maplocalleader='\\'

set omnifunc=syntaxcomplete#Complete

set mouse=""

set hlsearch
set incsearch
set ignorecase smartcase
set smartcase

set number relativenumber

" if isdirectory($HOME . '/config/nvim/undo') == 0
"   :silent !mkdir -p ~/.config/nvim/undo > /dev/null 2>&1
" endif
" set undodir=./.vim-undo//
" set undodir+=~/.vim/undo//
" set undofile

let g:python2_host_prog='/usr/bin/python'

" --- END BASICS

" --- PLUGINS

call plug#begin()

" ???
Plug 'sheerun/vim-polyglot'

" Elixir
Plug 'elixir-lang/vim-elixir'
Plug 'slashmili/alchemist.vim'
Plug 'mhinz/vim-mix-format'
  let g:mix_format_on_save=0
  let g:mix_format_options='--check-equivalent'
" Add support to ANSI colors
Plug 'powerman/vim-plugin-AnsiEsc'

" Phoenix
Plug 'c-brenn/phoenix.vim'
Plug 'tpope/vim-projectionist'  " required for some navigation features

" Utilities
" Plug 'bogado/file-line'
" Plug 'milkypostman/vim-togglelist'
" Plug 'sbdchd/neoformat'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  let g:deoplete#enable_at_startup=1
  let g:deoplete#sources={}
  let g:deoplete#sources._=['file', 'neosnippet']
  let g:deoplete#omni#functions={}
  let g:deoplete#omni#input_patterns={}
" Plug 'ervandew/supertab'
" Plug 'editorconfig/editorconfig-vim'
" Plug 'tpope/vim-unimpaired'
" Plug 'w0rp/ale'
"   let g:ale_lint_on_save=0
"   let g:ale_lint_on_text_changed=0
" Plug 'tpope/vim-fugitive'
" Plug 'tpope/vim-rhubarb'
" Plug 'ludovicchabant/vim-gutentags'
"   let g:gutentags_cache_dir='~/.tags_cache'

" UI plugins
Plug 'tomasr/molokai'
" Plug 'fmoralesc/molokayo'
" Plug 'ayu-theme/ayu-vim'
" Plug 'lifepillar/vim-solarized8'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
"   let g:airline_theme='solarized'
"   let g:bufferline_echo=0
"   let g:airline_powerline_fonts=0
"   let g:airline_enable_branch=1
"   let g:airline_enable_syntastic=1
"   let g:airline_branch_prefix = '⎇ '
"   let g:airline_paste_symbol = '∥'
"   let g:airline#extensions#tabline#enabled=0
"   let g:airline#extensions#ale#enabled=1

call plug#end()

" --- END PLUGINS

" --- UI

set background=dark
syntax enable
" colorscheme molokai

nnoremap <silent> <cr> :nohlsearch<cr>

map <Left> :echo "no!"<cr>
map <Right> :echo "no!"<cr>
map <Up> :echo "no!"<cr>
map <Down> :echo "no!"<cr>

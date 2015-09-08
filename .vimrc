" Automatic reloading of .vimrc
autocmd! bufwritepost .vimrc source %


" Handle Vundles
set nocompatible
filetype off
filetype plugin indent off
set rtp+=~/.vim/bundle/Vundle.vim


" Vundles Bundles
call vundle#begin()
Plugin 'gmarik/Vundle.vim'
Plugin 'wincent/Command-T'
Plugin 'kien/ctrlp.vim'
Plugin 'nsf/gocode', {'rtp': 'vim/'}
Plugin 'fatih/vim-go'
Plugin 'marijnh/tern_for_vim'
Plugin 'altercation/vim-colors-solarized'
Plugin '29decibel/codeschool-vim-theme'
Plugin 'digitaltoad/vim-jade'
Plugin 'Valloric/YouCompleteMe'
Plugin 'scrooloose/syntastic'
Plugin 'jeffkreeftmeijer/vim-numbertoggle'
Plugin 'editorconfig/editorconfig-vim'
call vundle#end()


" Go settings and syntax highlight
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"
let g:go_fmt_autosave = 1
filetype plugin indent on
syntax on


" Better copy & paste
set pastetoggle=<F2>


" Mouse and backspace
set mouse=a
set bs=2


" Rebind <Leader> key
let mapleader = ","


" Quicksave command
noremap <C-Z> :update<CR>
vnoremap <C-Z> <C-C>:update<CR>
inoremap <C-Z> <C-O>:update<CR>


" Quick quit command
noremap <Leader>e :quit<CR>
noremap <Leader>E :qa<CR>


" bind Ctrl+<movement> keys to move around the windows,
" instead of using Ctrl+w + <movement>
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h


" easier moving between tabs
map <Leader>n <esc>:tabprevious<CR>
map <Leader>m <esc>:tabnext<CR>


" Better color scheme
set t_Co=256
color codeschool


" Showing line numbers and length
set number " show line numbers
set tw=79  " width of document (used by gd)
set nowrap " don't automatically wrap on load
set fo-=t  " don't automatically wrap text when typing


" Highlight lines over 80 columns
" Based on solution on:
" http://stackoverflow.com/questions/235439/vim-80-column-layout-concern
highlight OverLength ctermbg=red ctermfg=white guibg=blue
match OverLength /\%81v.\+/


" Show whitespace
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
" au InsertLeave * match ExtraWhitespace /\s\+$/


" Useful settings
set history=700
set undolevels=700

set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set expandtab

set hlsearch
set incsearch
set ignorecase
set smartcase


" Settings for folding
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=1


" Settings for vim-powerline
set laststatus=2


" Settings for ctrlp
let g:ctrlp_max_height = 30


" Settings for vim-javascript
let g:html_indent_inctags = "html,body,head,tbody"
let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"


" Enable omnifunc for python, css and html
autocmd FileType javascript setl sw=2 sts=2 et
autocmd FileType python setl sw=4 sts=4 et
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType css setl sw=2 sts=2 et
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType html setl sw=2 sts=2 et
autocmd FileType xhtml set omnifunc=htmlcomplete#CompleteTags
autocmd FileType xhtml setl sw=2 sts=2 et
autocmd FileType htmldjango set omnifunc=htmlcomplete#CompleteTags
autocmd FileType htmldjango setl sw=2 sts=2 et
autocmd FileType jade setl sw=2 sts=2 et
autocmd FileType bash setl sw=4 sts=4 ts=4 noet
autocmd FileType sh setl sw=4 sts=4 ts=4 noet


" Ignore files and dirs in CommandT
set wildignore+=*.pyc,**/migrations/*,**/assets/*,**/docs/*
set wildignore+=**/node_modules/*,**/bower_components/*,**/media/*


" Dismiss preview window after omnicomplete
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif


" Add the virtualenv's site-packages to vim path
py << EOF
import os
import sys
import vim

has_manage = lambda p: os.path.isdir(p) and 'manage.py' in os.listdir(p)

if 'VIRTUAL_ENV' in os.environ:
    envdir = os.environ['VIRTUAL_ENV']
    sys.path.insert(0, envdir)
    activate_this = os.path.join(envdir, 'bin', 'activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))

    projdir = open(
        os.path.join(envdir, '.project')
    ).read().split('\n')[0]

    # find project path by determining the directory that contains the manage.py
    # file. the project name is defined as the basename for the project path
    if has_manage(projdir):
        projpath = projdir
    else:
        paths = [path for path in os.listdir(projdir) if has_manage(path)]
        if not len(paths):
            projpath = projdir
        else:
            projpath = os.path.join(projdir, paths[0])
    projname = os.path.basename(projpath)

    # add the project path to the path and define the DJANGO_SETTINGS_MODULE
    # in this case I assume that the settings is a module and not a python
    # file
    sys.path.insert(1, projpath)
    os.environ['DJANGO_SETTINGS_MODULE'] = '{0}.settings.local'.format(
        projname
    )
EOF


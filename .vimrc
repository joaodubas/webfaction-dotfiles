" Automatic reloading of .vimrc
autocmd! bufwritepost .vimrc source %


" Handle Vundles
set nocompatible
filetype off
filetype plugin indent off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()


" Vundles Bundles
Bundle "gmarik/vundle"
Bundle "wincent/Command-T"
Bundle "kien/ctrlp.vim"
Bundle "Blackrush/vim-gocode"
" Bundle "davidhalter/jedi-vim"
Bundle "marijnh/tern_for_vim"
Bundle "altercation/vim-colors-solarized"
Bundle "digitaltoad/vim-jade"
" Bundle "pangloss/vim-javascript"
" Bundle "myhere/vim-nodejs-complete"
Bundle "Valloric/YouCompleteMe"
Bundle "scrooloose/syntastic"


" Go settings and syntax highlight
set runtimepath+=$GOROOT/misc/vim
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
set background=dark
colorscheme solarized
let g:solarized_termcolors=256    " colordepth
let g:solarized_termtrans=0       " 1|0 background transparent
let g:solarized_bold=1            " 1|0 show bold fonts
let g:solarized_italic=1          " 1|0 show italic fonts
let g:solarized_underline=1       " 1|0 show underlines
let g:solarized_contrast="normal" " normal|high|low contrast
let g:solarized_visibility="low"  " normal|high|low effect on whitespaces


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


" Settings for nodejs omnifunc
" autocmd FileType javascript set omnifunc=nodejscomplete#CompleteJS
" autocmd FileType javascript setl sw=2 sts=2 et
" let g:node_jscomplete = 1


" Settings for python-mode
" Based on: http://unlogic.co.uk/posts/vim-python-ide.html
" let g:pymode_rope = 0
" let g:pymode_lint = 1
" let g:pymode_lint_checker = "pyflakes,pep8"
" let g:pymode_lint_write = 1
" let g:pymode_virtualenv = 1
" let g:pymode_syntax = 1
" let g:pymode_syntax_all = 1
" let g:pymode_syntax_indent_errors = g:pymode_syntax_all
" let g:pymode_syntax_space_errors = g:pymode_syntax_all
" let g:pymode_folding = 0


" Settings for jedi-vim
" let g:jedi#poup_on_dot = 0


" Enable omnifunc for python, css and html
" autocmd FileType python set omnifunc=pythoncomplete#Complete
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


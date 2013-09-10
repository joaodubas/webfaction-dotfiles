" Automatic reloading of .vimrc
autocmd! bufwritepost .vimrc source %


" Setup Pathogen
call pathogen#infect()


" Go settings and syntax highlight
filetype off
filetype plugin indent off
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


" Settings for python-mode
map <Leader>g :call RopeGotoDefinition()<CR>
let ropevim_enable_shortcuts = 1
let g:pymode_rope_goto_def_newwin = 1
let g:pymode_rope_extended_complete = 1
let g:pymode_breakpoint = 0
let g:pymode_syntax = 1
let g:pymode_syntax_builtin_objs = 0
let g:pymode_syntax_builtin_funcs = 0
map <Leader>b Oimport ipdb; ipdb.set_trace() # BREAKPOINT<C-c>


" Settings for vim-javascript
let g:html_indent_inctags = "html,body,head,tbody"
let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"


" Settings for nodejs omnifunc
autocmd FileType javascript set omnifunc=nodejscomplete#CompleteJS
autocmd FileType javascript setl sw=2 sts=2 et
let g:node_jscomplete = 1


" Enable omnifunc for python, css and html
autocmd FileType python set omnifunc=pythoncomplete#Complete
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

" Dismiss preview window after omnicomplete
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif


" Add the virtualenv's site-packages to vim path
py << EOF
import os
import sys
import vim
if 'VIRTUAL_ENV' in os.environ:
    envdir = os.environ['VIRTUAL_ENV']
    sys.path.insert(0, envdir)
    activate_this = os.path.join(envdir, 'bin', 'activate_this.py')
    execfile(activate_this, dict(__file__=activate_this))

    projdir = open(
        os.path.join(envdir, '.project')
    ).read().split('\n')[0]
    projname = os.path.basename(projdir).split('-')[-1]
    sys.path.insert(1, os.path.join(projdir, projname))
    os.environ['DJANGO_SETTINGS_MODULE'] = '{0}.settings.local'.format(
        projname
    )
EOF


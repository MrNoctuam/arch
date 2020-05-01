"-----------------------------------------------------------------------
"                         install vim-plug
"-----------------------------------------------------------------------

if has('vim_starting')
    set runtimepath+=$HOME/.config/nvim/plugged/vim-plug
    if !isdirectory(expand('$NVIM_HOME') . '/plugged/vim-plug')
        call system('mkdir -p $HOME/.config/nvim/plugged/vim-plug')
        call system('git clone https://github.com/junegunn/vim-plug.git $HOME/.config/nvim/plugged/vim-plug/autoload')
    end
endif

"-----------------------------------------------------------------------
"                         install plugins
"-----------------------------------------------------------------------

call plug#begin('$HOME/.config/nvim/plugged')

Plug 'scrooloose/nerdtree'
"Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'nvie/vim-flake8'
Plug 'Shougo/deoplete.nvim'
Plug 'zchee/deoplete-jedi'
Plug 'mboughaba/i3config.vim'
Plug 'NLKNguyen/papercolor-theme'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

"-----------------------------------------------------------------------
"                         colorscheme
"-----------------------------------------------------------------------

let g:PaperColor_Theme_Options = {
\   'theme': {
\     'default.light': {
\       'transparent_background': 1
\     }
\   }
\ }

colorscheme PaperColor

"-----------------------------------------------------------------------
"                         airline settings
"-----------------------------------------------------------------------

let g:airline_theme='papercolor'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'

"-----------------------------------------------------------------------
"                         deoplete settings
"-----------------------------------------------------------------------

let g:deoplete#omni_patterns = {}
let g:deoplete#sources = {}
let g:deoplete#sources._ = []
let g:deoplete#file#enable_buffer_path = 1
let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_completion_start_length = 1

" tab-completion
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

"-----------------------------------------------------------------------
"                         nerdtree settings
"-----------------------------------------------------------------------

let NERDTreeMinimalUI=1
let NERDTreeShowHidden=1
let NERDTreeChDirMode=2
let NERDTreeQuitOnOpen = 1
let NERDTreeIgnore=['\.pyc$', '__pycache__']

map <silent> <C-n> :NERDTreeToggle<CR>
nnoremap <silent> <C-t> :NERDTreeFind<CR>

"-----------------------------------------------------------------------
"                         split settings
"-----------------------------------------------------------------------

set splitright
set splitbelow

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>


set number
set nowrap
set autoindent
set list

set expandtab
set tabstop=4 
set shiftwidth=4
set softtabstop=4

set textwidth=80
set encoding=utf-8
set fileformat=unix

if has('vim_starting')
        set encoding=utf-8
        scriptencoding utf-8
endif

augroup vim_rc | autocmd! | augroup end

" get the initial startup time for ViM (use :mes)
if !v:vim_did_enter && has('reltime')
    let g:startup_time = reltime()
    augroup vimrc_startup_time
        autocmd! VimEnter * let g:startup_time = reltime(g:startup_time)
                    \ | redraw
                    \ | echomsg 'startup_time: ' . reltimestr(g:startup_time)
    augroup END
endif

" Vim 8 defaults
unlet! skip_defaults_vim
silent! source $VIMRUNTIME/defaults.vim

" set the leader keys
let g:mapleader = "\<Space>"
let g:maplocalleader = ';'

" set any vim specific settings here
let indent_size  = 4
let &tabstop     = indent_size
let &shiftwidth  = indent_size          " number of spaces for indent/autoindent
let &softtabstop = indent_size          " let backspace delete indent_size space tab
set expandtab smarttab                  " convert tab to spaces
set autoindent                          " use same indenting on new lines
set smartindent                         " smart auto indenting for new lines
set nojoinspaces

set incsearch                           " search as characters are entered
set hlsearch                            " highlight matches

" set complete=.,w,b,u,t,i
set complete-=i
set completeopt=menu,menuone,preview

" enable omni-completion.
if has('autocmd') && exists('+omnifunc')
    autocmd vim_rc Filetype *
          \if &omnifunc == "" |
          \setlocal omnifunc=syntaxcomplete#Complete |
          \endif
endif

" automatically open and close the popup menu / preview window
au vim_rc CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif

" set omnifunc for individual file types
autocmd vim_rc FileType css           setl omnifunc=csscomplete#CompleteCSS
autocmd vim_rc FileType html,markdown setl omnifunc=htmlcomplete#CompleteTags
autocmd vim_rc FileType python        setl omnifunc=python3complete#Complete
autocmd vim_rc FileType xml           setl omnifunc=xmlcomplete#CompleteTags
autocmd vim_rc FileType ruby          setl omnifunc=rubycomplete#Complete
autocmd vim_rc FileType haskell       setl omnifunc=necoghc#omnifunc
autocmd vim_rc FileType javascript    setl omnifunc=javascriptcomplete#CompleteJS
" vim settings end

let $VIM_HOME = $HOME . '/.vim'
let $CONFIG = expand($HOME . '/.config')
let $TMP = expand($VIM_HOME . '/.tmp')

if !isdirectory(expand($CONFIG))
    call mkdir(expand($CONFIG), 'p')
endif

if !isdirectory(expand($TMP))
	" Create missing dirs i.e. cache/{undo,backup}
	call mkdir(expand('$TMP/undo'), 'p')
endif

" Load dein.
let s:dein_dir = finddir('dein.vim', '.;')
if s:dein_dir !=# '' || &runtimepath !~# '/dein.vim'
  if s:dein_dir ==# '' && &runtimepath !~# '/dein.vim'
    let s:dein_dir = expand('$CONFIG/vim') . '/repos/github.com/Shougo/dein.vim'
    if !isdirectory(s:dein_dir)
      echomsg 'Downloading the dein plugin management wait a moment'
      execute '!git clone https://github.com/Shougo/dein.vim' s:dein_dir
    endif
  endif
  execute 'set runtimepath^=' . substitute(fnamemodify(s:dein_dir, ':p') , '/$', '', '')
endif

" Disable packpath
set packpath=

" dein configurations.
let g:dein#install_max_processes = 16
let g:dein#install_progress_type = 'echo'
let g:dein#enable_notification   = 1
let g:dein#install_progress_type = 'title'
let g:dein#install_log_filename  = $TMP . '/dein.log'

" Constants
let $CACHE = expand($HOME . '/.cache')
let s:path = expand($CACHE . '/dein')

" use a toml format configuration file for the individual plugins
" dein.toml if for regular and deinlazy.toml for lazy installation
let s:toml_dir = expand($VIM_HOME . '/dein')
let s:toml =s:toml_dir.'/dein.toml'
let s:lazy_toml = s:toml_dir.'/deinlazy.toml'

" check and install
if dein#load_state(s:path)
       call dein#begin(s:path, [expand('<sfile>'), s:toml, s:lazy_toml])
       try
           call dein#load_toml(s:toml, {'lazy': 0})
           call dein#load_toml(s:lazy_toml, {'lazy' : 1})
       catch /.*/
		echoerr v:exception
		echomsg 'Error loading ...'
		echomsg 'Caught: ' v:exception
		echoerr 'error plugin.toml config'
	endtry
    call dein#end()
    if dein#check_install()
         " Installation check.
       call dein#install()
    endif
endif

syntax enable
filetype plugin indent on

call dein#call_hook('source')
call dein#call_hook('post_source')

" vim:set et sw=4

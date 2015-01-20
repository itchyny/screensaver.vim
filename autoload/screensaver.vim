" =============================================================================
" Filename: autoload/screensaver.vim
" Author: itchyny
" License: MIT License
" Last Change: 2014/12/07 20:45:16.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! screensaver#new(...)
  if !has_key(b:, 'screensaver')
    let controller = deepcopy(s:self)
    call controller.saveoption()
    silent! noautocmd tabnew
    let b:screensaver = controller
  else
    let b:screensaver.previous_name = b:screensaver.source.name
  endif
  try
    let source = screensaver#source(a:0 ? a:1 : 'clock')
  catch
    let source = screensaver#source('clock')
  endtry
  call b:screensaver.start(source)
endfunction

function! screensaver#source(name)
  let source = screensaver#source#{a:name}#new()
  let source.name = a:name
  return source
endfunction

function! screensaver#complete(arglead, cmdline, cursorpos)
  let paths = split(globpath(&runtimepath, 'autoload/screensaver/source/**.vim'), '\n')
  let names = map(paths, 'substitute(fnamemodify(v:val, ":t"), "\\.vim", "", "")')
  let matchnames = filter(copy(names), 'stridx(v:val, a:arglead) == 0')
  if len(matchnames)
    return matchnames
  endif
  return filter(copy(names), 'stridx(v:val, a:arglead) >= 0')
endfunction

let s:self = {}

function! s:self.start(source) dict
  call self.setoption()
  call self.setcursor()
  call self.call('end')
  let self.source = a:source
  call self.mapping()
  call self.call('start')
  call self.redraw()
  exec 'augroup ScreenSaver' . bufnr('')
    autocmd!
    autocmd CursorHold <buffer>
          \   if has_key(b:, 'screensaver')
          \ |   call b:screensaver.redraw()
          \ | endif
    autocmd BufLeave <buffer>
          \   if has_key(b:, 'screensaver')
          \ |   call b:screensaver.end()
          \ | endif
  augroup END
  let self.bufnr = bufnr('')
endfunction

function! s:self.saveoption() dict
  let self.setting = {}
  let self.setting.laststatus = &laststatus
  let self.setting.showtabline = &showtabline
  let self.setting.ruler = &ruler
  let self.setting.updatetime = &updatetime
  let self.setting.hlsearch = &hlsearch
  let self.setting.winnr = winnr()
  let self.setting.tabpagenr = tabpagenr()
  let result = split(screensaver#util#capture('hi Cursor'), '\n')
  let self.setting.hiCursor = map(filter(result, 'stridx(v:val, "xxx") >= 0'), 'substitute(v:val, "xxx", " ", "")')
endfunction

function! s:self.setoption() dict
  setlocal laststatus=0 showtabline=0 noruler updatetime=150 nohlsearch
        \ buftype=nofile noswapfile nolist completefunc= omnifunc=
        \ bufhidden=hide wrap nowrap nobuflisted nofoldenable foldcolumn=0
        \ nocursorcolumn nocursorline nonumber nomodeline filetype=screensaver
endfunction

function! s:self.restoreoption() dict
  let &laststatus = self.setting.laststatus
  let &showtabline = self.setting.showtabline
  let &ruler = self.setting.ruler
  let &updatetime = self.setting.updatetime
  let &hlsearch = self.setting.hlsearch
  call self.restorecursor()
endfunction

function! s:self.setcursor() dict
  silent! hi Cursor guifg=fg guibg=bg
endfunction

function! s:self.restorecursor() dict
  if len(self.setting.hiCursor)
    silent! exec 'hi ' self.setting.hiCursor[0]
  endif
endfunction

function! s:self.redraw() dict
  call cursor(1, 1)
  call self.call('redraw')
  silent! call feedkeys(mode() ==# 'i' ? "\<C-g>\<ESC>" : "g\<ESC>", 'n')
endfunction

function! s:self.mapping() dict
  let save_cpo = &cpo
  set cpo&vim
  nnoremap <buffer><silent> <Plug>(screensaver_end) :<C-u>call b:screensaver.end()<CR>
  call screensaver#util#nmapall('<Plug>(screensaver_end)')
  if get(g:, 'screensaver_password')
    nmap <buffer> : <Plug>(screensaver_end)
  else
    silent! nunmap <buffer> :
  endif
  let &cpo = save_cpo
endfunction

function! s:self.call(method) dict
  if has_key(self, 'source') && has_key(self.source, a:method)
    call self.source[a:method]()
  endif
endfunction

function! s:self.previous() dict
  call screensaver#new(get(self, 'previous_name', self.source.name))
endfunction

function! s:self.end(...) dict
  call self.call('end')
  if a:0 && a:1 || !get(g:, 'screensaver_password')
    call self.restoreoption()
    silent! noautocmd quit!
    silent! exec 'tabnext' self.setting.tabpagenr
    silent! exec self.setting.winnr 'wincmd w'
    silent! exec 'bwipeout!' self.bufnr
  else
    call screensaver#new('password')
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

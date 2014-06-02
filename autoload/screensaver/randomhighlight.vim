" =============================================================================
" Filename: autoload/screensaver/randomhighlight.vim
" Author: itchyny
" License: MIT License
" Last Change: 2014/05/31 01:26:50.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! screensaver#randomhighlight#new(...)
  return extend(extend(deepcopy(s:self), (a:0 ? a:1 : {})), { 'color': screensaver#randomcolor#new() })
endfunction

let s:self = {}
let s:self.time = -1
let s:gui = has('gui_running')

function! s:self.highlight() dict
  let self.time = (get(self, 'time') + 1) % 36
  if self.time % 6 && !s:gui
    return
  endif
  call self.color.next()
  if s:gui
    exec 'highlight ' . self.name . ' guibg=' . self.color.get()
  else
    exec 'highlight ' . self.name . ' ctermbg=' . self.color.get()
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

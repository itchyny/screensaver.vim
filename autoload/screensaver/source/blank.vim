" =============================================================================
" Filename: autoload/screensaver/source/helloworld.vim
" License: MIT License
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! screensaver#source#blank#new() abort
  return deepcopy(s:self)
endfunction

let s:self = {}
let s:self.message = ''

" Actions when the screensaver starts.
function! s:self.start() dict abort
  let self.i = winheight(0) / 2
  let self.j = winwidth(0) / 2
  let self.di = 1
  let self.dj = 2
  call setline(1, repeat([''], winheight(0)))
endfunction

" Actions when the screensaver redraws.
function! s:self.redraw() dict abort
  call setline(self.i, '')
  call setline(self.i, repeat(' ', self.j) . self.message)
endfunction
let s:strdisplaywidth = exists('*strdisplaywidth') ? function('strdisplaywidth') : function('strwidth')

" Actions when the screensaver exists.
function! s:self.end() dict abort
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo


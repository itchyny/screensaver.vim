" =============================================================================
" Filename: autoload/screensaver/source/helloworld.vim
" Author: itchyny
" License: MIT License
" Last Change: 2014/06/02 12:39:26.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! screensaver#source#helloworld#new()
  return deepcopy(s:self)
endfunction

let s:self = {}
let s:self.message = 'Hello, world!'

" Actions when the screensaver starts.
function! s:self.start() dict
  let self.i = winheight(0) / 2
  let self.j = winwidth(0) / 2
  let self.di = 1
  let self.dj = 2
  call setline(1, repeat([''], winheight(0)))
endfunction

" Actions when the screensaver redraws.
function! s:self.redraw() dict
  call setline(self.i, '')
  let self.i += self.di
  let self.j += self.dj
  if self.di > 0 && self.i - 1 >= winheight(0) || self.di < 0 && self.i <= 1
    let self.di = - self.di
    let self.i += self.di * 2
  endif
  if self.dj > 0 && self.j + s:strdisplaywidth(self.message) >= winwidth(0) || self.dj < 0 && self.j <= 1
    let self.dj = - self.dj
    let self.j += self.dj * 2
  endif
  call setline(self.i, repeat(' ', self.j) . self.message)
endfunction
let s:strdisplaywidth = exists('*strdisplaywidth') ? function('strdisplaywidth') : function('strwidth')

" Actions when the screensaver exists.
function! s:self.end() dict
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

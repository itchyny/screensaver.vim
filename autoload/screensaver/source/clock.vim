" =============================================================================
" Filename: autoload/screensaver/source/clock.vim
" Author: itchyny
" License: MIT License
" Last Change: 2024/11/10 21:55:32.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! screensaver#source#clock#new() abort
  return deepcopy(s:self)
endfunction

let s:self = {}
let s:self.time = []
let s:self.timehm = []
let s:self.pixels = []
let s:self.pixelshm = []

function! s:self.start() dict abort
  let [h, w] = [winheight(0) / 4 + 1, (winwidth(0) - 50) / 4 + 1]
  let self.i = max([1, min([max([0, winheight(0) - 5]), screensaver#random#number() % (h * 2) + h])])
  let self.j = max([1, (screensaver#random#number()) % (w * 2) + w])
  let self.di = (screensaver#random#number() % 2) * 2 - 1
  let self.dj = (screensaver#random#number() % 2) * 4 - 2
  let self.hl = screensaver#randomhighlight#new({ 'name': 'ScreenSaverClock' })
  call self.setline()
endfunction

function! s:self.redraw() dict abort
  if [self.h, self.w] != [winheight(0), winwidth(0)]
    call self.setline()
  endif
  call self.hl.highlight()
  let [h, m, s] = screensaver#util#time()
  if self.time == [h, m, s]
    let pixels = self.pixels
  else
    let self.time = [h, m, s]
    if self.timehm != [h, m]
      let self.timehm = [h, m]
      let self.pixelshm = screensaver#pixel#getstr(printf('%d:%02d:', h, m))
    endif
    let pixels = screensaver#pixel#getstr(printf('%02d', s), self.pixelshm)
    let self.pixels = pixels
    let self.pixelswidth = screensaver#util#sum(pixels[0])
  endif
  silent! syntax clear ScreenSaverClock
  for i in range(len(pixels))
    let [k, ps, cs] = [self.j, pixels[i], []]
    for j in range(0, len(ps) - 2, 2)
      let k += ps[j]
      let l = k + ps[j + 1]
      call add(cs, '%' . k . 'c.*%' . l . 'c')
      let k = l
    endfor
    execute printf('syntax match ScreenSaverClock /\v%%%dl%%(%s)/', self.i + i, join(cs, '|'))
  endfor
  call self.move()
endfunction

function! s:self.setline() dict abort
  let [self.h, self.w] = [winheight(0), winwidth(0)]
  call setline(1, repeat([repeat(' ', self.w)], self.h))
endfunction

function! s:self.move() dict abort
  let self.i += self.di
  let self.j += self.dj
  if self.di > 0 && self.i + 4 > self.h || self.di < 0 && self.i <= 1
    let self.di = - self.di
    let self.i += self.di * 2
  endif
  if self.dj > 0 && self.j + self.pixelswidth > self.w || self.dj < 0 && self.j <= 2
    let self.dj = - self.dj
    let self.j += self.dj * 2
  endif
endfunction

function! s:self.end() dict abort
  silent! syntax clear ScreenSaverClock
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

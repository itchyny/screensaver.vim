" =============================================================================
" Filename: autoload/screensaver/source/largeclock.vim
" Author: itchyny
" License: MIT License
" Last Change: 2024/11/10 22:06:22.
" =============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! screensaver#source#largeclock#new() abort
  return deepcopy(s:self)
endfunction

let s:self = {}
let s:self.time = []
let s:self.timehm = []
let s:self.pixels = []
let s:self.pixelshm = []

function! s:self.start() dict abort
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
    return
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
  let a = max([1, min([self.h * 3 / 4 / 5, self.w / 62])])
  let x = max([1, (self.h + 1 - 5 * a) / 2])
  let y = max([1, (self.w - self.pixelswidth * a) / 2])
  silent! syntax clear ScreenSaverClock
  for i in range(len(pixels))
    let [k, ps, cs] = [y, pixels[i], []]
    for j in range(0, len(ps) - 2, 2)
      let k += ps[j] * a
      let l = k + ps[j + 1] * a
      call add(cs, '%' . k . 'c.*%' . l . 'c')
      let k = l
    endfor
    execute printf('syntax match ScreenSaverClock /\v%%>%dl%%<%dl%%(%s)/',
          \ x + i * a - 1, x + i * a + a, join(cs, '|'))
  endfor
endfunction

function! s:self.setline() dict abort
  let [self.h, self.w] = [winheight(0), winwidth(0)]
  call setline(1, repeat([repeat(' ', self.w)], self.h))
endfunction

function! s:self.end() dict abort
  silent! syntax clear ScreenSaverClock
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

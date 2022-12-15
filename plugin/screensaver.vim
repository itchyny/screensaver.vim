" =============================================================================
" Filename: plugin/screensaver.vim
" Author: itchyny
" License: MIT License
" Last Change: 2022/12/16 08:58:15.
" =============================================================================

if exists('g:loaded_screensaver') || v:version < 800
  finish
endif
let g:loaded_screensaver = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -complete=customlist,screensaver#complete
      \ ScreenSaver call screensaver#new(<q-args>)

nnoremap <silent> <Plug>(screensaver) :<C-u>ScreenSaver<CR>
vnoremap <silent> <Plug>(screensaver) :<C-u>ScreenSaver<CR>

let &cpo = s:save_cpo
unlet s:save_cpo

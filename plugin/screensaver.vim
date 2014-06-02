" =============================================================================
" Filename: plugin/screensaver.vim
" Author: itchyny
" License: MIT License
" Last Change: 2014/05/29 22:48:17.
" =============================================================================

if exists('g:loaded_screensaver') && g:loaded_screensaver
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -complete=customlist,screensaver#complete
      \ ScreenSaver call screensaver#new(<q-args>)

nnoremap <silent> <Plug>(screensaver) :<C-u>ScreenSaver<CR>
vnoremap <silent> <Plug>(screensaver) :<C-u>ScreenSaver<CR>

let g:loaded_screensaver = 1

let &cpo = s:save_cpo
unlet s:save_cpo

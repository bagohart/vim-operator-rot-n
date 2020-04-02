" Autoloading hack: Activate this to enforce local reloading. {{{
" call OperatorRotN#operator_rot_n#Baaaaad()
" call OperatorRotN#util#Baaaaad()
" }}}

" reload guard {{{
if exists("g:loaded_operator_rot_n")
  " deactivate this for simple local reloading
  finish
endif
let g:loaded_operator_rot_n = 1
" }}}

" Settings {{{
let g:OperatorRotN_reuse_count_on_repeat = get(g:, 'OperatorRotN_reuse_count_on_repeat', 0)
let g:OperatorRotN_linewise_motions_select_whole_lines = get(g:, 'OperatorRotN_linewise_motions_select_whole_lines', 1)
let g:OperatorRotN_default_count = get(g:, 'OperatorRotN_default_count', 1)
" }}}

" Plug mappings {{{
nnoremap <Plug>(operator-rot-n) :<C-u>call operator_rot_n#SetupOperator()<CR>g@
nmap <Plug>(operator-rot-n-linewise) <Plug>(operator-rot-n)_
xnoremap <Plug>(operator-rot-n-visual) :<C-u>call operator_rot_n#OperatorRotNVisualMode()<CR>

nnoremap <Plug>(operator-rot-n-repeat) :<C-u>call operator_rot_n#OperatorRotNRepeat()<CR>
nnoremap <Plug>(operator-rot-n-repeat-visual) :<C-u>call operator_rot_n#OperatorRotNRepeatVisual()<CR>
" }}}

" User mappings. {{{
" nmap g? <Plug>(operator-rot-n)
" nmap g?? <Plug>(operator-rot-n-linewise)
" nmap g?g? <Plug>(operator-rot-n-linewise)
" xmap g? <Plug>(operator-rot-n-visual)
" }}}

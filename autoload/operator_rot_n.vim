" Initialization to prepare efficient ROT N transformation {{{
let s:initialized = 0

" I could generate this automatically but then some locale will probably break this in 2 weeks :)
let s:alphabet_lower_case = "abcdefghijklmnopqrstuvwxyz"
let s:alphabet_upper_case = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
let s:from = s:alphabet_lower_case . s:alphabet_upper_case
let s:encryption_to = {}

" preparation for optimized efficient decryption
" todo: make local
" tested. looks good.
function! Init() abort
    let from = s:alphabet_lower_case . s:alphabet_upper_case
    for i in range(1,25)
        let to_lower_case =   strcharpart(s:alphabet_lower_case, i) .
                            \ strcharpart(s:alphabet_lower_case, 0, i)
        let to_upper_case =   strcharpart(s:alphabet_upper_case, i) .
                            \ strcharpart(s:alphabet_upper_case, 0, i)
        " keys are converted to strings automatically because Vimscript thinks that's funny
        let s:encryption_to[i] = to_lower_case . to_upper_case
    endfor
    let s:initialized = 1
    " echom from
    " echom string(s:encryption_to)
endfunction
" }}}

" I tried to implement on-demand initialization, but then the first invocation
" would always fail. very mysterious o_O
call Init()

" Operator setup in normal and visual mode {{{
function! operator_rot_n#SetupOperator()
    " echom "Called operator_rot_n#SetupOperator()"
    call s:SaveCount()
    set operatorfunc=operator_rot_n#OperatorRotN
endfunction

function! operator_rot_n#OperatorRotNVisualMode()
    " echom "Called operator_rot_n#OperatorRotNVisualMode() with v:count=" . v:count
    call s:SaveCount()
    call operator_rot_n#OperatorRotN(visualmode())
endfunction

function! s:SaveCount()
    let s:count = v:count ==# 0 ? g:OperatorRotN_default_count : v:count
endfunction
" }}}

function! operator_rot_n#OperatorRotN(type) " {{{
    " echom "operator func called me. v:count1=" . v:count1 . " and v:count=" . v:count " and s:count=" . s:count ", type=" . a:type
    let s:count = s:count % 26
    if s:count ==# 0
        " e.g. optimized double ROT13 encryption!
        return
    endif
    if a:type ==# 'char' || a:type ==# 'line'
        let selected_text = operator_rot_n#GetYankedSelection(a:type)
        call map(selected_text, "tr(v:val, s:from, s:encryption_to[s:count])")
        call operator_rot_n#ReplaceYankedSelection(selected_text, a:type)
        call setpos(".", getpos("'["))
        call repeat#set("\<Plug>(operator-rot-n-repeat)")
    elseif a:type ==# 'v' || a:type ==# 'V' || a:type ==# "\<C-v>"
        let selected_text = operator_rot_n#GetVisualSelection()
        call map(selected_text, "tr(v:val, s:from, s:encryption_to[s:count])")
        call operator_rot_n#ReplaceVisualSelection(selected_text, a:type)
        call setpos(".", getpos("'<"))
        call repeat#set("\<Plug>(operator-rot-n-repeat-visual)")
    else
        throw "This should never happen: Called OperatorRotN with wrong type=" . a:type
    endif
    " todo: setpos am ende korrekt?
endfunction " }}}

" Magic repeat tricks {{{
function! operator_rot_n#OperatorRotNRepeat()
    " echom "Called operator_rot_n#OperatorRotNRepeat() with v:count=" . v:count
    call SaveCountBeforeRepeat()
    normal! .
endfunction

function! operator_rot_n#OperatorRotNRepeatVisual()
    " echom "Called operator_rot_n#OperatorRotNRepeatVisual() with v:count=" . v:count
    call SaveCountBeforeRepeat()
    execute "normal! 1v\<Esc>"
    call operator_rot_n#OperatorRotN(visualmode())
endfunction

function! SaveCountBeforeRepeat()
    " echom "Called SaveCountBeforeRepeat() with v:count=" . v:count . " and g:OperatorRotN_reuse_count_on_repeat=" . g:OperatorRotN_reuse_count_on_repeat
    let fallback_count = g:OperatorRotN_reuse_count_on_repeat ? s:count : g:OperatorRotN_default_count
    let s:count = v:count > 0 ? v:count : fallback_count
endfunction " }}}

" This loses some precision w.r.t. NL vs NUL characters. oh well.
" Uses visual selection, i.e. the last visual selection is lost afterwards.
function! operator_rot_n#GetYankedSelection(type) " {{{
    let backup_registers = operator_rot_n#BackupRegisterList(['a'])
    if a:type == 'char' || (a:type == 'line' && !g:OperatorRotN_linewise_motions_select_whole_lines)
        normal! `[v`]"ay
    elseif (a:type == 'line' && g:OperatorRotN_linewise_motions_select_whole_lines)
        normal! `[V`]"ay
    else
        throw "Called operator_rot_n#GetYankedSelection() with wrong type=" . a:type
    endif
    " Get the text as a list of lines
    let selected_text = getreg('a', 1, 1)
    " echom "yanked selection=" . @a
    call operator_rot_n#RestoreRegisterDict(backup_registers)
    return selected_text
endfunction " }}}

function! operator_rot_n#ReplaceYankedSelection(text, type) abort " {{{
    let backup_registers = operator_rot_n#BackupRegisterList(['a'])
    call setreg('a', a:text, "v")
    if a:type == 'char' || (a:type == 'line' && !g:OperatorRotN_linewise_motions_select_whole_lines)
        normal! `[v`]"ap
    elseif (a:type == 'line' && g:OperatorRotN_linewise_motions_select_whole_lines)
        normal! `[V`]"ap
    else
        throw "Called operator_rot_n#GetYankedSelection() with wrong type=" . a:type
    endif
    call operator_rot_n#RestoreRegisterDict(backup_registers)
endfunction " }}}

" type should be "v", "V" or "\<C-v>"
function! operator_rot_n#ReplaceVisualSelection(text, type) abort " {{{
       let backup_registers = operator_rot_n#BackupRegisterList(['a'])
       call setreg('a', a:text, a:type)
       normal! gv"ap
       call operator_rot_n#RestoreRegisterDict(backup_registers)
endfunction "}}}

" This loses some precision w.r.t. NL vs NUL characters. oh well.
function! operator_rot_n#GetVisualSelection() abort " {{{
    let backup_registers = operator_rot_n#BackupRegisterList(['a'])
    normal! gv"ay
    " Get the text as a list of lines
    let selected_text = getreg('a', 1, 1)
    call operator_rot_n#RestoreRegisterDict(backup_registers)
    return selected_text
endfunction " }}}

" Register backup and restoration {{{
function! s:BackupRegister(register) abort
    " see :h setreg() and getreg() for the last two crazy arguments
    let l:register_value = getreg(a:register, 1, 1)
    let l:register_type = getregtype(a:register)
    return {'register_value': l:register_value, 'register_type': l:register_type}
endfunction

function! s:RestoreRegister(register, register_backup) abort
    let l:register_value = a:register_backup['register_value']
    let l:register_type = a:register_backup['register_type']
    call setreg(a:register, l:register_value, l:register_type)
endfunction

function! operator_rot_n#BackupRegisterList(register_list) abort
    let l:registers_backup = {}
    for l:register in a:register_list
        let l:registers_backup[l:register] = s:BackupRegister(l:register)
    endfor
    return l:registers_backup
endfunction

function! operator_rot_n#RestoreRegisterDict(registers_backup) abort
    for [l:register, l:register_backup] in items(a:registers_backup)
        call s:RestoreRegister(l:register, l:register_backup)
    endfor
endfunction
" }}}

# Vim-Operator-Rot-N

This Vim plugin provides an operator for Rot-N encryption/decryption.

# ... Why?
Do your friends send you Rot-N encrypted messages because they think it's funny, leaving you agonized over a mess of jumbled letters, frantically searching for that ad-free website with a military-grade-Rot-N-decryption service?\
That sadness ends today!\
Dwell in serenity as you open their obfuscated message in [Vim](https://www.vim.sexy/), press `g?ip........` and laugh silently as soon as the brute-force decrypted message appears.
Afterwards, spend 2 minutes writing an answer message, and 15+ minutes to design a macro that Rot-N encrypts every word of your reply with a different N.

# Features
Vim has a built-in ROT13 operator `g?`, see `:help rot13`. 
In contrast, this plugin provides a more general Rot-N operator with special count handling:
* `10g?2aw` does a ROT-10 encryption on the next 2 words.
* Repeatable: `5.` does a ROT-5 encryption on the same 2 word.
* With `g?{motion}`, a customizable default value is used for N.

# Guide
## Mappings
No mappings are created automatically. Add your own. I use:
```
nmap g? <Plug>(operator-rot-n)
nmap g?? <Plug>(operator-rot-n-linewise)
nmap g?g? <Plug>(operator-rot-n-linewise)
xmap g? <Plug>(operator-rot-n-visual)
```
## Usage
Assuming my suggested mappings, you can use this operator with `[count]g?{motion}`.\
The `[count]` before the operator determines the N for the Rot-N transformation.\
The `{motion}` can also take a count as usual, but that one does not influence the already chosen N.\
If no `[count]` is supplied, the value from `g:OperatorRotN_default_count` is used (default 1).\
In visual mode, the `[count]` is interpreted analogously.

## Repeat
You can repeat the transformation on the same text with `.`.\
Using `[count].` executes a Rot-`[count]` transformation on the same text as before.\
If `.` is used without a `[count]`, the used N depends on the value of `g:OperatorRotN_reuse_count_on_repeat`:\
If enabled, the `[count]` from the last invocation is reused.\
If disabled, `g:OperatorRotN_default_count` is used.

## Behaviour on linewise motions.
If `g:OperatorRotN_linewise_motions_select_whole_lines` is enabled (default 1), then linewise operators such as `j` select whole lines.\
Otherwise, the `'[` and `']` marks determine the selection.
There is usually no good reason to change this setting.

# Requirements
Requires [vim-repeat](https://github.com/tpope/vim-repeat).\
Developed and tested on Neovim 0.4.3. When I tested it on Vim 8.2, it worked, too.

# Implementation
100% highly-efficient Vimscript, especially optimized for double ROT13 encryption.

# Related Plugins
I didn't find any. This probably means that no one else's friends send them ROT-N encrypted messages for fun. But you can install this plugin today and tqsfbe the word!

# License
The Vim licence applies. See `:help license`.

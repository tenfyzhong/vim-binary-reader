"==============================================================
"    file: vim-binary-reader.vim
"   brief: use xxd to read binary files
" VIM Version: 7.4
"  author: tenfyzhong
"   email: 364755805@qq.com
" created: 2016-05-02 12:55:03
"==============================================================

if !has('perl') || !executable('xxd')
    finish
endif

if exists("g:vim_binary_reader_disable") && 
            \g:vim_binary_reader_disable == 1
    finish
endif

function! s:BinaryBufReadPost() "{{{
    if &bin && &buftype == ''
        silent %!xxd
        set ft=xxd
    endif
endfunction "}}}

function! s:BinaryBufWritePre() "{{{
    if &bin && &ft == 'xxd'
        silent %!xxd -r
    endif
endfunction "}}}

function! s:BinaryBufWritePost() "{{{
    if &bin && &ft == 'xxd'
        silent %!xxd
        set nomod
    endif
endfunction "}}}

function! s:SetIfBinary(filename) "{{{
    if &buftype != ''
        return
    endif

    let l:extension = fnamemodify(a:filename, ':e')
    if l:extension != ''
        if exists("g:vim_binary_reader_extensions") && 
                    \g:vim_binary_reader_extensions =~? l:extension
            setlocal binary
        endif
        return 
    endif

perl << EOF
    ($success, $value) = VIM::Eval("a:filename");
    if ($success && -B $value) {
        VIM::DoCommand("setlocal binary");
    }
EOF
endfunction "}}}

if !exists("g:vim_binary_reader_extensions")
    let g:vim_binary_reader_extensions = "^\(bin\|dat\|mp3\|mp4\|o\|a\|so\|exe\|class\)$"
endif

" vim -b : edit binary using xxd-format!
augroup vim-binary-reader-init
    au!
    au BufReadPre * call <SID>SetIfBinary(expand('%'))
    au BufreadPost * call <SID>BinaryBufReadPost()
    au BufWritePre * call <SID>BinaryBufWritePre()
    au BufWritePost * call <SID>BinaryBufWritePost()
augroup END

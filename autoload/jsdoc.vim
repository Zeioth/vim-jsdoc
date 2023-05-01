" jsdoc.vim - Automatic jsdoc management for Vim
" Maintainer:   Zeioth
" Version:      1.0.0




" Path helper methods {{{

function! jsdoc#chdir(path)
    if has('nvim')
        let chdir = haslocaldir() ? 'lcd' : haslocaldir(-1, 0) ? 'tcd' : 'cd'
    else
        let chdir = haslocaldir() ? ((haslocaldir() == 1) ? 'lcd' : 'tcd') : 'cd'
    endif
    execute chdir fnameescape(a:path)
endfunction

" Throw an exception message.
function! jsdoc#throw(message)
    throw "jsdoc: " . a:message
endfunction

" Show an error message.
function! jsdoc#error(message)
    let v:errmsg = "jsdoc: " . a:message
    echoerr v:errmsg
endfunction

" Show a warning message.
function! jsdoc#warning(message)
    echohl WarningMsg
    echom "jsdoc: " . a:message
    echohl None
endfunction

" Prints a message if debug tracing is enabled.
function! jsdoc#trace(message, ...)
    if g:jsdoc_trace || (a:0 && a:1)
        let l:message = "jsdoc: " . a:message
        echom l:message
    endif
endfunction

" Strips the ending slash in a path.
function! jsdoc#stripslash(path)
    return fnamemodify(a:path, ':s?[/\\]$??')
endfunction

" Normalizes the slashes in a path.
function! jsdoc#normalizepath(path)
    if exists('+shellslash') && &shellslash
        return substitute(a:path, '\v/', '\\', 'g')
    elseif has('win32')
        return substitute(a:path, '\v/', '\\', 'g')
    else
        return a:path
    endif
endfunction

" Shell-slashes the path (opposite of `normalizepath`).
function! jsdoc#shellslash(path)
    if exists('+shellslash') && !&shellslash
        return substitute(a:path, '\v\\', '/', 'g')
    else
        return a:path
    endif
endfunction

" Returns whether a path is rooted.
if has('win32') || has('win64')
    function! jsdoc#is_path_rooted(path) abort
        return len(a:path) >= 2 && (
                    \a:path[0] == '/' || a:path[0] == '\' || a:path[1] == ':')
    endfunction
else
    function! jsdoc#is_path_rooted(path) abort
        return !empty(a:path) && a:path[0] == '/'
    endfunction
endif

" }}}




" jsdoc helper methods {{{

" Finds the first directory with a project marker by walking up from the given
" file path.
function! jsdoc#get_project_root(path) abort
    if g:jsdoc_project_root_finder != ''
        return call(g:jsdoc_project_root_finder, [a:path])
    endif
    return jsdoc#default_get_project_root(a:path)
endfunction

" Default implementation for finding project markers... useful when a custom
" finder (`g:jsdoc_project_root_finder`) wants to fallback to the default
" behaviour.
function! jsdoc#default_get_project_root(path) abort
    let l:path = jsdoc#stripslash(a:path)
    let l:previous_path = ""
    let l:markers = g:jsdoc_project_root[:]
    while l:path != l:previous_path
        for root in l:markers
            if !empty(globpath(l:path, root, 1))
                let l:proj_dir = simplify(fnamemodify(l:path, ':p'))
                let l:proj_dir = jsdoc#stripslash(l:proj_dir)
                if l:proj_dir == ''
                    call jsdoc#trace("Found project marker '" . root .
                                \"' at the root of your file-system! " .
                                \" That's probably wrong, disabling " .
                                \"jsdoc for this file...",
                                \1)
                    call jsdoc#throw("Marker found at root, aborting.")
                endif
                for ign in g:jsdoc_exclude_project_root
                    if l:proj_dir == ign
                        call jsdoc#trace(
                                    \"Ignoring project root '" . l:proj_dir .
                                    \"' because it is in the list of ignored" .
                                    \" projects.")
                        call jsdoc#throw("Ignore project: " . l:proj_dir)
                    endif
                endfor
                return l:proj_dir
            endif
        endfor
        let l:previous_path = l:path
        let l:path = fnamemodify(l:path, ':h')
    endwhile
    call jsdoc#throw("Can't figure out what file to use for: " . a:path)
endfunction

" }}}




" ============================================================================
" YOU PROBABLY ONLY CARE FROM HERE
" ============================================================================

" jsdoc Setup {{{

" Setup jsdoc for the current buffer.
function! jsdoc#setup_jsdoc() abort
    if exists('b:jsdoc_files') && !g:jsdoc_debug
        " This buffer already has jsdoc support.
        return
    endif

    " Don't setup jsdoc for anything that's not a normal buffer
    " (so don't do anything for help buffers and quickfix windows and
    "  other such things)
    " Also don't do anything for the default `[No Name]` buffer you get
    " after starting Vim.
    if &buftype != '' || 
          \(bufname('%') == '' && !g:jsdoc_generate_on_empty_buffer)
        return
    endif

    " We only want to use vim-jsdoc in the filetypes supported by jsdoc
    if index(g:jsdoc_include_filetypes, &filetype) == -1
        return
    endif

    " Let the user specify custom ways to disable jsdoc.
    if g:jsdoc_init_user_func != '' &&
                \!call(g:jsdoc_init_user_func, [expand('%:p')])
        call jsdoc#trace("Ignoring '" . bufname('%') . "' because of " .
                    \"custom user function.")
        return
    endif

    " Try and find what file we should manage.
    call jsdoc#trace("Scanning buffer '" . bufname('%') . "' for jsdoc setup...")
    try
        let l:buf_dir = expand('%:p:h', 1)
        if g:jsdoc_resolve_symlinks
            let l:buf_dir = fnamemodify(resolve(expand('%:p', 1)), ':p:h')
        endif
        if !exists('b:jsdoc_root')
            let b:jsdoc_root = jsdoc#get_project_root(l:buf_dir)
        endif
        if !len(b:jsdoc_root)
            call jsdoc#trace("no valid project root.. no jsdoc support.")
            return
        endif
        if filereadable(b:jsdoc_root . '/.nojsdoc')
            call jsdoc#trace("'.nojsdoc' file found... no jsdoc support.")
            return
        endif

        let b:jsdoc_files = {}
        " for module in g:jsdoc_modules
        "     call call("jsdoc#".module."#init", [b:jsdoc_root])
        " endfor
    catch /^jsdoc\:/
        call jsdoc#trace("No jsdoc support for this buffer.")
        return
    endtry

    " We know what file to manage! Now set things up.
    call jsdoc#trace("Setting jsdoc for buffer '".bufname('%')."'")

    " Autocommands for updating jsdoc on save.
    " We need to pass the buffer number to the callback function in the rare
    " case that the current buffer is changed by another `BufWritePost`
    " callback. This will let us get that buffer's variables without causing
    " errors.
    let l:bn = bufnr('%')
    execute 'augroup jsdoc_buffer_' . l:bn
    execute '  autocmd!'
    execute '  autocmd BufWritePost <buffer=' . l:bn . '> call s:write_triggered_update_jsdoc(' . l:bn . ')'
    execute 'augroup end'

    " Miscellaneous commands.
    command! -buffer -bang JsdocRegen :call s:manual_jsdoc_regen(<bang>0)
    command! -buffer -bang JsdocOpen :call s:jsdoc_open()

    " Keybindings
    "nmap <silent> <C-k> :<C-u>jsdocRegen<CR>
    "nmap <silent> <C-h> :<C-u>jsdocOpen<CR>
    nmap <silent> g:jsdoc_shortcut_regen . :<C-u>jsdocRegen<CR>
    nmap <silent> g:jsdoc_shortcut_open . :<C-u>jsdocOpen<CR>

endfunction

" }}}




"  jsdoc Management {{{

" (Re)Generate the docs for the current project.
function! s:manual_jsdoc_regen(bufno) abort
    if g:jsdoc_enabled == 1
      "visual feedback"
      if g:jsdoc_verbose_manual_regen == 1
        echo 'Manually regenerating jsdoc documentation.'
      endif

      " Run async
      call s:update_jsdoc(a:bufno , 0, 2)
    endif
endfunction

" Open jsdoc in the browser.
function! s:jsdoc_open() abort
    try
        let l:bn = bufnr('%')
        let l:proj_dir = getbufvar(l:bn, 'jsdoc_root')

        "visual feedback"
        if g:jsdoc_verbose_open == 1
          echo g:jsdoc_browser_cmd . ' ' . l:proj_dir . g:jsdoc_browser_file
        endif
        call job_start(['sh', '-c', g:doxygen_browser_cmd . ' ' . l:proj_dir . g:doxygen_browser_file], {})
    endtry
endfunction

" (re)generate jsdoc for a buffer that just go saved.
function! s:write_triggered_update_jsdoc(bufno) abort
    if g:jsdoc_enabled && g:jsdoc_generate_on_write
      call s:update_jsdoc(a:bufno, 0, 2)
    endif
    silent doautocmd user jsdocupdating
endfunction

" update jsdoc for the current buffer's file.
" write_mode:
"   0: update jsdoc if it exists, generate it otherwise.
"   1: always generate (overwrite) jsdoc.
"
" queue_mode:
"   0: if an update is already in progress, report it and abort.
"   1: if an update is already in progress, abort silently.
"   2: if an update is already in progress, queue another one.
function! s:update_jsdoc(bufno, write_mode, queue_mode) abort
    " figure out where to save.
    let l:proj_dir = getbufvar(a:bufno, 'jsdoc_root')

    " Switch to the project root to make the command line smaller, and make
    " it possible to get the relative path of the filename.
    let l:prev_cwd = getcwd()
    call jsdoc#chdir(l:proj_dir)
    try
        
        " Generate the jsdoc docs where specified.
        if g:jsdoc_auto_regen == 1
          call job_start(['sh', '-c', g:jsdoc_cmd], {})

        endif       

    catch /^jsdoc\:/
        echom "Error while generating ".a:module." file:"
        echom v:exception
    finally
        " Restore the current directory...
        call jsdoc#chdir(l:prev_cwd)
    endtry
endfunction

" }}}

" jsdoc.vim - Automatic jsdoc management for Vim
" Maintainer:   Zeioth
" Version:      1.0.0




" Globals - Boiler plate {{{

if (&cp || get(g:, 'jsdoc_dont_load', 0))
    finish
endif

if v:version < 704
    echoerr "jsdoc: this plugin requires vim >= 7.4."
    finish
endif

let g:jsdoc_debug = get(g:, 'jsdoc_debug', 0)

if (exists('g:loaded_jsdoc') && !g:jsdoc_debug)
    finish
endif
if (exists('g:loaded_jsdoc') && g:jsdoc_debug)
    echom "Reloaded jsdoc."
endif
let g:loaded_jsdoc = 1

let g:jsdoc_trace = get(g:, 'jsdoc_trace', 0)

let g:jsdoc_enabled = get(g:, 'jsdoc_enabled', 1)

" }}}




" Globals - For border cases {{{


let g:jsdoc_project_root = get(g:, 'jsdoc_project_root', ['.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout'])

let g:jsdoc_project_root_finder = get(g:, 'jsdoc_project_root_finder', '')

let g:jsdoc_exclude_project_root = get(g:, 'jsdoc_exclude_project_root', 
            \['/usr/local', '/opt/homebrew', '/home/linuxbrew/.linuxbrew'])

let g:jsdoc_include_filetypes = get(g:, 'jsdoc_include_filetypes', ['rust'])
let g:jsdoc_resolve_symlinks = get(g:, 'jsdoc_resolve_symlinks', 0)
let g:jsdoc_generate_on_new = get(g:, 'jsdoc_generate_on_new', 1)
let g:jsdoc_generate_on_write = get(g:, 'jsdoc_generate_on_write', 1)
let g:jsdoc_generate_on_empty_buffer = get(g:, 'jsdoc_generate_on_empty_buffer', 0)

let g:jsdoc_init_user_func = get(g:, 'jsdoc_init_user_func', 
            \get(g:, 'jsdoc_enabled_user_func', ''))

let g:jsdoc_define_advanced_commands = get(g:, 'jsdoc_define_advanced_commands', 0)


" }}}




" Globals - The important stuff {{{

" jsdoc - Auto regen
let g:jsdoc_auto_regen = get(g:, 'jsdoc_auto_regen', 1)
let g:jsdoc_cmd = get(g:, 'jsdoc_cmd', 'jsdoc ')

" jsdoc - Open on browser
let g:jsdoc_browser_cmd = get(g:, 'jsdoc_browser_cmd', 'xdg-open')
let g:jsdoc_browser_file = get(g:, 'jsdoc_browser_file', '/docs/index.html')

" jsdoc - Verbose
let g:jsdoc_verbose_manual_regen = get(g:, 'jsdoc_verbose_open', '1')
let g:jsdoc_verbose_open = get(g:, 'jsdoc_verbose_open', '1')


" }}}




" jsdoc Setup {{{

augroup jsdoc_detect
    autocmd!
    autocmd BufNewFile,BufReadPost *  call jsdoc#setup_jsdoc()
    autocmd VimEnter               *  if expand('<amatch>')==''|call jsdoc#setup_jsdoc()|endif
augroup end

" }}}




" Misc Commands {{{

if g:jsdoc_define_advanced_commands
    command! JsdocToggleEnabled :let g:jsdoc_enabled=!g:jsdoc_enabled
    command! JsdocToggleTrace   :call jsdoc#toggletrace()
endif

" }}}


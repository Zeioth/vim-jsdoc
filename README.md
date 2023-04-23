# vim-jsdoc
Out of the box, this plugin automatically regenerates your jsdoc
documentation. Currently, this plugin is in highly experimental state.

## Dependencies
None. Rust ships with this tool.

## Documentation
Please use <:h jsdoc> on vim to read the [full documentation](https://github.com/Zeioth/vim-jsdoc/blob/main/doc/jsdoc.txt).

## How to use

You just need to define the next keybindings (you MUST setup this)

```
" Shortcuts to open and generate docs
nmap <silent> <C-k> :<C-u>jsdocRegen<CR>
nmap <silent> <C-h> :<C-u>jsdocOpen<CR>
```

Enable automated doc generation on save (optional)
```
let g:jsdoc_auto_regen = 1

" jsdoc - Open on browser
let g:jsdoc_browser_cmd = get(g:, 'jsdoc_browser_cmd', 'xdg-open')
let g:jsdoc_browser_file = get(g:, 'jsdoc_browser_file', './docs/index.html')
```

Custom command to generate the jsdoc documentation (optional)

```
let g:jsdoc_cmd = get(g:, 'jsdoc_cmd', 'jsdoc')
```

Change the way the root of the project is detected (optional)

```
" By default, we detect the root of the project where the first .git file is found
let g:jsdoc_project_root = ['.git', '.hg', '.svn', '.bzr', '_darcs', '_FOSSIL_', '.fslckout']
```

## Final notes

Please have in mind that you are responsable for adding your jsdoc directory to the .gitignore if you don't want it to be pushed by accident.

It is also possible to disable this plugin for a single project. For that, create .nojsdoc file in the project root directory.

## Credits
This project started as a hack of [vim-doxygen](https://github.com/Zeioth/vim-doxygen), which started as a hack of [vim-guttentags](https://github.com/ludovicchabant/vim-gutentags). We use its boiler plate functions to manage directories in vimscript with good compatibility across operative systems. So please support its author too if you can!

# vim-jsdoc
Out of the box, this plugin automatically regenerates your jsdoc
documentation. Currently, this plugin is in highly experimental state.

## Dependencies
```sh
# For this to work, you must install typedoc like
sudo npm -g jsdoc
```

You also need to have a 'jsdoc.json' file like this in your project root
directory.
```json
{
	"source": {
		"include": ["./src"],
		"includePattern": ".+\\.js(doc|x)?$",
		"exclude": "node_modules/|docs"
	},
	"plugins": [],
	"opts": {
		"destination": "docs/"
	}
}
```
To see all possiple options, check the
[JsDoc official documentation](https://jsdoc.app/about-configuring-jsdoc.html).

## Documentation
Please use <:h jsdoc> on vim to read the [full documentation](https://github.com/Zeioth/vim-jsdoc/blob/main/doc/jsdoc.txt).

## How to use
Copy this in your vimconfig:

```
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim jsdoc
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Enable it for the next languages
let g:jsdoc_include_filetypes = ['javascript']

" Enable the keybindings for the languages in g:jsdoc_include_filetypes
augroup jsdoc_mappings
  for ft in g:jsdoc_include_filetypes
    execute 'autocmd FileType ' . ft . ' nnoremap <buffer> <C-h> :<C-u>JsdocOpen<CR>'
    "execute 'autocmd FileType ' . ft . ' nnoremap <buffer> <C-k> :<C-u>JsdocRegen<CR>'
  endfor
augroup END
```

## Most frecuent options users customize

Enable automated doc generation on save (optional)
```
" Enabled by default for the languages defined in g:jsdoc_include_filetypes
let g:jsdoc_auto_regen = 1
```

Change the way the documentation is opened (optional)
```
" jsdoc - Open on browser
let g:jsdoc_browser_cmd = get(g:, 'jsdoc_browser_cmd', 'xdg-open')
let g:jsdoc_browser_file = get(g:, 'jsdoc_browser_file', './docs/index.html')
```

Custom command to generate the jsdoc documentation (optional)

```
let g:jsdoc_cmd = 'jsdoc'
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

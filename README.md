# vim-bibcite

## Introduction

This plugin provides autocompletion of citations from `.bib` files while
working in TeX or LaTeX documents.

The original code comes from Karl Yngve Lervåg’s [vimtex][vt], which is a much
fuller and more mature plugin. You should seriously consider using that
instead. Another plugin, Guillem Ballesteros’s [vim-autocite][vac], gave me the
idea to pull out this one feature of [vim-latex][vt]. I’ve adapted, or flat out
copied, most of this plugin from their prior efforts. Anything that works is to
their credit; anything that doesn’t work is my fault.

[vt]: https://github.com/lervag/vimtex
[vac]: https://github.com/GCBallesteros/vim-autocite

## Pathogen Installation

```console
$ cd ~/.vim/bundle
$ git clone https://github.com/telemachus/vim-bibcite.git
```

## Usage

vim-bibcite autocompletes using any `.bib` files found in the same directory as
the file the user is editing. Simply start typing a citation and enter
`Control-X Control-O` to trigger a list of possible completions. (See [`help
i_CTRL-X_CTRL-O`][cxco] for more details about how to browse the list of possible
completions.)

That’s it. No configuration is needed or possible. (See below for limitations.)

[cxco]: http://vimdoc.sourceforge.net/htmldoc/insert.html#i_CTRL-X_CTRL-O

## Limitations

+ The user can’t manually tell vim-bibcite where to find `.bib` files.
+ If `.bib` files are not in the exact same directory as the file the user is
  editing, vim-bibcite won’t find them.

## Dependencies

vim-bibcite requires bibtex. If bibtex isn’t installed, the plugin won’t do anything.

## Contributions, Requests, or Suggestions

If you would like to contribute, please submit [a pull request][pr]. If you
have a request or a suggestion, please [submit an issue][issue]. Thanks, in either case!

[pr]: https://github.com/telemachus/vim-bibcite/pulls
[issue]: https://github.com/telemachus/vim-bibcite/issues

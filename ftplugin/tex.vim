if &compatible || exists('g:loaded_bibcite_vim') && g:loaded_bibcite_vim
  finish
endif
let g:loaded_bibcite_vim = 1

if !executable('bibtex')
  " I don't think I want to be this chatty. Remove message for now.
  " echom "Warning: bibtex completion not available"
  " echom "         Missing executable: bibtex"
  finish
endif

setlocal omnifunc=bibcite#omnifunc

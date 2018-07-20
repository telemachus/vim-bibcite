" Bibtex citation autocompletion
" vim-bibcite: https://github.com/telemachus/vim-bibcite
" Maintainer: Peter Aronoff
" Email: telemachus@arpinum.org
"
" This code has been extracted and modified from the following plugins:
"
" vimtex: https://github.com/lervag/vimtex
" Maintainer: Karl Yngve Lervåg
" Email: karl.yngve+git@gmail.com
"
" vim-autocite: https://github.com/GCBallesteros/vim-autocite
" Maintainer: Guillem Ballesteros
" Email: guillem.ballesteros.garcia@gmail.com

function! bibcite#omnifunc(findstart, base)
  if a:findstart
    " Note: bibcite_complete_patterns is a dictionary where the keys are
    " the types of completion and the values are the patterns that must match
    " for the given type.
    let bibcite_complete_patterns = {
          \ 'cite' : '\v\\\a*cite\a*%(\s*\[[^]]*\]){0,2}\s*\{[^}]*$',
          \ 'bibentry' : '\v\\bibentry\s*\{[^}]*$',
          \ 'tbcquote' : '\v\\%(text|block)cquote\*?%(\s*\[[^]]*\]){0,2}\{[^}]*$',
          \ 'fhcquote' : '\v\\%(for|hy)\w+cquote\*?\{[^}]*\}%(\s*\[[^]]*\]){0,2}\{[^}]*$',
          \ }
    let pos  = col('.') - 1
    let line = getline('.')[:pos-1]
    for [type, pattern] in items(bibcite_complete_patterns)
      if line =~ pattern . '$'
        while pos > 0
          if line[pos - 1] =~ '{\|,' || line[pos-2:pos-1] == ', '
            return pos
          else
            let pos -= 1
          endif
        endwhile
        return -2
      endif
    endfor
  else
    return bibcite#bibtex(a:base)
  endif
endfunction

function! bibcite#bibtex(regexp)
  let res = []

  let type_length = 4
  for m in bibcite#search(a:regexp)
    let type = m['type']   == '' ? '[-]' : '[' . m['type']   . '] '
    let auth = m['author'] == '' ? ''    :       m['author'][:20] . ' '
    let year = m['year']   == '' ? ''    : '(' . m['year']   . ')'

    " Align the type entry and fix minor annoyance in author list
    let type = printf('%-' . type_length . 's', type)
    let auth = substitute(auth, '\~', ' ', 'g')
    let auth = substitute(auth, ',.*\ze', ' et al. ', '')

    let w = {
          \ 'word': m['key'],
          \ 'abbr': type . auth . year,
          \ 'menu': m['title']
          \ }

    call add(res, w)
  endfor

  return res
endfunction

" This variable must be set outside of function scope. Otherwise, vim goes
" looking for our .bst file in the directory where the user is editing rather
" than in the same directory as this script.
let s:bstfile = expand('<sfile>:p:h') . '/vimcomplete'

function! bibcite#search(regexp)
  let res = []
  let type_length = 0

  " Find data from external bib files
  let bibfiles = join(bibcite#load(), ',')
  if bibfiles != ''
    " Define temporary files
    let tmp = {
          \ 'aux' : 'tmpfile.aux',
          \ 'bbl' : 'tmpfile.bbl',
          \ 'blg' : 'tmpfile.blg',
          \ }

    " Write temporary aux file
    call writefile([
          \ '\citation{*}',
          \ '\bibstyle{' . s:bstfile . '}',
          \ '\bibdata{' . bibfiles . '}',
          \ ], tmp.aux)

    " Create the temporary bbl file
    let exe = {}
    let exe.cmd = 'bibtex -terse ' . tmp.aux
    let exe.bg = 0
    call bibcite#execute(exe)

    " Parse temporary bbl file
    let lines = split(substitute(join(readfile(tmp.bbl), "\n"),
          \ '\n\n\@!\(\s\=\)\s*\|{\|}', '\1', 'g'), "\n")

    for line in filter(lines, 'v:val =~ a:regexp')
      let matches = matchlist(line,
            \ '^\(.*\)||\(.*\)||\(.*\)||\(.*\)||\(.*\)')
      if !empty(matches) && !empty(matches[1])
        let type_length = max([type_length, len(matches[2]) + 3])
        call add(res, {
              \ 'key':    matches[1],
              \ 'type':   matches[2],
              \ 'author': matches[3],
              \ 'year':   matches[4],
              \ 'title':  matches[5],
              \ })
      endif
    endfor

    " Clean up
    call delete(tmp.aux)
    call delete(tmp.bbl)
    call delete(tmp.blg)
  endif

  return res
endfunction

function! bibcite#load()
  let bibs_in_dir = []

  " Search for bibliographies in the directory of the TeX document.
  let bibs_in_dir = split(globpath(fnamemodify(expand("%:p"), ":h"), '*.bib'), '\n')

  return bibs_in_dir
endfunction

function! bibcite#execute(exe)
  " Execute the given command on the current system.  Wrapper function to make
  " it easier to run on both windows and unix.
  "
  " The command is given in the argument exe, which should be a dictionary with
  " the following entries:
  "
  "   exe.cmd     String          String that contains the command to run
  "   exe.bg      0 or 1          Run in background or not
  "   exe.silent  0 or 1          Show output or not
  "   exe.null    0 or 1          Send output to /dev/null
  "   exe.wd      String          Run command in provided working directory
  "
  " Only exe.cmd is required.

  " Check and parse arguments
  if !has_key(a:exe, 'cmd')
    echoerr "Error in latex#util#execute!"
    echoerr "Argument error, exe.cmd does not exist!"
    return
  endif
  let bg = has_key(a:exe, 'bg') ? a:exe.bg     : 1
  let silent = has_key(a:exe, 'silent') ? a:exe.silent : 1
  let null = has_key(a:exe, 'null') ? a:exe.null   : 1

  " Change directory if wanted
  if has_key(a:exe, 'wd')
    let pwd = getcwd()
    execute 'lcd ' . a:exe.wd
  endif

  " Set up command string based on the given system
  if has('win32')
    if bg
      let cmd = '!start /b ' . a:exe.cmd
    else
      let cmd = '!' . a:exe.cmd
    endif
    if null
      let cmd .= ' >nul'
    endif
  else
    let cmd = '!' . a:exe.cmd
    if null
      let cmd .= ' &>/dev/null'
    endif
    if bg
      let cmd .= ' &'
    endif
  endif

  if silent
    silent execute cmd
  else
    execute cmd
  endif

  " Return to previous working directory
  if has_key(a:exe, 'wd')
    execute 'lcd ' . pwd
  endif

  if !has("gui_running")
    redraw!
  endif
endfunction

let s:sep = fnamemodify('.', ':p')[-1:]
let s:session_list_buffer = 'SESSIONS'

" utility
function! s:echo_err(m) abort
  echohl ErrorMsg
  echomsg 'learn-smg.vim:' a:msg
  echohl None
endfunction

" for neovim
if exists('*readdir')
  let s:readdir = function('readdir')
else
  function! s:readdir(dir) abort
    return map(glob(a:dir . s:sep . '*', 1, 1), 'fnamemodify(v:val, ":t")')
  endfunction
endif

" local functions
function! s:files() abort
  let session_path = get(g:, 'learn_smg_session_path', '')

  if session_path is# ''
    call s:echo_err('g:learn_smg_session_path is empty')
    return []
  endif

  let session_path = expand(session_path)
  let Filter = { file -> !isdirectory(session_path . s:sep . file) }
  return filter(s:readdir(session_path), Filter)
endfunction

" learn_smg functions
function! learnsmg#create_session(file) abort
  execute 'mksession!' join([g:learn_smg_session_path, a:file], s:sep)

  redraw
  echo 'learn-smg.vim: created'
endfunction

function! learnsmg#load_session(file) abort
  execute 'source' join([g:learn_smg_session_path, a:file], s:sep)
endfunction

function! learnsmg#sessions() abort
  let files = s:files()
  if empty(files)
    return
  endif

  if bufexists(s:session_list_buffer)
    let winid = bufwinid(s:session_list_buffer)
    if winid isnot# -1
      call win_gotoid(winid)
    else
      execute 'sbuffer' s:session_list_buffer
    endif
  else
    execute 'new' s:session_list_buffer

    set buftype=nofile
    nnoremap <silent> <buffer>
          \ <Plug>(session-close)
          \ :<C-u>bwipeout!<CR>
    nnoremap <silent> <buffer>
          \ <Plug>(session-open)
          \ :<C-u>call learnsmg#load_session(trim(getline('.')))<CR>

    nmap <buffer> q <Plug>(session-close)
    nmap <buffer> <CR> <Plug>(session-open)
  endif

  %delete _
  call setline(1, files)
endfunction

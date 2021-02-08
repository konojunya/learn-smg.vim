if exists('g:loaded_learn_smg')
  finish
endif
let g:loaded_learn_smg = 1

command! LearnSMGSessionList call learnsmg#sessions()
command! -nargs=1 LearnSMGSessionCreate call learnsmg#create_session(<q-args>)

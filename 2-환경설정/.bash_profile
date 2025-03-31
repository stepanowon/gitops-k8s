function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

function proml {
  local GREEN="\[\033[1;32m\]"
  local WGRAY="\[\033[00m\]"
  PS1="\u@\h:\w$GREEN\$(parse_git_branch)$WGRAY\$ "
  PS2='> '
  PS4='+ '
}
proml

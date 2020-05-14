function vi {
  if type -P vim >/dev/null; then
    command vim "$@"
  else
    command vi "$@"
  fi
}

function reload {
  pushd ~ > /dev/null
  source ./.bash_profile
  popd > /dev/null

  for a in "$@"; do
    "reload-$a"
  done
}

function reload-gpg {
  export GPG_TTY=$(tty)
  gpg-connect-agent updatestartuptty /bye >/dev/null
  gpg --card-status
}

function adjust_ps1 {
  perl -pe 's{(\\\$)([^\$]+?)$}{$1$2}s'
}

function render_ps1 {
  local ec="$?"
  
  export PS1_VAR=

  local nm_profile="${AWS_PROFILE}"
  if [[ -n "${nm_profile}" ]]; then
    if [[ -n "${AWS_OKTA_SESSION_EXPIRATION:-}" ]]; then
      local time_left="$(( AWS_OKTA_SESSION_EXPIRATION - $(date +%s) ))"
      if [[ "${time_left}" -lt 0 ]]; then
        time_left=""
      fi
      PS1_VAR="${PS1_VAR:+${PS1_VAR}}@${nm_profile}${time_left:+ ${time_left}}"
    else
      PS1_VAR="${PS1_VAR:+${PS1_VAR}}@${nm_profile}"
    fi

    if [[ -n "${AWS_DEFAULT_REGION:-}" ]]; then
      PS1_VAR="${PS1_VAR:+${PS1_VAR}} ${AWS_DEFAULT_REGION}"
    fi
  fi

  if [[ -n "${TMUX_PANE:-}" ]]; then
    PS1_VAR="${TMUX_PANE}${PS1_VAR:+ ${PS1_VAR}}"
  fi

  echo
  powerline-go -error "$ec" --colorize-hostname -cwd-mode plain -mode flat -newline \
    -priority root,cwd,user,host,ssh,perms,git-branch,exit,cwd-path,git-status \
    -modules host,ssh,cwd,perms,gitlite,load,exit${PS1_VAR:+,shell-var --shell-var PS1_VAR} \
    -theme ~/.dotfiles/default.json
}

function update_ps1 {
  PS1="$(render_ps1 | adjust_ps1)"
}

if [[ -f ~/.env ]]; then
  source ~/.env
fi

if tty >/dev/null; then
  if type -P powerline-go >/dev/null; then
    PROMPT_COMMAND="update_ps1"
  fi
fi


export AWS_OKTA_BACKEND=pass
#export AWS_OKTA_MFA_PROVIDER=YUBICO
export AWS_OKTA_MFA_PROVIDER=OKTA
#AWS_OKTA_MFA_FACTOR_TYPE=token:hardware
export AWS_OKTA_MFA_FACTOR_TYPE=push

export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"

export VAULT_ADDR=https://vault.whoa.bot

export NODEJS_CHECK_SIGNATURES=no

export KUBECTX_IGNORE_FZF=1

export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

export TERM=xterm-256color
export TERM_PROGRAM=iTerm.app

export LC_COLLATE=C
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
unset LC_ALL

if type -P vim >/dev/null; then
  export EDITOR="$(which vim)"
else
  export EDITOR="$(which vi)"
fi


function vi {
  if type -P vim >/dev/null; then
    command vim "$@"
  else
    command vi "$@"
  fi
}

function profile {
  if [[ "$#" == 0 ]]; then
    unset AWS_PROFILE AWS_DEFAULT_REGION AWS_REGION
    reset-aws
    return 0
  fi

  export AWS_PROFILE="$1"

  if [[ -n "${2:-}" ]]; then
    export AWS_DEFAULT_REGION="$2"
    export AWS_REGION="$2"
  else
    local region="$(unset AWS_DEFAULT_REGION AWS_REGION; aws configure get region)"
    if [[ -n "${region}" ]]; then
      export AWS_REGION="${region}" AWS_DEFAULT_REGION="${region}"
    else
      export AWS_REGION="us-east-1" AWS_DEFAULT_REGION="us-east-1"
    fi
  fi

  reset-aws
}

function renew {
  if [[ "$#" -gt 0 ]]; then
    profile "$1"
    shift
  fi

  eval $( 
    $(aws configure get credential_process) | jq -r '"export AWS_ACCESS_KEY_ID=\(.AccessKeyId) AWS_SECRET_ACCESS_KEY=\(.SecretAccessKey) AWS_SESSION_TOKEN=\(.SessionToken)"'
  )

  local region="$(unset AWS_DEFAULT_REGION AWS_REGION; aws configure --profile "${AWS_PROFILE}" get region)"
  if [[ -n "${region}" ]]; then
    export AWS_REGION="${region}" AWS_DEFAULT_REGION="${region}"
  else
    export AWS_REGION="us-east-1" AWS_DEFAULT_REGION="us-east-1"
  fi

  if [[ "$#" -gt 0 ]]; then
   "$@"
  fi
}

function reset-aws {
  unset \
    AWS_ACCESS_KEY_ID \
    AWS_OKTA_ASSUMED_ROLE \
    AWS_OKTA_ASSUMED_ROLE_ARN \
    AWS_OKTA_PROFILE \
    AWS_OKTA_SESSION_EXPIRATION \
    AWS_SECRET_ACCESS_KEY \
    AWS_SECURITY_TOKEN \
    AWS_SESSION_TOKEN
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
  unset GPG_TTY
}

function adjust_ps1 {
  perl -pe 's{(\\\$)([^\$]+?)$}{$1$2}s'
}

function expired {
  time_left=
  if [[ -n "${AWS_OKTA_SESSION_EXPIRATION:-}" ]]; then
    time_left="$(( AWS_OKTA_SESSION_EXPIRATION - $(date +%s) ))"
    if [[ "${time_left}" -lt 0 ]]; then
      return 0
    fi
  fi

  return 1
}

function render_ps1 {
  local ec="$?"
  
  export PS1_VAR=

  local nm_profile="${AWS_PROFILE}"
  if [[ -n "${nm_profile}" ]]; then
    if [[ -n "${AWS_OKTA_SESSION_EXPIRATION:-}" ]]; then
      PS1_VAR="${PS1_VAR:+${PS1_VAR}}@${nm_profile}${time_left:+ ${time_left}}"
    else
      PS1_VAR="${PS1_VAR:+${PS1_VAR}}@${nm_profile}"
    fi

    if [[ -n "${AWS_REGION:-}" ]]; then
      PS1_VAR="${PS1_VAR:+${PS1_VAR}} ${AWS_REGION}"
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
  if expired; then
    reset-aws
  fi
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

export AWS_SDK_LOAD_CONFIG=1
export AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_DEFAULT_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"

export VAULT_ADDR=https://vault.kitt.run

export NODEJS_CHECK_SIGNATURES=no

export KUBECTX_IGNORE_FZF=1

export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

export TERM=xterm-256color
export TERM_PROGRAM=iTerm.app

export LC_COLLATE=C
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
unset LC_ALL

unset GPG_TTY

if type -P vim >/dev/null; then
  export EDITOR="$(which vim)"
else
  export EDITOR="$(which vi)"
fi

function cm {
  source ~/.dotfiles/.cmrc
  _cm "$@"
}

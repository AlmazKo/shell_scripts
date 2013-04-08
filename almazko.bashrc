color_off="\e[0m"
prompt_begin="\e[1;96m "
prompt_end="\e[0;37m > $color_off"
prompt_cross="\e[0;37m > $color_off"
prompt_cross_end="\e[0;37m > $color_off" 
vcs_clean="\e[0;92m"
vcs_dirty="\e[0;91m"
vcs_branch=""

function parse_git_status {
  # clear git variables
  GIT_BRANCH=
  GIT_DIRTY=

  # exit if no git found in system
  local GIT_BIN=$(which git 2>/dev/null)
  [[ -z $GIT_BIN ]] && return

  # check we are in git repo
  local CUR_DIR=$PWD
  while [ ! -d ${CUR_DIR}/.git ] && [ ! $CUR_DIR = "/" ]; do CUR_DIR=${CUR_DIR%/*}; done
  [[ ! -d ${CUR_DIR}/.git ]] && return

  # 'git repo for dotfiles' fix: show git status only in home dir and other git repos
  [[ $CUR_DIR == $HOME ]] && [[ $PWD != $HOME ]] && return

  # get git branch
  GIT_BRANCH=$($GIT_BIN symbolic-ref HEAD 2>/dev/null)
  [[ -z $GIT_BRANCH ]] && return
  GIT_BRANCH=${GIT_BRANCH#refs/heads/}

  # get git status
  local GIT_STATUS=$($GIT_BIN status --porcelain 2>/dev/null)
  [[ -n $GIT_STATUS ]] && GIT_DIRTY=1
}


function prompt_command {
  local statuses
  local PS1_GIT=
  local PWDNAME=$PWD

  # beautify working firectory name
  if [ $HOME == $PWD ]; then
    PWDNAME="~"
  elif [ $HOME == ${PWD:0:${#HOME}} ]; then
    PWDNAME="~${PWD:${#HOME}}"
  fi

  # parse git status and get git variables
  parse_git_status

  local prompt_ending=
  local color_user=
  if $color_is_on; then
    # set user color
    case `id -u` in
      0) color_user=$color_red ;;
      *) color_user=$color_light_yellow ;;
    esac

    # build git status for prompt
    if [ ! -z $GIT_BRANCH ]; then
      if [ -z $GIT_DIRTY ]; then
	PS1_GIT="$vcs_clean${GIT_BRANCH}${color_off}"
      else
	PS1_GIT="$vcs_dirty${GIT_BRANCH}${color_off}"
      fi

      prompt_ending="$prompt_cross${vcs_branch}$PS1_GIT$prompt_cross_end"
    else
      prompt_ending=$prompt_end
    fi
  fi

  local jobs=$(jobs -l | wc -l)

  if [ $jobs -gt 0 ] ; then
    statuses="\e[0;93m ⭑$color_off"
  fi

  MY_DATE_TIME=`date +%H:%M:%S`""
  # set new color prompt

  PS1="$statuses$prompt_begin${PWDNAME}$color_off$prompt_ending "

}

PROMPT_COMMAND=prompt_command

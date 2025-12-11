# https://github.com/jackharrisonsherlock/common

# Prompt symbol
COMMON_PROMPT_SYMBOL="❯"

# Colors
COMMON_COLORS_HOST_ME=green
COMMON_COLORS_HOST_AWS_VAULT=yellow
COMMON_COLORS_CURRENT_DIR=blue
COMMON_COLORS_RETURN_STATUS_TRUE=magenta
COMMON_COLORS_RETURN_STATUS_FALSE=yellow
COMMON_COLORS_GIT_STATUS_DEFAULT=green
COMMON_COLORS_GIT_STATUS_STAGED=red
COMMON_COLORS_GIT_STATUS_UNSTAGED=yellow
COMMON_COLORS_GIT_PROMPT_SHA=green
COMMON_COLORS_BG_JOBS=yellow

# Left Prompt
 PROMPT='$(common_host)$(common_current_dir)$(common_bg_jobs)$(common_return_status)'

# Right Prompt
 RPROMPT='$(common_git_status)'

# Enable redrawing of prompt variables
 setopt promptsubst

# Prompt with current SHA
# PROMPT='$(common_host)$(common_current_dir)$(common_bg_jobs)$(common_return_status)'
# RPROMPT='$(common_git_status) $(git_prompt_short_sha)'

# Host
common_host() {
  if [[ -n $SSH_CONNECTION ]]; then
    me="%n@%m"
  elif [[ $LOGNAME != $USER ]]; then
    me="%n"
  fi
  if [[ -n $me ]]; then
    echo "%{$fg[$COMMON_COLORS_HOST_ME]%}$me%{$reset_color%}:"
  fi
  if [[ $AWS_VAULT ]]; then
    echo "%{$fg[$COMMON_COLORS_HOST_AWS_VAULT]%}$AWS_VAULT%{$reset_color%} "
  fi
}

# Current directory
common_current_dir() {
  echo -n "%{$fg[$COMMON_COLORS_CURRENT_DIR]%}%c "
}

# Prompt symbol
common_return_status() {
  echo -n "%(?.%F{$COMMON_COLORS_RETURN_STATUS_TRUE}.%F{$COMMON_COLORS_RETURN_STATUS_FALSE})$COMMON_PROMPT_SYMBOL%f "
}

# Git status
common_git_status() {
local dir="$PWD"
    local is_repo=0
    while [[ -n "$dir" ]]; do
        if [[ -d "$dir/.git" ]]; then
            is_repo=1
            break
        fi
        if [[ "$dir" == "/" ]]; then break; fi
        dir="${dir%/*}"
        [[ -z "$dir" ]] && dir="/"
    done
    [[ $is_repo -eq 0 ]] && return

    local ref
    local status_out
    status_out=$(git status --porcelain --branch 2>/dev/null)
    
    local first_line="${status_out%%$'\n'*}"
    local branch="${first_line##\#\# }" 
    branch="${branch%%...*}"

    local message_color="%F{$COMMON_COLORS_GIT_STATUS_DEFAULT}"
    if [[ -n $status_out ]]; then
        local file_status="${status_out#*$'\n'}"
        
        if echo "$file_status" | grep -q "^[MADRCU]"; then
            message_color="%F{$COMMON_COLORS_GIT_STATUS_STAGED}"
        elif echo "$file_status" | grep -q "^.[MADRCU?]"; then
            message_color="%F{$COMMON_COLORS_GIT_STATUS_UNSTAGED}"
        fi
    fi

    echo -n "${message_color}${branch}%f"
}

# Git prompt SHA
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="%{%F{$COMMON_COLORS_GIT_PROMPT_SHA}%}"
ZSH_THEME_GIT_PROMPT_SHA_AFTER="%{$reset_color%} "

# Background Jobs
common_bg_jobs() {
  bg_status="%{$fg[$COMMON_COLORS_BG_JOBS]%}%(1j.↓%j .)"
  echo -n $bg_status
}

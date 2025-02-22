# Display direnv output before instant prompt
eval "$(direnv export zsh)"

# ===================================================
# Theme
# ===================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  . "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# zsh theme
# https://github.com/romkatv/powerlevel10k#manual
. $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || . ~/.p10k.zsh

# colorize ls
export CLICOLOR=1

# man page colors
export LESS_TERMCAP_mb=$(print -P "%F{cyan}") \
    LESS_TERMCAP_md=$(print -P "%B%F{red}") \
    LESS_TERMCAP_me=$(print -P "%f%b") \
    LESS_TERMCAP_so=$(print -P "%K{magenta}") \
    LESS_TERMCAP_se=$(print -P "%K{black}") \
    LESS_TERMCAP_us=$(print -P "%U%F{green}") \
    LESS_TERMCAP_ue=$(print -P "%f%u")

export PS1="%# "

# ===================================================
# Editors
# ===================================================
export EDITOR="subl -w"
export REACT_EDITOR=code

# ===================================================
# Keyboard settings
# ===================================================

# Don't eat the space before a pipe after tab completion
ZLE_SPACE_SUFFIX_CHARS=$'&|'

# ===================================================
# Tools and tab completions
# ===================================================

autoload -U bashcompinit && bashcompinit # Enable bash complete command
autoload -U compinit && compinit -i

# Enable autocompletion for aws cli
complete -C '$(brew --prefix)/bin/aws_completer' aws

# https://iterm2.com/documentation-shell-integration.html
export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES
. ~/.iterm2_shell_integration.zsh

# Homebrew
# Give homebrew priority over /usr/bin by running here
[[ -r /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
[[ -r /usr/local/bin/brew ]] && eval "$(/usr/local/bin/brew shellenv)"

# https://github.com/nvm-sh/nvm#install--update-script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Automatically call nvm use
# https://github.com/nvm-sh/nvm#calling-nvm-use-automatically-in-a-directory-with-a-nvmrc-file
autoload -U add-zsh-hook
load-nvmrc() {
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

if [[ -r ~/.aliasrc ]]; then
  . ~/.aliasrc
fi

# https://direnv.net/docs/hook.html
eval "$(direnv hook zsh)"

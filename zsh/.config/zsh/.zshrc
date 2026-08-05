# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source external files
[[ -r "$ZDOTDIR/.zaliases" ]] && source "$ZDOTDIR/.zaliases"

# Tab completions
autoload -Uz compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
_comp_options+=(globdots)
compinit -d $XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION

# Use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# History
export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE="$HOME/.cache/zsh/history"
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt inc_append_history
setopt share_history

# Change word selection to exclude slashes
autoload -U select-word-style
select-word-style bash

# A simple, fast, minimalist Zsh plugin management function
# Script by mattmc3 from https://github.com/mattmc3/zsh_unplugged
function plugin-load {
  local plugin repo commitsha plugdir initfile initfiles=() clone_args=()
  : ${ZPLUGINDIR:=${ZDOTDIR:-~/.config/zsh}/plugins}
  for plugin in $@; do
    repo="$plugin"
    clone_args=(--quiet --depth 1 --recursive --shallow-submodules)
    commitsha=""
    if [[ "$plugin" == *'@'* ]]; then
      repo="${plugin%@*}"
      commitsha="${plugin#*@}"
      clone_args+=(--no-checkout)
    fi
    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone "${clone_args[@]}" https://github.com/$repo $plugdir
      if [[ -n "$commitsha" ]]; then
        git -C $plugdir fetch -q origin "$commitsha"
        git -C $plugdir checkout -q "$commitsha"
      fi
    fi
    if [[ ! -e $initfile ]]; then
      initfiles=($plugdir/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
      (( $#initfiles )) || { echo >&2 "No init file found '$repo'." && continue }
      ln -sf $initfiles[1] $initfile
    fi
    fpath+=$plugdir
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}

repos=(
  romkatv/powerlevel10k
  romkatv/zsh-defer
  zsh-users/zsh-autosuggestions
  zdharma-continuum/fast-syntax-highlighting
)
plugin-load $repos

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

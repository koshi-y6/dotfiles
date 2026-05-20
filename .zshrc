# ────────────────────────────────────────────────────────────────
# Powerlevel10k instant prompt — must be near the top
# ────────────────────────────────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ────────────────────────────────────────────────────────────────
# Brew prefix cache & environment variables
# ────────────────────────────────────────────────────────────────
BREW_PREFIX=${BREW_PREFIX:-$(brew --prefix)}
export ZPLUG_HOME=$BREW_PREFIX/opt/zplug

# ────────────────────────────────────────────────────────────────
# PATH settings
# ────────────────────────────────────────────────────────────────
typeset -U path
path=(
  $HOME/.cargo/bin
  "$HOME/git_lib/termpdf.py"
  $path
)

# ────────────────────────────────────────────────────────────────
# zplug init and plugins
# ────────────────────────────────────────────────────────────────
if [[ ! -f $ZPLUG_HOME/init.zsh.zwc || $ZPLUG_HOME/init.zsh -nt $ZPLUG_HOME/init.zsh.zwc ]]; then
  zcompile $ZPLUG_HOME/init.zsh
fi
source $ZPLUG_HOME/init.zsh

zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

if ! zplug check --verbose; then
  printf "Installing missing zplug plugins...\n"
  zplug install
fi

zplug load

# ────────────────────────────────────────────────────────────────
# mise (replaces pyenv, nvm, rustup)
# ────────────────────────────────────────────────────────────────
eval "$(mise activate zsh)"

# ────────────────────────────────────────────────────────────────
# Prezto (if installed)
# ────────────────────────────────────────────────────────────────
ZPREZTO_INIT="${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
if [[ -f "$ZPREZTO_INIT" ]]; then
  if [[ ! -f "$ZPREZTO_INIT.zwc" || "$ZPREZTO_INIT" -nt "$ZPREZTO_INIT.zwc" ]]; then
    zcompile "$ZPREZTO_INIT"
  fi
  source "$ZPREZTO_INIT"
fi

# ────────────────────────────────────────────────────────────────
# Powerlevel10k theme and config
# ────────────────────────────────────────────────────────────────
source "${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k/powerlevel10k.zsh-theme"

P10K_CONFIG=~/.p10k.zsh
if [[ -f "$P10K_CONFIG" ]]; then
  if [[ ! -f "$P10K_CONFIG.zwc" || "$P10K_CONFIG" -nt "$P10K_CONFIG.zwc" ]]; then
    zcompile "$P10K_CONFIG"
  fi
  source "$P10K_CONFIG"
fi

# ────────────────────────────────────────────────────────────────
# zoxide (fast cd)
# ────────────────────────────────────────────────────────────────
if [[ ! -f ${ZDOTDIR:-$HOME}/.zoxide.zsh || -z "$(command -v zoxide)" ]]; then
  zoxide init zsh > ${ZDOTDIR:-$HOME}/.zoxide.zsh
fi
source ${ZDOTDIR:-$HOME}/.zoxide.zsh

# ────────────────────────────────────────────────────────────────
# peco history search (Ctrl+R)
# ────────────────────────────────────────────────────────────────
function peco-history-selection() {
  local selected=$(fc -l -n 1 | awk '!a[$0]++' | tail -r | peco)
  if [[ -n "$selected" ]]; then
    BUFFER="$selected"
    CURSOR=$#BUFFER
    zle reset-prompt
  fi
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

# ────────────────────────────────────────────────────────────────
# Misc environment settings
# ────────────────────────────────────────────────────────────────
export DYLD_FALLBACK_LIBRARY_PATH="$BREW_PREFIX/lib:$DYLD_FALLBACK_LIBRARY_PATH"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=cyan'

# Redundant fallback (safe)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Created by `pipx` on 2025-05-22 15:39:27
export PATH="$PATH:$HOME/.local/bin"

export SERENA_HOME="$HOME/serena"
alias serena="uv run --directory \$SERENA_HOME serena"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('$HOME/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
    . "$HOME/miniforge3/etc/profile.d/conda.sh"
  else
    export PATH="$HOME/miniforge3/bin:$PATH"
  fi
fi
unset __conda_setup
# <<< conda initialize <

# alias
alias pwdc='pwd | pbcopy && pwd'

export PATH="/opt/homebrew/opt/libomp/bin:$PATH"
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

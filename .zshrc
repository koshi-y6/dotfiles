# ────────────────────────────────────────────────────────────────
# Powerlevel10k instant prompt — must be near the top
# ────────────────────────────────────────────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ────────────────────────────────────────────────────────────────
# Brew prefix cache & environment variables
# ────────────────────────────────────────────────────────────────
if (( $+commands[brew] )); then
  BREW_PREFIX=${BREW_PREFIX:-$(brew --prefix)}
  export ZPLUG_HOME="$BREW_PREFIX/opt/zplug"
fi

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
if [[ -n ${ZPLUG_HOME:-} && -r "$ZPLUG_HOME/init.zsh" ]]; then
  if [[ ! -f "$ZPLUG_HOME/init.zsh.zwc" || "$ZPLUG_HOME/init.zsh" -nt "$ZPLUG_HOME/init.zsh.zwc" ]]; then
    zcompile "$ZPLUG_HOME/init.zsh"
  fi
  source "$ZPLUG_HOME/init.zsh"

  zplug "zsh-users/zsh-autosuggestions"
  zplug "zsh-users/zsh-completions"
  zplug "zsh-users/zsh-syntax-highlighting", defer:2

  if ! zplug check --verbose; then
    printf "Installing missing zplug plugins...\n"
    zplug install
  fi

  zplug load
fi

# ────────────────────────────────────────────────────────────────
# mise (replaces pyenv, nvm, rustup)
# ────────────────────────────────────────────────────────────────
(( $+commands[mise] )) && eval "$(mise activate zsh)"

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
P10K_THEME="${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k/powerlevel10k.zsh-theme"
[[ -r "$P10K_THEME" ]] && source "$P10K_THEME"

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
if (( $+commands[zoxide] )) && [[ ! -f ${ZDOTDIR:-$HOME}/.zoxide.zsh ]]; then
  zoxide init zsh > "${ZDOTDIR:-$HOME}/.zoxide.zsh"
fi
[[ -r ${ZDOTDIR:-$HOME}/.zoxide.zsh ]] && source "${ZDOTDIR:-$HOME}/.zoxide.zsh"

# ────────────────────────────────────────────────────────────────
# direnv (per-directory environment variables)
# ────────────────────────────────────────────────────────────────
if (( $+commands[direnv] )); then
  eval "$(direnv hook zsh)"
fi

# ────────────────────────────────────────────────────────────────
# ghq repository selector
# ────────────────────────────────────────────────────────────────
function gcd() {
  local dir

  if ! command -v ghq >/dev/null 2>&1; then
    printf "gcd: ghq is not installed\n" >&2
    return 1
  fi

  if ! command -v fzf >/dev/null 2>&1; then
    printf "gcd: fzf is not installed\n" >&2
    return 1
  fi

  dir="$(
    ghq list -p |
      fzf --height=50% --layout=reverse --prompt='ghq> ' \
          --preview='git -C {} status --short --branch 2>/dev/null'
  )" || return

  [[ -n "$dir" ]] && cd "$dir"
}

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
[[ -n ${BREW_PREFIX:-} ]] && export DYLD_FALLBACK_LIBRARY_PATH="$BREW_PREFIX/lib:${DYLD_FALLBACK_LIBRARY_PATH:-}"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=cyan'

export SERENA_HOME="$HOME/serena"
alias serena="uv run --directory \$SERENA_HOME serena"

# alias
alias pwdc='pwd | pbcopy && pwd'

for brew_tool in libomp llvm openjdk; do
  [[ -n ${BREW_PREFIX:-} && -d "$BREW_PREFIX/opt/$brew_tool/bin" ]] && path=("$BREW_PREFIX/opt/$brew_tool/bin" $path)
done
# Neovim (bob)
[ -f "$HOME/.local/share/bob/env/env.sh" ] && . "$HOME/.local/share/bob/env/env.sh"

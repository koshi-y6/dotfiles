# Homebrew supports both Apple Silicon and Intel Macs.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# User-installed commands (pipx, uv tools, etc.).
export PATH="$HOME/.local/bin:$PATH"

# TeX Live is installed separately from Homebrew. Use the stable symlink when
# present instead of pinning an architecture and release year.
[[ -d /Library/TeX/texbin ]] && export PATH="/Library/TeX/texbin:$PATH"

# Keep this optional for machines where OrbStack is installed manually.
[[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh"

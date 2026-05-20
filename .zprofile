eval $(/opt/homebrew/bin/brew shellenv)
export PATH="/usr/local/texlive/2023/bin/x86_64-darwin:$PATH"                                                                                                                 
export DYLD_LIBRARY_PATH=/opt/homebrew/Cellar/glib/2.76.4/lib:/opt/homebrew/Cellar/pango/1.50.14/lib:/opt/homebrew/Cellar/harfbuzz/8.0.1/lib:/opt/homebrew/Cellar/fontconfig/2.14.2/lib:$DYLD_LIBRARY_PATH

export PATH="/opt/homebrew/opt/cocoapods:$PATH"  


# Created by `pipx` on 2025-05-22 15:39:27
export PATH="$PATH:$HOME/.local/bin"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

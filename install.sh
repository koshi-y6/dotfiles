#!/bin/bash
# install.sh - Dotfiles installation script
# This script installs and configures your dotfiles

# Color settings
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display logo
echo -e "${BLUE}"
echo '======================================'
echo '       DOTFILES INSTALLER             '
echo '======================================'
echo -e "${NC}"

# Get the root directory of dotfiles
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo -e "${YELLOW}Dotfiles directory: $DOTFILES_DIR${NC}"

# Create backup directory
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo -e "${YELLOW}Created backup directory: $BACKUP_DIR${NC}"

# Function to create symlinks
create_symlink() {
    local src="$1"
    local dst="$2"

    if [ -e "$dst" ]; then
        echo -e "${YELLOW}Backing up: $dst -> $BACKUP_DIR/$(basename "$dst")${NC}"
        mv "$dst" "$BACKUP_DIR/$(basename "$dst")"
    fi

    echo -e "${GREEN}Creating symlink: $src -> $dst${NC}"
    ln -sf "$src" "$dst"
}

# Function to clone a git repository robustly.
# - Judges installation by the presence of a sentinel FILE, not just the directory.
#   (An empty leftover directory must not be treated as "already installed".)
# - Cleans up any partial/empty directory before cloning.
# - Detects clone failures instead of silently continuing.
#
# Usage: clone_repo <name> <repo_url> <dest_dir> <sentinel_file> [extra git args...]
clone_repo() {
    local name="$1"
    local repo_url="$2"
    local dest_dir="$3"
    local sentinel="$4"
    shift 4
    local extra_args=("$@")

    if [ -f "$dest_dir/$sentinel" ]; then
        echo -e "${GREEN}${name} already installed${NC}"
        return 0
    fi

    echo -e "${YELLOW}Installing ${name}...${NC}"
    # Remove any partial/empty leftover so the clone starts clean
    rm -rf "$dest_dir"

    if git clone "${extra_args[@]}" "$repo_url" "$dest_dir"; then
        echo -e "${GREEN}${name} installed${NC}"
        return 0
    else
        echo -e "${RED}Failed to clone ${name} from ${repo_url}. Check your network and try again.${NC}"
        return 1
    fi
}

# Remove empty leftover plugin directories under a tpm plugins dir.
# tpm's install_plugins treats an existing (even empty) directory as
# "already installed" and skips cloning. Removing the empty husks lets
# tpm clone them properly. Directories with real content are left
# untouched, so no unnecessary re-download happens (no speed penalty).
#
# Usage: clean_empty_plugin_dirs <plugins_dir> [keep_name ...]
clean_empty_plugin_dirs() {
    local plugins_dir="$1"
    shift
    local keep=("$@")

    [ -d "$plugins_dir" ] || return 0

    local dir name skip k
    for dir in "$plugins_dir"/*/; do
        [ -d "$dir" ] || continue
        name="$(basename "$dir")"

        # Never touch directories we are told to keep (e.g. tpm itself)
        skip=0
        for k in "${keep[@]}"; do
            if [ "$name" = "$k" ]; then
                skip=1
                break
            fi
        done
        [ "$skip" -eq 1 ] && continue

        # Only remove if the directory has no content (ignoring . and ..)
        if [ -z "$(ls -A "$dir" 2>/dev/null)" ]; then
            echo -e "${YELLOW}Removing empty plugin dir: $name${NC}"
            rm -rf "$dir"
        fi
    done
}

# Create necessary directories
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/tmux"
mkdir -p "$HOME/.config/wezterm"
mkdir -p "$HOME/.config/mise"

# Link Zsh related files
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
create_symlink "$DOTFILES_DIR/.zshenv" "$HOME/.zshenv"
create_symlink "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
create_symlink "$DOTFILES_DIR/.zlogin" "$HOME/.zlogin"
create_symlink "$DOTFILES_DIR/.zlogout" "$HOME/.zlogout"

# Link Hammerspoon configuration
create_symlink "$DOTFILES_DIR/.config/hammerspoon" "$HOME/.hammerspoon"

# Link Tmux.conf
create_symlink "$DOTFILES_DIR/.config/tmux/.tmux.conf" "$HOME/.tmux.conf"

# Handle .tmux directory properly to avoid symlink loop
if [ -L "$DOTFILES_DIR/.config/tmux/.tmux" ]; then
    echo -e "${YELLOW}Removing existing symlink: $DOTFILES_DIR/.config/tmux/.tmux${NC}"
    rm "$DOTFILES_DIR/.config/tmux/.tmux"
fi

if [ ! -d "$DOTFILES_DIR/.config/tmux/.tmux" ]; then
    echo -e "${YELLOW}Creating .tmux directory: $DOTFILES_DIR/.config/tmux/.tmux${NC}"
    mkdir -p "$DOTFILES_DIR/.config/tmux/.tmux/plugins"
fi

create_symlink "$DOTFILES_DIR/.config/tmux/.tmux" "$HOME/.tmux"

# Link Neovim configuration
create_symlink "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"

# Link Wezterm configuration
create_symlink "$DOTFILES_DIR/term/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

# Link mise configuration
create_symlink "$DOTFILES_DIR/.config/mise/config.toml" "$HOME/.config/mise/config.toml"

# Link Brewfile
create_symlink "$DOTFILES_DIR/Brewfile" "$HOME/Brewfile"

# Install Tmux Plugin Manager
# Judge by the actual "tpm" executable, not just the directory, so an empty
# leftover directory is correctly treated as "not installed".
clone_repo "Tmux Plugin Manager" \
    "https://github.com/tmux-plugins/tpm" \
    "$DOTFILES_DIR/.config/tmux/.tmux/plugins/tpm" \
    "tpm"

# Install Homebrew
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        if [[ "$OSTYPE" == "darwin"* ]]; then
            if [[ "$(uname -m)" == "arm64" ]]; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> $HOME/.zprofile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                echo 'eval "$(/usr/local/bin/brew shellenv)"' >> $HOME/.zprofile
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi

        if command -v brew &> /dev/null; then
            echo -e "${GREEN}Homebrew installed${NC}"
        else
            echo -e "${RED}Homebrew installation failed. Check the output above.${NC}"
        fi
    else
        echo -e "${GREEN}Homebrew already installed${NC}"
    fi
}

# Setup Zsh plugins
setup_zsh_plugins() {
    # Prezto: judge by init.zsh, not the directory.
    clone_repo "Prezto" \
        "https://github.com/sorin-ionescu/prezto.git" \
        "${ZDOTDIR:-$HOME}/.zprezto" \
        "init.zsh" \
        --recursive

    # Powerlevel10k: judge by the theme file, not the directory.
    clone_repo "Powerlevel10k" \
        "https://github.com/romkatv/powerlevel10k.git" \
        "${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k" \
        "powerlevel10k.zsh-theme" \
        --depth=1

    if [ -f "$DOTFILES_DIR/.p10k.zsh" ]; then
        create_symlink "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
    fi

    if [ -f "$HOME/.zshrc" ]; then
        echo -e "${YELLOW}Compiling .zshrc...${NC}"
        zcompile "$HOME/.zshrc"
        echo -e "${GREEN}Compilation of .zshrc completed${NC}"
    fi
}

# Setup additional configurations
setup_additional_configs() {
    # Initialize Zoxide
    if command -v zoxide &> /dev/null; then
        echo -e "${YELLOW}Initializing Zoxide...${NC}"
        zoxide init zsh > "${ZDOTDIR:-$HOME}/.zoxide.zsh"
        echo -e "${GREEN}Zoxide initialized${NC}"
    fi

    # Create necessary directories
    mkdir -p "$HOME/.cache"

    # Create Cargo directory (for cargo install if needed)
    if [ ! -d "$HOME/.cargo/bin" ]; then
        echo -e "${YELLOW}Creating Cargo directory...${NC}"
        mkdir -p "$HOME/.cargo/bin"
        echo -e "${GREEN}Cargo directory created${NC}"
    fi

    # Initialize Fzf (included in Brewfile)
    if [ -f "/usr/local/opt/fzf/install" ]; then
        echo -e "${YELLOW}Initializing Fzf...${NC}"
        /usr/local/opt/fzf/install --key-bindings --completion --no-update-rc
        echo -e "${GREEN}Fzf initialized${NC}"
    elif [ -f "/opt/homebrew/opt/fzf/install" ]; then
        echo -e "${YELLOW}Initializing Fzf...${NC}"
        /opt/homebrew/opt/fzf/install --key-bindings --completion --no-update-rc
        echo -e "${GREEN}Fzf initialized${NC}"
    fi

    # Create Zathura config directory
    mkdir -p "$HOME/.config/zathura"
}

# Install runtimes via mise
install_mise_runtimes() {
    if command -v mise &> /dev/null; then
        echo -e "${YELLOW}Installing runtimes via mise...${NC}"
        mise install
        echo -e "${GREEN}mise runtimes installed${NC}"
    else
        echo -e "${RED}mise not found. Skipping runtime installation.${NC}"
    fi
}

# Main execution

# Install Homebrew
install_homebrew

# Install packages from Brewfile
echo -e "${YELLOW}Installing packages from Brewfile...${NC}"
brew bundle --file="$HOME/Brewfile"
echo -e "${GREEN}Brewfile installation completed${NC}"

# Install runtimes via mise (Brewfile already installed mise)
install_mise_runtimes

# Initialize additional settings
echo -e "${BLUE}==== Initializing additional settings ====${NC}"
setup_zsh_plugins
setup_additional_configs

# Install Tmux plugins
# 1) Clean up empty leftover plugin dirs (keep tpm). Empty husks make tpm's
#    install_plugins skip cloning, so removing them lets the real plugins
#    (resurrect, continuum, etc.) install. Non-empty dirs are left alone,
#    so already-installed plugins are NOT re-downloaded (no speed penalty).
# 2) Guard against a missing tpm so we don't crash if the clone failed earlier.
TMUX_PLUGINS_DIR="$DOTFILES_DIR/.config/tmux/.tmux/plugins"
clean_empty_plugin_dirs "$TMUX_PLUGINS_DIR" "tpm"

INSTALL_PLUGINS="$TMUX_PLUGINS_DIR/tpm/bin/install_plugins"
if [ -x "$INSTALL_PLUGINS" ]; then
    echo -e "${YELLOW}Installing Tmux plugins...${NC}"
    "$INSTALL_PLUGINS"
    echo -e "${GREEN}Tmux plugins installed${NC}"
else
    echo -e "${RED}tpm install_plugins not found. Skipping Tmux plugin installation.${NC}"
fi

echo -e "${GREEN}Installation completed!${NC}"
echo -e "${YELLOW}To apply the new settings, restart your terminal or run 'source ~/.zshrc'${NC}"

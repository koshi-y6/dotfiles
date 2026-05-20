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
if [ ! -d "$DOTFILES_DIR/.config/tmux/.tmux/plugins/tpm" ]; then
    echo -e "${YELLOW}Installing Tmux Plugin Manager...${NC}"
    git clone https://github.com/tmux-plugins/tpm "$DOTFILES_DIR/.config/tmux/.tmux/plugins/tpm"
    echo -e "${GREEN}Tmux Plugin Manager installed${NC}"
else
    echo -e "${GREEN}Tmux Plugin Manager already installed${NC}"
fi

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
        echo -e "${GREEN}Homebrew installed${NC}"
    else
        echo -e "${GREEN}Homebrew already installed${NC}"
    fi
}

# Setup Zsh plugins
setup_zsh_plugins() {
    if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
        echo -e "${YELLOW}Installing Prezto...${NC}"
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
        echo -e "${GREEN}Prezto installed${NC}"
    else
        echo -e "${GREEN}Prezto already installed${NC}"
    fi

    if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k" ]; then
        echo -e "${YELLOW}Installing Powerlevel10k...${NC}"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/external/powerlevel10k"
        echo -e "${GREEN}Powerlevel10k installed${NC}"
    else
        echo -e "${GREEN}Powerlevel10k already installed${NC}"
    fi

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
echo -e "${YELLOW}Installing Tmux plugins...${NC}"
"$DOTFILES_DIR/.config/tmux/.tmux/plugins/tpm/bin/install_plugins"
echo -e "${GREEN}Tmux plugins installed${NC}"

echo -e "${GREEN}Installation completed!${NC}"
echo -e "${YELLOW}To apply the new settings, restart your terminal or run 'source ~/.zshrc'${NC}"

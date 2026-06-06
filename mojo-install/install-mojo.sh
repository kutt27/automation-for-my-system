#!/bin/bash

set -e

TEMP_FILES=()
PROJECT_DIR=""

cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ] && [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
        echo ""
        echo "Installation failed. Cleaning up $PROJECT_DIR..."
        rm -rf "$PROJECT_DIR" && echo "Removed project: $PROJECT_DIR"
        echo "Cleanup complete."
    fi
}

trap cleanup EXIT

install_pixi() {
    echo "Installing pixi..."

    if command -v pixi &>/dev/null; then
        echo "Pixi is already installed: $(pixi --version)"
        export PATH="$HOME/.pixi/bin:$PATH"
        return 0
    fi

    # Use non-interactive installation
    if ! curl -fsSL https://pixi.sh/install.sh | bash -s -- -y; then
        echo "Failed to install pixi"
        return 1
    fi

    export PATH="$HOME/.pixi/bin:$PATH"

    if ! command -v pixi &>/dev/null; then
        echo "Warning: pixi not found in PATH, trying ~/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    fi

    echo "Pixi installed successfully: $(pixi --version)"
}

create_mojo_project() {
    echo ""
    echo "Creating Mojo project at: $PROJECT_DIR"

    mkdir -p "$(dirname "$PROJECT_DIR")"

    if ! pixi init "$PROJECT_DIR" \
        -c https://conda.modular.com/max-nightly/ \
        -c conda-forge; then
        echo "Failed to create pixi project"
        return 1
    fi

    cd "$PROJECT_DIR" || { echo "Failed to cd to $PROJECT_DIR"; return 1; }

    if ! pixi add mojo; then
        echo "Failed to add mojo dependency"
        return 1
    fi

    cat > hello.mojo << 'EOF'
def main():
    print("Hello, Mojo!")
EOF

    TEMP_DIRS_PROJECT=true
    echo "Mojo project created at: $PROJECT_DIR"
}

verify_installation() {
    echo ""
    echo "Verifying installation..."

    if ! pixi run mojo --version; then
        echo "Failed to verify Mojo installation"
        return 1
    fi

    echo ""
    echo "Testing Mojo with hello world..."
    pixi run mojo hello.mojo
    echo "Mojo verification successful!"
}

setup_shell_integration() {
    echo ""
    echo "Setting up shell integration..."

    local shellrc=""
    case "$SHELL" in
        */bash) shellrc="$HOME/.bashrc" ;;
        */zsh)  shellrc="$HOME/.zshrc" ;;
        *)      shellrc="$HOME/.profile" ;;
    esac

    local pixi_path='export PATH="$HOME/.pixi/bin:$PATH"'

    if [ ! -f "$shellrc" ]; then
        touch "$shellrc"
    fi

    if ! grep -q 'pixi/bin' "$shellrc" 2>/dev/null; then
        echo "" >> "$shellrc"
        echo "# Pixi package manager" >> "$shellrc"
        echo "$pixi_path" >> "$shellrc"
        echo "Added pixi to $shellrc"
    else
        echo "Pixi already in $shellrc"
    fi
}

main() {
    echo "========================================="
    echo "Mojo Installation Script for Arch Linux"
    echo "Using Pixi (no sudo required)"
    echo "========================================="

    export PATH="$HOME/.pixi/bin:$HOME/.local/bin:$PATH"

    echo ""
    echo "Choose an option:"
    echo "  1) Install Mojo to system"
    echo "  2) Create a Mojo project"
    echo ""
    read -p "Enter your choice [1/2]: " choice

    case "$choice" in
        1)
            install_pixi
            setup_shell_integration

            echo ""
            echo "========================================="
            echo "Installation complete!"
            echo ""
            echo "Run 'source ~/.bashrc' or restart your shell"
            echo "to add pixi to your PATH"
            echo "========================================="
            ;;
        2)
            read -p "Enter project location [default: $HOME/mojo-projects/hello-world]: " user_location
            PROJECT_DIR="${user_location:-$HOME/mojo-projects/hello-world}"

            if [ -d "$PROJECT_DIR" ]; then
                echo "Error: Directory '$PROJECT_DIR' already exists."
                echo "Please choose a different location or remove the existing directory."
                exit 1
            fi

            install_pixi
            create_mojo_project
            verify_installation
            setup_shell_integration

            echo ""
            echo "========================================="
            echo "Installation complete!"
            echo ""
            echo "Project location: $PROJECT_DIR"
            echo ""
            echo "Usage:"
            echo "  cd $PROJECT_DIR"
            echo "  pixi run mojo <file.mojo>"
            echo ""
            echo "Run 'source ~/.bashrc' or restart your shell"
            echo "to add pixi to your PATH"
            echo "========================================="
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

main "$@"

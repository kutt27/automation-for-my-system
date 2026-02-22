#!/bin/bash

set -e

TEMP_FILES=()
TEMP_DIRS=()

cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo ""
        echo "Installation failed. Cleaning up..."
        for file in "${TEMP_FILES[@]}"; do
            [ -f "$file" ] && rm -f "$file" && echo "Removed file: $file"
        done
        for dir in "${TEMP_DIRS[@]}"; do
            [ -d "$dir" ] && rm -rf "$dir" && echo "Removed directory: $dir"
        done
        if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
            rm -rf "$PROJECT_DIR" && echo "Removed project: $PROJECT_DIR"
        fi
        echo "Cleanup complete."
    fi
}

trap cleanup EXIT

install_pixi() {
    echo "Installing pixi..."
    
    if command -v pixi &>/dev/null; then
        echo "Pixi is already installed: $(pixi --version)"
        return 0
    fi
    
    local pixi_script="/tmp/pixi_install_$$.sh"
    TEMP_FILES+=("$pixi_script")
    
    if ! curl -fsSL https://pixi.sh/install.sh -o "$pixi_script"; then
        echo "Failed to download pixi installer"
        return 1
    fi
    
    chmod +x "$pixi_script"
    if ! bash "$pixi_script"; then
        echo "Failed to install pixi"
        return 1
    fi
    
    export PATH="$HOME/.pixi/bin:$PATH"
    
    if ! command -v pixi &>/dev/null; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    echo "Pixi installed successfully"
}

create_mojo_project() {
    echo ""
    echo "Creating Mojo project..."
    
    PROJECT_DIR="$HOME/mojo-projects/hello-world"
    
    mkdir -p "$HOME/mojo-projects"
    
    if [ -d "$PROJECT_DIR" ]; then
        echo "Project directory already exists, removing..."
        rm -rf "$PROJECT_DIR"
    fi
    
    if ! pixi init "$PROJECT_DIR" \
        -c https://conda.modular.com/max-nightly/ \
        -c conda-forge; then
        echo "Failed to create pixi project"
        return 1
    fi
    
    TEMP_DIRS+=("$PROJECT_DIR")
    
    cd "$PROJECT_DIR"
    
    if ! pixi add mojo; then
        echo "Failed to add mojo dependency"
        return 1
    fi
    
    cat > hello.mojo << 'EOF'
def main():
    print("Hello, Mojo!")
EOF
    
    echo "Mojo project created at: $PROJECT_DIR"
}

verify_installation() {
    echo ""
    echo "Verifying installation..."
    
    cd "$PROJECT_DIR"
    
    if pixi run mojo --version; then
        echo ""
        echo "Testing Mojo with hello world..."
        pixi run mojo hello.mojo
    else
        echo "Failed to verify Mojo installation"
        return 1
    fi
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
    
    if [ -f "$shellrc" ] && ! grep -q 'pixi/bin' "$shellrc" 2>/dev/null; then
        echo "" >> "$shellrc"
        echo "# Pixi package manager" >> "$shellrc"
        echo "$pixi_path" >> "$shellrc"
        echo "Added pixi to $shellrc"
    fi
}

main() {
    echo "========================================="
    echo "Mojo Installation Script for Arch Linux"
    echo "Using Pixi (no sudo required)"
    echo "========================================="
    
    export PATH="$HOME/.pixi/bin:$HOME/.local/bin:$PATH"
    
    install_pixi
    create_mojo_project
    verify_installation
    setup_shell_integration
    
    trap - EXIT
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
}

main "$@"

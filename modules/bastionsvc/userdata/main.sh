#!/bin/bash
ok() {
    echo -e "✅ $1"
}

info() {
    echo -e "📢 $1"
}

e() {
    echo -e "❌ $1"
}

install_tools_linux() {
    echo "Running Linux installation script..."
    ./setup/linux.sh
    echo "Linux installation script complete!"
}

install_tools_mac() {
    echo "Running macOS installation script..."
    ./setup/osx.sh
    echo "macOS installation script complete!"
}

generate_token() {
    echo "Running token generation script..."
    ./setup/op.sh
    echo "Token generation script complete!"
}

login() {
    echo "Running login helper script..."
    ./setup/login.sh
    echo "login helper script complete!"
}

secrets() {
    echo "Running secrets helper script..."
    ./setup/secrets.sh
    echo "secrets helper script complete!"
}

echo "Welcome to the tool management script."

if [ $# -ne 1 ]; then
    echo "Usage: ./main.sh <action>"
    echo "Actions: install, token, login"
    exit 1
fi

action=$1

case $action in
    install)
        if [[ $(uname) == "Linux" ]]; then
            install_tools_linux
        elif [[ $(uname) == "Darwin" ]]; then
            install_tools_mac
        else
            echo "Unsupported operating system: $(uname)"
            exit 1
        fi
        ;;
    token)
        generate_token
        ;;
    login)
        login
        secrets
        ;;
    *)
        echo "Invalid action: $action"
        echo "Actions: install, token, docker-login"
        exit 1
        ;;
esac

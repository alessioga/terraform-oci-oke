#!/bin/bash

# Tool versions
OP_VERSION="v1.11.0"
FLUXCTL_VERSION="1.24.0"
KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
HELM_VERSION="3.7.0"
TERRAFORM_VERSION="1.0.2"

ok() {
    echo -e "✅ $1"
}

info() {
    echo -e "📢 $1"
}

e() {
    echo -e "❌ $1"
}

install_1password_cli() {
    brew install --cask 1password-cli
    ok "1Password CLI installation complete!"
}

install_k9s () {
    brew install k9s 
    ok "K9s installation complete!"
}

install_fluxctl() {
    echo "Installing Fluxctl..."
    brew install fluxcd/tap/flux 2&> /dev/null
    ok "Fluxctl installation complete!"
}

install_k9s() {
    echo "Installing K9s..."
    brew install k9s 2&> /dev/null
    ok "K9s installation complete!"
}
install_kubectl() {
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/darwin/amd64/kubectl" 2&> /dev/null
    sudo install -o root -g wheel -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    ok "kubectl installation complete!"
}

install_helm() {
    echo "Installing Helm..."
    brew install helm

    ok "Helm installation complete!"
}

install_terraform() {
    echo "Installing Terraform..."
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
    ok "Terraform installation complete!"
}

install_jfrog_cli() {
    if ! command -v jfrog >/dev/null 2>&1; then
        brew install jfrog-cli
        ok "Installing JFrog CLI..."
    fi
}

install_docker() {
	echo "Installing Docker..."
	brew install --cask docker
 	open /Applications/Docker.app
	ok "Docker installation complete!"
}

echo "Starting tool installation..."

install_1password_cli
install_jfrog_cli
install_fluxctl
install_kubectl
install_helm
install_terraform
install_docker

ok "All installations complete!"

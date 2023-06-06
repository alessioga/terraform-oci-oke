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

OP_VERSION="v2.18.0"
FLUXCTL_VERSION="1.24.0"
KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
HELM_VERSION="3.7.0"
TERRAFORM_VERSION="1.0.2"

install_zsh_ohmyzsh() {
    if [[ "$p10k" == "true" ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # MacOS
            brew install zsh git
        else
            # Linux
            sudo apt -y update > /dev/null
            sudo apt install zsh git
        fi

        chsh -s $(which zsh)
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/themes/powerlevel10k
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' $HOME/.zshrc
        fi
    fi

    plugins=(
        git
        kubectl
        kubectx
        docker
        terraform
        vim
        sysadmin
        git
        git-extras
        git-flow
    )

    for plugin in "${plugins[@]}"; do
        echo "Enabling Oh My Zsh plugin: $plugin"
                omz plugin enable "$plugin"
            fi
        fi
    done
}


install_1password_cli() {
    wget -N --quiet "https://cache.agilebits.com/dist/1P/op2/pkg/$OP_VERSION/op_linux_amd64_$OP_VERSION.zip" -O "op_linux_amd64_$OP_VERSION.zip" >/dev/null
    wget -N --quiet "https://cache.agilebits.com/dist/1P/op2/pkg/$OP_VERSION/op.sig" -O "op.sig" >/dev/null
    gpg --yes --receive-keys --quiet 3FEF9748469ADBE15DA7CA80AC2D62742012EA22 2&> /dev/null
    gpg --verify --quiet op.sig "op_linux_amd64_$OP_VERSION.zip" 2&> /dev/null
    sudo unzip -qq -d /usr/local/bin -o "op_linux_amd64_$OP_VERSION.zip" >/dev/null
    sudo chmod +x /usr/local/bin/op
    rm "op_linux_amd64_$OP_VERSION.zip" op.sig
    ok "1Password CLI installation complete!"
}

install_fluxctl() {
    wget -N --quiet "https://github.com/fluxcd/flux/releases/download/$FLUXCTL_VERSION/fluxctl_$(uname -s | tr '[:upper:]' '[:lower:]')_amd64" -O fluxctl >/dev/null
    chmod +x fluxctl
    sudo mv -f fluxctl /usr/local/bin/
    ok "Fluxctl installation complete!"
}

install_k9s() {
    curl -sS https://webinstall.dev/k9s | bash
    ok "k9s installation complete!"

}

install_kubectl() {
    wget -N --quiet "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/$(uname -s | tr '[:upper:]' '[:lower:]')/amd64/kubectl" -O kubectl >/dev/null
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    ok "kubectl installation complete!"
}

install_jfrog_cli() {
    wget -qO - https://releases.jfrog.io/artifactory/jfrog-gpg-public/jfrog\_public\_gpg.key | sudo apt-key add -
    echo "deb https://releases.jfrog.io/artifactory/jfrog-debs xenial contrib" | sudo tee -a /etc/apt/sources.list
    sudo apt -y update > /dev/null
    sudo apt install -y jfrog-cli-v2 >/dev/null
    ok "JFrog CLI installation complete!"
}

install_helm() {
    curl -sSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | sudo bash -s > /dev/null
    ok "Helm installation complete!"
}

install_terraform() {
    ok "Terraform installation complete!"
}

echo "Starting tool installation..."

install_1password_cli
install_jfrog_cli
install_fluxctl
install_kubectl
install_k9s
install_helm
install_terraform

echo "All installations complete!"

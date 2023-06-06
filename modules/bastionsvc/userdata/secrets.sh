#!/bin/bash
set -e

NAMESPACE="imagepullsecret-patcher"
DOCKER_SECRET_NAME="sealed-regcred"
DOCKER_CONFIG=$(< .dockerconfigjson)
JFROG_TOKEN=$(cat .jfrogconfigtoken)
JFROG_SECRET_NAME="jfrog-credentials"
JFROG_USERNAME="devopscore-ro"

ok() {
    echo -e "✅ $1"
}

info() {
    echo -e "📢 $1"
}

e() {
    echo -e "❌ $1"
}

create_kubernetes_secret() {
    info "Creating Kubernetes secret..."
    
    ln -f -s "$HOME/.docker/config.json" ".dockerconfigjson"

    echo "$ANNOTATIONS" | kubectl create secret generic "$DOCKER_SECRET_NAME" --from-literal=".dockerconfigjson=$DOCKER_CONFIG" \
    --namespace="$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

    kubectl create secret generic "$JFROG_SECRET_NAME" \
        --from-literal="password=$JFROG_TOKEN" \
        --from-literal="username=$JFROG_USERNAME" \
        --namespace="flux-system" --dry-run=client -o yaml | kubectl apply -f -


    ok "Kubernetes secret created!"
    
    local secret_create_status=$?

    if [ $secret_create_status -eq 0 ]; then
        ok "Kubernetes secret creation successful!"
    else
        info "Failed to create Kubernetes secret. Exit code: $secret_create_status"
        exit 1
    fi
}

# main
info "Starting Kubernetes secret creation..."

create_kubernetes_secret

ok "Kubernetes secret creation complete!"

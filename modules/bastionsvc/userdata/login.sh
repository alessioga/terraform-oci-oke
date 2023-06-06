#!/bin/bash

JFROG_TOKEN=$(cat .jfrogconfigtoken)
JFROG_SECRET_NAME="jfrog-credentials"
JFROG_USERNAME="devopscore-ro"
JFROG_ACCOUNT_NAME="neom"
DOCKER_JFROG_USERNAME="devopscore"

ok() {
    echo -e "✅ $1"
}

info() {
    echo -e "📢 $1"
}

e() {
    echo -e "❌ $1"
}

get_github_token() {

    token=$(op read op://Private/github-pat/token)
    echo -n "$token" > .githubtoken
    export TF_VAR_github_token=$(cat .githubtoken)
}

jfrog_login() {
    echo "Performing JFrog login to neom.jfrog.io..."
    op read op://neos-dev-machines/jfrog-devopscore-ro/password > .jfrogconfigtoken
    if ! jfrog c show "$JFROG_ACCOUNT_NAME" >/dev/null 2>&1; then
        echo "Adding JFrog account $JFROG_ACCOUNT_NAME..."
        jf c add $JFROGACCOUNT_NAME --artifactory-url neom.jfrog.io --user $JFROG_USERNAME --access-token $JFROG_TOKEN --interactive=false > /dev/null
    fi


    ok "JFrog login complete!"
}

docker_login() {
    DOCKER_PASSWORD=$(op read op://neos-dev-machines/dockerhub/password)
    info "Performing Docker login to JFrog..."
    echo -n "$JFROG_TOKEN" | docker login neom.jfrog.io -u devopscore-ro --password-stdin 2&> /dev/null
    info "Performing Docker login to Docker..."
    echo -n "$DOCKER_PASSWORD" | docker login -u devopscoredocker --password-stdin 2&> /dev/null
    ln -f -s "$HOME/.docker/config.json" ".dockerconfigjson"
    ln -f -s "$HOME/.docker/config.json" "/tmp/.dockerconfigjson"

    ok "Docker login complete!"
}

terraform_login() {
    echo "Performing Terraform login to neom.jfrog.io..."
    export TF_CLI_CONFIG_FILE="$HOME/.terraformrc"
    echo "credentials \"neom.jfrog.io\" {
      token = \"$JFROG_TOKEN\"
    }" > "$TF_CLI_CONFIG_FILE"
    ok "Terraform login complete!"
}

op_signin() {

    accounts=$(op account list)

    if [ -z "$accounts" ]; then
        eval $(op account add --address team-neom.1password.com --signin --shorthand team-neom)
        local signin_status=$?
        if [ $signin_status -eq 0 ]; then
            ok "1Password sign-in successful!"
        else
            echo "Failed to sign in to 1Password. Exit code: $signin_status"
            exit 1
        fi
    else
        eval $(op signin --account team-neom)
    fi

}

echo "Starting login process..."
op_signin

jfrog_login
docker_login
terraform_login
get_github_token

ok "All logins complete!"

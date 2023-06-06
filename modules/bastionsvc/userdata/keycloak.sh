#!/bin/bash

function get_keycloak_password() {
  kubectl get secrets/keycloak -n keycloak -o=go-template='{{index .data "admin-password"}}' | base64 -d
}

function configure_keycloak() {
  local password="$1"
  kubectl exec -n keycloak keycloak-0 -ti -- kcadm.sh config credentials \
    --server http://localhost:8080 --user user --password $password --config /tmp/user_config --realm master
}

function create_client() {
  local client_id="$1"
  local secret="$2"
  kubectl exec -n keycloak keycloak-0 -ti -- kcadm.sh create clients -r neos --config /tmp/user_config -b \
    "{
      \"clientId\": \"$client_id\",
      \"clientAuthenticatorType\": \"client-secret\",
      \"secret\": \"$secret\",
      \"standardFlowEnabled\" : true,
      \"directAccessGrantsEnabled\" : true,
      \"redirectUris\": [\"*\"],
      \"webOrigins\": [\"*\"]
    }"
}

function create_user() {
  local username="$1"
  if kubectl exec -n keycloak keycloak-0 -ti -- kcadm.sh create users -r neos -s username=$username -s enabled=true -s emailVerified=true -o --fields id,username --config /tmp/user_config; then
    kubectl exec -n keycloak keycloak-0 -ti -- kcadm.sh set-password --username $username -p pass -r neos --config /tmp/user_config
  fi
}

function get_neosadmin_id() {
  kubectl exec -it -n keycloak keycloak-0 -- kcadm.sh get users -r neos -q username=neosadmin --config /tmp/user_config | jq '.[0].id' | xargs
}

function get_running_pod_name() {
  kubectl get pods -n core-iam -l 'app.kubernetes.io/name=core-iam' --field-selector=status.phase==Running -o jsonpath='{.items[0].metadata.name}'
}

function add_admin_to_iam_db() {
  local pod_name="$1"
  local neosadmin_id="$2"
  kubectl exec -it -n core-iam pods/$pod_name -- poetry run iam-db add_admin $neosadmin_id
}

password=$(get_keycloak_password)
configure_keycloak $password

create_client "core-iam" "wIuEVpAaAKLqFUmYEOwRGmTJsGbetqbs"
create_client "core-gateway" "SzLbyU6joZtSq0OQtInvWWm0cOqMPXeq"

for username in neosadmin neosuser producer.education producer.smartconstruction
do
  create_user $username
done

neosadmin_id=$(get_neosadmin_id)
running_pod_name=$(get_running_pod_name)

add_admin_to_iam_db $running_pod_name $neosadmin_id

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

POD_STATUS=$(kubectl -n imagepullsecret-patcher get pods -l name=imagepullsecret-patcher -o jsonpath="{.items[0].status.phase}")

if [ "$POD_STATUS" != "Running" ]; then
  while [ "$POD_STATUS" != "Pending" ]; do
    info "Waiting for pod to be in 'Pending' status, current status is '$POD_STATUS'"
    sleep 10
    POD_STATUS=$(kubectl -n imagepullsecret-patcher get pods -l name=imagepullsecret-patcher -o jsonpath="{.items[0].status.phase}")
  done
fi



ok "ImagePullSecret patcher pod is running!"

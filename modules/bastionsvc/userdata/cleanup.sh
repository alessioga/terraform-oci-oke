#!/bin/bash

kind delete cluster --name flux-e2e

rm -f terraform.tfstate

rm -f flux-e2e-config

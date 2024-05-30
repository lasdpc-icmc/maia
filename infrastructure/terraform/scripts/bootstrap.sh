#!/bin/bash
set -xe

VAULT_NUMBER_OF_KEYS_FOR_UNSEAL=3
VAULT_NUMBER_OF_KEYS=5

SLEEP_SECONDS=15
PROTOCOL=https
VAULT_PORT=8200
VAULT_0=vault-0.vault-internal

get_secret () {
    local value=$(aws secretsmanager --region ${AWS_REGION} get-secret-value --secret-id "$1" | jq --raw-output .SecretString)
    echo $value
}

# Install JQ as we use it later on

yum install -y jq wget unzip 2>&1 >/dev/null

# Give the Helm chart a chance to get started

echo "Sleeping for ${SLEEP_SECONDS} seconds"
sleep ${SLEEP_SECONDS} # Allow helm chart some time 

# Install Kubernetes cli

curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$PATH:$HOME/bin
kubectl version --short --client

until curl -k -fs -o /dev/null ${PROTOCOL}://${VAULT_0}:8200/v1/sys/init; do
    echo "Waiting for Vault to start..."
    sleep 1
done

# See if vault is initialized

init=$(curl -fs -k ${PROTOCOL}://${VAULT_0}:8200/v1/sys/init | jq -r .initialised)

echo "Is vault initialized: '${init}'"

if [ "$init" != "false" ]; then
    echo "Initializing Vault"
    SECRET_VALUE=$(kubectl exec -n vault vault-0 -- "/bin/sh" "-c" "export VAULT_SKIP_VERIFY=true && vault operator init -recovery-shares=${VAULT_NUMBER_OF_KEYS} -recovery-threshold=${VAULT_NUMBER_OF_KEYS_FOR_UNSEAL}")
    echo "storing vault init values in secrets manager"
    aws secretsmanager put-secret-value --region ${AWS_REGION} --secret-id ${VAULT_SECRET} --secret-string "${SECRET_VALUE}"
else
    echo "Vault is already initialized"
fi

sealed=$(curl -fs -k ${PROTOCOL}://${VAULT_0}:8200/v1/sys/seal-status | jq -r .sealed)

VAULT_SECRET_VALUE=$(get_secret ${VAULT_SECRET})
root_token=$(echo ${VAULT_SECRET_VALUE} | awk '{ if (match($0,/Initial Root Token: (.*)/,m)) print m[1] }' | cut -d " " -f 1)
echo $VAULT_SECRET_VALUE >> /tmp/root_token.txt

export KEY1=$(cat /tmp/root_token.txt | grep "Unseal Key 1" | awk '{print $4}')
export KEY2=$(cat /tmp/root_token.txt | grep "Unseal Key 2" | awk '{print $8}')
export KEY3=$(cat /tmp/root_token.txt | grep "Unseal Key 3" | awk '{print $12}')

# Unseal vault nodes

unseal_vault () {
   kubectl exec -n vault vault-$1 vault operator unseal $2
}

declare -a StringArray2=("0" "1" "2")
for val_2 in ${StringArray2[@]}; do

    declare -a StringArray1=("$KEY1" "$KEY2" "$KEY3")
    for val_1 in ${StringArray1[@]}; do
    unseal_vault $val_2 $val_1
    done

done

# Send root token as secret on vault namespace

echo $root_token >> /tmp/vault-root-token.pem
kubectl create secret generic vault-root-token -n vault \
 --from-file=/tmp/vault-root-token.pem \

 ## Configure SSO With Google Email

export VAULT_ADDR="https://vault-lasdpc.icmc.usp.br"
export VAULT_TOKEN=$root_token

if [ "$(vault auth list -format=json | jq -r '.["oidc/"].type')" != "oidc" ]; then

    wget https://releases.hashicorp.com/vault/1.11.1/vault_1.11.1_linux_amd64.zip
    unzip vault_1.11.1_linux_amd64.zip
    mv vault /usr/local/bin/vault
    vault version
    vault auth enable oidc

    vault policy write lasdpc-icmc-$ENV - <<EOF
    path "secret/*" {
    capabilities = ["read"]
    }
EOF

    vault write auth/oidc/config \
    oidc_discovery_url="https://accounts.google.com" \
    oidc_client_id="$CLIENT_ID" \
    oidc_client_secret="$CLIENT_SECRET" \
    default_role="lasdpc-icmc-$ENV"

    vault write auth/oidc/role/lasdpc-icmc-$ENV \
    bound_audiences="$CLIENT_ID" \
    allowed_redirect_uris="https://vault-lasdpc.icmc.usp.br/ui/vault/auth/oidc/oidc/callback" \
    allowed_redirect_uris="https://vault-lasdpc.icmc.usp.br/oidc/callback" \
    oidc_scopes="email" \
    user_claim="email" \
    policies="lasdpc-icmc-$ENV"

    vault write sys/auth/oidc/tune listing_visibility="unauth"

else
    echo "OIDC is already enabled in Vault"
fi
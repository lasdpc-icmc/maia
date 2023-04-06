#!/bin/bash -e
set -xe
# SERVICE is the name of the Vault service in Kubernetes.
# It does not have to match the actual running service, though it may help for consistency.
SERVICE=vault
SECRET_NAME=vault-server-tls
# TMPDIR is a temporary working directory.
TMPDIR=/tmp
# Sleep timer
SLEEP_TIME=30
# Name of the CSR
# Namespace
NAMESPACE=vault

# Install Kubernetes cli

echo "Install Kubernetes cli"
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.19.6/2021-01-05/bin/linux/amd64/kubectl
chmod +x "kubectl" && mv "kubectl" /usr/local/bin/
export PATH=$PATH:$HOME/bin
kubectl version --short --client

yum update -y
yum install wget -y

VERSION=$(curl --silent "https://api.github.com/repos/cloudflare/cfssl/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
VNUMBER=${VERSION#"v"}
wget https://github.com/cloudflare/cfssl/releases/download/${VERSION}/cfssl_${VNUMBER}_linux_amd64 -O cfssl
chmod +x cfssl
mv cfssl /usr/local/bin

wget https://github.com/cloudflare/cfssl/releases/download/${VERSION}/cfssljson_${VNUMBER}_linux_amd64 -O cfssljson
chmod +x cfssljson
mv cfssljson /usr/local/bin

cat <<EOF > ca-csr.json
{
  "hosts": [
    "cluster.local,vault,vault.svc.vaul-server.cluster.local,vault.vault-server.svc,localhost,127.0.0.1"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "BR",
      "L": "Sao Carlos",
      "O": "USP",
      "OU": "CA",
      "ST": "ICMC"
    }
  ]
}
EOF

cat <<EOF > ca-config.json
{
    "signing": {
      "default": {
        "expiry": "175200h"
      },
      "profiles": {
        "default": {
          "usages": ["signing", "key encipherment", "server auth", "client auth"],
          "expiry": "175200h"
        }
      }
    }
  }

EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

#generate certificate in /tmp

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -hostname="vault,vault.vault.svc.cluster.local,vault.vault.svc,localhost,127.0.0.1" \
  -profile=default \
  ca-csr.json | cfssljson -bare vault

kubectl -n ${NAMESPACE} create secret tls tls-ca \
 --cert ca.pem  \
 --key ca-key.pem

 kubectl -n ${NAMESPACE} create secret tls tls-server \
  --cert vault.pem \
  --key vault-key.pem

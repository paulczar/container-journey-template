#!/bin/bash

# fail hard and fast
set -eo pipefail

[[ $DEBUG ]] && set -x
KUBECTL_VERSION=${KUBECTL_VERSION:-$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)}
BX_VERSION=${BX_VERSION:-0.5.1}
BX_API=${BX_API:-https://api.ng.bluemix.net}

# Check for and install cf
if [[ ! -e /usr/bin/cf ]]; then
  echo "==> Installing Cloud Foundry CLI (cf)"
  wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -
  echo "deb http://packages.cloudfoundry.org/debian stable main" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list > /dev/null
  sudo apt-get -qq update
  sudo apt-get install -yqq cf-cli
  cf --version > /dev/null
fi

# check for and install bluemix
if [[ ! -e /usr/local/bin/bx ]]; then
  echo "==> Installing Bluemix CLI (bx)"
  curl "http://public.dhe.ibm.com/cloud/bluemix/cli/bluemix-cli/Bluemix_CLI_${BX_VERSION}_amd64.tar.gz" | tar zxvf -
  sudo ./Bluemix_CLI/install_bluemix_cli && rm -rf ./Bluemix_CLI
  bx --version > /dev/null
fi

if ! bx plugin repos | grep "^Bluemix\s" > /dev/null; then
  echo "==> Installing Bluemix plugin repo"
  bx plugin repo-add Bluemix https://plugins.ng.bluemix.net
fi
if ! bx plugin list | grep "^container-service\s" > /dev/null; then
  echo "==> Installing Bluemix container-service plugin"
  bx plugin install container-service -r Bluemix
fi

# check for and install kubectl
if [[ ! -e /usr/local/bin/kubectl ]]; then
  echo "==> Installing Kubenetes CLI (kubectl)"
  curl -s -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/kubectl
  kubectl --help > /dev/null
fi

if [[ -z ${SKIP_LOGIN} ]]; then
  bx login -a ${BX_API}
  bx cs init
fi

#!/usr/bin/bash
set -e
HOSTNAME=kube-96
sudo apt -y install cowsay
echo "192.168.1.96  $HOSTNAME" | sudo tee -a /etc/hosts
## need proxy
cowsay -f hellokitty.cow "Need proxy"
PROXY=http://192.168.0.1:8080
echo HTTP_PROXY=$PROXY | sudo tee -a /etc/environment
echo HTTPS_PROXY=$PROXY | sudo tee -a /etc/environment
echo http_proxy=$PROXY | sudo tee -a /etc/environment
echo https_proxy=$PROXY | sudo tee -a /etc/environment
echo NO_PROXY=$HOSTNAME,localhost,127.0.0.1,localaddress,.localdomain.com,example.com,10.244.0.0/16,10.96.0.0/12,192.168.0.0/16 | sudo tee -a /etc/environment
export HTTP_PROXY=$PROXY
export HTTPS_PROXY=$PROXY
export http_proxy=$PROXY
export https_proxy=$PROXY
export NO_PROXY=$HOSTNAME,localhost,127.0.0.1,localaddress,.localdomain.com,example.com,10.244.0.0/16,10.96.0.0/12,192.168.0.0/16
env | grep -i proxy
sudo systemctl set-environment HTTP_PROXY=$PROXY
sudo systemctl set-environment HTTPS_PROXY=$PROXY
sudo systemctl set-environment http_proxy=$PROXY
sudo systemctl set-environment https_proxy=$PROXY
sudo systemctl set-environment NO_PROXY=$HOSTNAME,localhost,127.0.0.1,localaddress,.localdomain.com,example.com,10.244.0.0/16,10.96.0.0/12,192.168.0.0/16
sudo systemctl set-environment no_proxy=$HOSTNAME,localhost,127.0.0.1,localaddress,.localdomain.com,example.com,10.244.0.0/16,10.96.0.0/12,192.168.0.0/16
sudo systemctl daemon-reload
## eo proxy conf

cowsay -f hellokitty.cow "Other configs"
echo "br_netfilter" | sudo tee -a /etc/modules
sudo modprobe br_netfilter

# install docker
cowsay -f hellokitty.cow "Install docker"
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt install -y containerd.io docker-ce-cli docker-ce
sudo rm -f /etc/containerd/config.toml

## proxy for containerd
cowsay -f hellokitty.cow "Proxy for containerd"
sudo mkdir -p /lib/systemd/system/containerd.service.d/
FILEX=/lib/systemd/system/containerd.service.d/http-proxy.conf
echo "[Service]" | sudo tee -a $FILEX
echo "Environment=\"HTTP_PROXY=http://192.168.0.1:8080\"" | sudo tee -a $FILEX
echo "Environment=\"HTTPS_PROXY=http://192.168.0.1:8080\"" | sudo tee -a $FILEX
echo "Environment=\"http_proxy=http://192.168.0.1:8080\"" | sudo tee -a $FILEX
echo "Environment=\"https_proxy=http://192.168.0.1:8080\"" | sudo tee -a $FILEX
sudo cat $FILEX
#
sudo systemctl daemon-reload
sudo service containerd restart

# install helm
cowsay -f hellokitty.cow "Install helm"
sudo apt install -y git
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# final
# sudo -E bash -c "kubeadm init"
# echo https://docs.cilium.io/en/stable/installation/k8s-install-kubeadm/

#!/bin/bash
# ==========================================================
# Kubernetes + Docker Installer for Ubuntu 24.04 / 25.04
# Author: ChatGPT (GPT-5) | Updated: Oct 2025
# ==========================================================

LOGFILE="/var/log/k8s_install_$(date +%F_%T).log"
exec > >(tee -i $LOGFILE)
exec 2>&1

echo "🚀 Starting Kubernetes + Docker installation..."
sleep 2

# ----------------------------------------------------------
# 1. Update system
# ----------------------------------------------------------
echo "🔧 Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# ----------------------------------------------------------
# 2. Install base dependencies
# ----------------------------------------------------------
echo "📦 Installing dependencies..."
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

# ----------------------------------------------------------
# 3. Install Docker Engine
# ----------------------------------------------------------
echo "🐳 Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl enable docker
sudo systemctl start docker
sudo docker run --rm hello-world && echo "✅ Docker installed successfully."

# ----------------------------------------------------------
# 4. Install Kubernetes components
# ----------------------------------------------------------
echo "⚙️ Installing Kubernetes components (kubeadm, kubelet, kubectl)..."

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | \
sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update -y
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# ----------------------------------------------------------
# 5. Disable Swap
# ----------------------------------------------------------
echo "🧠 Disabling swap (required by kubeadm)..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# ----------------------------------------------------------
# 6. Enable required kernel modules
# ----------------------------------------------------------
echo "📡 Enabling required kernel modules..."
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# ----------------------------------------------------------
# 7. (Optional) Initialize Kubernetes cluster
# ----------------------------------------------------------
read -p "🧩 Do you want to initialize a single-node Kubernetes cluster now? (y/n): " INIT

if [[ "$INIT" == "y" || "$INIT" == "Y" ]]; then
    echo "🚀 Initializing cluster with kubeadm..."
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16 | tee kubeadm_init.log

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    echo "🌐 Installing Flannel CNI..."
    kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

    kubectl taint nodes --all node-role.kubernetes.io/control-plane- --overwrite
    echo "✅ Cluster initialized successfully!"
else
    echo "ℹ️ Skipping cluster initialization. You can run 'sudo kubeadm init' later."
fi

# ----------------------------------------------------------
# 8. Final checks
# ----------------------------------------------------------
echo "🔍 Checking versions..."
docker --version
kubectl version --client
kubeadm version

echo "✅ Installation completed!"
echo "📜 Log file saved at: $LOGFILE"
echo "Use 'kubectl get nodes' to verify the cluster once initialized."

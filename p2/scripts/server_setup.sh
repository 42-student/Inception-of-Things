#!/bin/bash
set -e

# provision smargineS VM with K3s in server mode

echo "[INFO] Updating system..."
apt-get upgrade -y
apt-get install -y curl

echo "[INFO] Installing K3s in server mode..."
curl -sfL https://get.k3s.io | sh -s - server \
	--write-kubeconfig-mode 600 \
	--write-kubeconfig /home/vagrant/.kube/config \
	--write-kubeconfig-owner vagrant

echo "[INFO] K3s installation completed."

echo "[INFO] Checking K3s status..."
systemctl status k3s --no-pager || true

echo "[INFO] Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "[INFO] kubectl installation completed."

echo "[INFO] Checking Kubernetes cluster status..."
kubectl cluster-info || true

echo "[INFO] Done. You can now run 'kubectl get nodes -o wide' after SSH into the VM."


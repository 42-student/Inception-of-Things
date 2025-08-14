#!/bin/bash

# provision smargineS VM with K3s in server mode

echo "[INFO] Updating system..."
apt-get update
apt-get install -y curl

echo "[INFO] Installing K3s in server mode..."
curl -sfL https://get.k3s.io | sh -s - server \
	--write-kubeconfig-mode 600 \
	--write-kubeconfig /home/vagrant/.kube/config

echo "[INFO] Setting kubeconfig ownership..."
chown vagrant:vagrant /home/vagrant/.kube/config

echo "[INFO] K3s installation completed."

echo "[INFO] Waiting for K3s to be ready..."
for i in {1..30}; do
    if sudo systemctl is-active --quiet k3s; then
        echo "[INFO] K3s is active"
        break
    fi
    echo "[INFO] Waiting for K3s ($i/30)..."
    sleep 2
done

echo "[INFO] Checking K3s status..."
systemctl status k3s --no-pager

echo "[INFO] Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

echo "[INFO] kubectl installation completed."

echo "[INFO] Done. You can now run 'kubectl get nodes -o wide' after SSH into the VM."


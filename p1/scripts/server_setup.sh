apt-get update
apt-get install -y curl

echo "[Server] $(date --rfc-3339 s) Installing K3S..."
curl -sfL https://get.k3s.io | sh -s - server --write-kubeconfig-mode 600 --write-kubeconfig /home/vagrant/.kube/config --write-kubeconfig-owner vagrant

K3S_TOKEN=/var/lib/rancher/k3s/server/node-token
cp ${K3S_TOKEN} /vagrant

echo "[Server] $(date --rfc-3339 s) $(hostname) running..."

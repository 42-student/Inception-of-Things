# Inception-of-Things

42 Left-curved system administration project

## Setup Host VM

Within the Host Machine, we configure a Host VM (one that will run nested VMs)  

We use `libvirt` (Virtual Machine Manager) as our hypervisor.  

### Config

> Name: IoT-host  
> OS: Ubuntu Server LTS 22.04.5  
> Memory: 8192 MB  
> CPUs: 8  
> Storage: qcow2 disk (25 GB)  
> Network: User (bridge not possible in our user session)  

---

### Cloud Init

Hands-off automated setup of the Virtual Machine:  

```bash
make install
```

Login into the host VM with user: `inception` and password that you provided at the start  

Ready to roll...  

**Proceed to [P0](#p0)**  

---

### Alternative: XML import

A more manual approach.

```bash
make import
```

#### Install

- Open the machine in VMM  
- Run installation with defaults  
- After installation completes:  

    1. reboot,  
    2. login to verify setup,  
    3. make snapshot (View -> Snapshots -> +),  
    4. Run: `systemctl enable serial-getty@ttyS0.service` and authenticate with password  
    5. Run: `systemctl start serial-getty@ttyS0.service` and authenticate with password  
    6. shutdown.  

- Configure mounting our source directory inside VM:  
View -> Details -> Add Hardware -> Filesystem -> Driver: virtio-9p, Source: <this dir>, Target: iot  

#### Provision

Start VM with connection to its console:  

```bash
make connect
# OR
# virsh -c qemu:///session start IoT-host --console
```

Login using your VM credentials.  

*Note: You can use `Ctrl+[` to exit the VM console.*  

Update repositories and install core packages:  

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install qemu-guest-agent git curl ansible
```

---

## P0

#### Mount our project as external filesystem

```bash
sudo mount -t 9p -o trans=virtio,version=9p2000.L iot /mnt

# Make a copy owned by our user to avoid issues with write permissions
cp -r /mnt ~
```

#### Call ansible playbook  

```bash
cd ~/mnt/host
ansible-playbook -i hosts.ini provision_vm_host.yaml
sudo reboot now
```

---

## P1

WIP  

```bash
cd ~/mnt/p1
vagrant up
```

---

## P2

WIP

#### Set up the VM for K3s

```bash
cd ~/mnt/p2
vagrant up
```

#### SSH into the VM with K3s

```bash
vagrant ssh smargineS
```

### Instructions for app1

#### Create Deployment and Service for app1

```bash
/vagrant/scripts/manage_app1.sh apply
```

#### List the Services:

```bash
kubectl get svc
```

#### Test the Service by curling its ClusterIP from within the VM:

```bash
# replace <CLUSTER-IP> with the CLUSTER-IP for the Service you want to test
curl http://<CLUSTER-IP>:80
```

#### Delete Deployment and Service for app1

```bash
/vagrant/scripts/manage_app1.sh delete
```

---

## TODO:
- P3
- Bonus


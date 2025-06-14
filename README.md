# Inception-of-Things

42 Left-curved system administration project

## Setup Host VM

Within the Host Machine, we configure a Host VM (one that will run nested VMs)  
We use Virtual Machine Manager as our hypervisor.  

### Setup

> Name: IoT-host  
> OS: Ubuntu Server LTS 22.04.5  
> Memory: 8192 MB  
> CPUs: 10  
> Storage: qcow2 disk (25 GB)  
> Network: User (bridge not possible in user session)  

### Cloud Init

```bash
make install
```

Login into the host VM with user: inception and password provided at start  

Ready to roll...  
Proceed to [P0](#p0)  

### Alternative: XML import

A more involved approach.

```bash
make import
```

#### Install

Open the machine in VMM  
Run installation with defaults  
After installation completes:
    1. reboot,  
    2. login to verify setup,  
    3. make snapshot (View -> Snapshots -> +),  
    4. Run: `systemctl enable serial-getty@ttyS0.service` and authenticate with password  
    5. Run: `systemctl start serial-getty@ttyS0.service` and authenticate with password  
    6. shutdown.  

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

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install qemu-guest-agent git curl ansible
```

#### Mount our project as external filesystem

```bash
sudo mount -t 9p -o trans=virtio,version=9p2000.L iot /mnt
```

## P0

Call ansible playbook  

```bash
cp -r /mnt ~
cd ~/mnt/host
ansible-playbook -i hosts.ini provision_vm_host.yaml
sudo reboot now
```

## P1

WIP  

```bash
cd ~/mnt/p1
vagrant up
```

## TODO:
- P2
- P3
- Bonus

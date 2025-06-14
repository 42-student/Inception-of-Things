NAME := Inception-of-Things
AUTHORS := mcutura

HOSTNAME := iot-host

VM_NAME := IoT-host
VM_IMGDIR := ${HOME}/sgoinfre/VMs
VM_IMG := $(VM_IMGDIR)/iot.qcow2
SESSION := --connect qemu:///session

ISO_FILE := ${HOME}/sgoinfre/iso/ubuntu-22.04.5-live-server-amd64.iso
ISO_URL := https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso

CLOUDIMG_FILE := ${HOME}/sgoinfre/iso/jammy-server-cloudimg-amd64.img
CLOUDIMG_URL := https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
VM_CLOUDIMG := $(VM_IMGDIR)/iot-cloud.qcow2

# SSH_KEY := host/.ssh/iot_id

SHELL := /bin/bash

# Colors
RED := \033[31m
GRN := \033[32m
MAG := \033[35m
MAB := \033[1;35m
CYA := \033[36m
CYB := \033[1;36m
NC  := \033[0m

.PHONY: help

help:	# Show this helpful message
	@awk 'BEGIN { FS = ":.*#"; \
	printf "$(GRN)$(NAME)$(NC)\nby: $(AUTHORS)\t@$(GRN)42 Berlin$(NC)\n\n"; \
	printf "Usage:\n\t$(CYB)make $(MAG)<target>$(NC)\n" } \
	/^[A-Za-z_0-9-]+:.*?#/ { printf "$(MAB)%-16s $(CYA)%s$(NC)\n", $$1, $$2}' Makefile


##### VM xml import #####
.PHONY: connect import clean

connect:	# Connect to Host VM
	virsh $(SESSION) start $(VM_NAME) --console

import: $(VM_IMG) | $(ISO_FILE)	# Import Host VM
	virsh $(SESSION) define --file <(sed "s|ISO_PATH|$(ISO_FILE)|g;s|PROJECT_DIR_PATH|$$(pwd)|g;s|INTRA_NAME|$${USER}|g" host/iot-host.xml)

$(ISO_FILE):
	@wget -O $(ISO_FILE) $(ISO_URL)

$(VM_IMGDIR):
	@mkdir -p $(VM_IMGDIR)

$(VM_IMG): |$(VM_IMGDIR)
	qemu-img create -f qcow2 $(VM_IMG) 25G

clean:	# Remove Host VM and its storage
	-virsh $(SESSION) destroy $(VM_NAME)
	virsh $(SESSION) undefine $(VM_NAME) --snapshots-metadata --remove-all-storage


###### Cloud Init ######
.PHONY: install isofs

install: isofs $(VM_CLOUDIMG)	# Install VM from CloudImg
	virt-install $(SESSION) --name $(VM_NAME) --ram 8192 --vcpus 10 \
		--disk path=$(VM_CLOUDIMG),format=qcow2 \
		--disk path=host/seed.iso,device=cdrom \
		--filesystem $$(pwd),iot,type=mount,mode=squash \
		--os-variant ubuntu22.04 --network user --graphics none \
		--console pty,target_type=serial --import

isofs:	# Create the Cloud-Init ISO
	sed "s|<HASH>|$$(openssl passwd -6)|g" host/user-data.yaml > host/user-data
	docker run --rm -v $(PWD)/host:/data alpine sh -c \
		"apk add --no-cache cdrkit && mkisofs -output /data/seed.iso -volid cidata -joliet -rock /data/user-data /data/meta-data"
	shred -fun 42 host/user-data

$(CLOUDIMG_FILE):
	@wget -O $(CLOUDIMG_FILE) $(CLOUDIMG_URL)

$(VM_CLOUDIMG): $(CLOUDIMG_FILE) | $(VM_IMGDIR)
	qemu-img create -f qcow2 -b $(CLOUDIMG_FILE) -F qcow2 $(VM_CLOUDIMG) 25G

# $(SSH_KEY):
# 	@mkdir -p host/.ssh
# 	@ssh-keygen -t ed25519 -C "${USER}@student.42berlin.de" -f $(SSH_KEY) -N ""


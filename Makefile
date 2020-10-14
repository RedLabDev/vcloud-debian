# Default values
VCD_ORG = default

DEBIAN_MIRROR = https://cloud.debian.org
DEBIAN_RELEASE = buster
DEBIAN_VERSION = 10
DEBIAN_BUILD = 20201013-422
DEBIAN_TYPE = generic# generic nocloud genericcloud 

DISK_SIZE = 50G

# URL of source image
IMAGE_URL = $(DEBIAN_MIRROR)/images/cloud/$(DEBIAN_RELEASE)/$(DEBIAN_BUILD)/debian-$(DEBIAN_VERSION)-$(DEBIAN_TYPE)-amd64-$(DEBIAN_BUILD).qcow2

TEMPLATE_ID = debian-$(DEBIAN_VERSION)-$(DEBIAN_BUILD)
TEMPLATE_NAME = $(TEMPLATE_ID).ova

.PHONY: all upload clean
all: upload

debian.qcow2:
	wget $(IMAGE_URL) -O debian.qcow2
	qemu-img resize debian.qcow2 $(DISK_SIZE)

debian.vmdk: debian.qcow2
	qemu-img convert -f qcow2 debian.qcow2 -O vmdk debian.vmdk

converted-disk1.vmdk: debian.vmdk
	rm converted.mf converted.ovf || true
	ovftool converted.vmx converted.ovf

debian.ova: converted-disk1.vmdk
	(export VMDK_FILE="$$(grep '<File ' converted.ovf)"; \
	export VMDK_DISK="$$(grep '<Disk ' converted.ovf)"; \
	export TEMPLATE_ID="$(TEMPLATE_ID)"; \
	export DEBIAN_VERSION="$(DEBIAN_VERSION)"; \
	export DEBIAN_BUILD="$(DEBIAN_BUILD)"; \
	envsubst < debian-template.ovf > debian.ovf)
	ovftool debian.ovf debian.ova

upload: debian.ova
	rm $(TEMPLATE_NAME) || true
	ln -s debian.ova $(TEMPLATE_NAME)
	vcd catalog delete -y $(VCD_ORG) $(TEMPLATE_NAME) || true
	vcd catalog upload    $(VCD_ORG) $(TEMPLATE_NAME) || true
	rm $(TEMPLATE_NAME)

clean:
	rm debian.qcow2 debian.vmdk debian.ova debian.ovf converted.mf converted.ovf converted-disk1.vmdk *.log || true

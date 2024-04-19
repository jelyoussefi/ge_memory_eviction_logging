#----------------------------------------------------------------------------------------------------------------------
# Flags
#----------------------------------------------------------------------------------------------------------------------
SHELL:=/bin/bash

CURRENT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

#----------------------------------------------------------------------------------------------------------------------
# Targets
#----------------------------------------------------------------------------------------------------------------------
default: intel-gpu-i915
.PHONY: intel-gpu-i915 intel-gpu-cse intel-gpu-pmt intel-gpu-firmware

	
intel-gpu-cse: 
	@if [ ! -f "${CURRENT_DIR}/intel-gpu-cse/.done" ]; then \
		$(call msg,Installing intel-gpu-cse ...) && \
		rm -rf ./intel-gpu-cse && \
		git clone  https://github.com/intel-gpu/intel-gpu-cse-backports.git ./intel-gpu-cse && \
		cd ./intel-gpu-cse && git checkout 198eb67d395f554e2cdf3528de7224d23990a6ca &&  chmod 777 ./scripts/backport-mkdkms* && \
		touch ${CURRENT_DIR}/intel-gpu-cse/.done; \
	fi
	
	@$(call msg,Building intel-gpu-cse ...)
	@sudo rm -rf ~/rpmbuild/RPMS/x86_64/*.rpm /var/lib/dkms/intel-platform-cse-dkms
	@cd ${CURRENT_DIR}/intel-gpu-cse/ && \
		BUILD_VERSION=1 make -f Makefile.dkms dkmsrpm-pkg && \
		cd ~/rpmbuild/RPMS/x86_64/ && sudo zypper install -y --allow-unsigned-rpm intel-platform-cse-dkms-*.rpm

intel-gpu-pmt: 
	@if [ ! -f "${CURRENT_DIR}/intel-gpu-pmt/.done" ]; then \
		$(call msg,Installing intel-gpu-pmt ...) && \
		rm -rf ./intel-gpu-pmt && \
		git clone https://github.com/intel-gpu/intel-gpu-pmt-backports.git ./intel-gpu-pmt && \
		cd ./intel-gpu-pmt && git checkout d65b5421be1628722c53e7ff5efbd4ab87628c89 && chmod 777 ./scripts/backport-mkdkms* && \
		touch ${CURRENT_DIR}/intel-gpu-pmt/.done; \
	fi
	@sudo rm -rf ~/rpmbuild/RPMS/x86_64/*.rpm /var/lib/dkms/intel-platform-vsec-dkms
	@$(call msg,Building intel-gpu-pmt ...)
	@cd ${CURRENT_DIR}/intel-gpu-pmt/ && \
		OS_TYPE=sles OS_VERSION=15sp4 BUILD_VERSION=1 make -f Makefile.dkms dkmsrpm-pkg && \
		cd ~/rpmbuild/RPMS/x86_64/ && sudo zypper install -y --allow-unsigned-rpm intel-platform-vsec-dkms-*.rpm

intel-gpu-firmware: 
	@if [ ! -f "${CURRENT_DIR}/intel-gpu-firmware/.done" ]; then \
		$(call msg,Installing intel-gpu-firmware ...) && \
		rm -rf ./intel-gpu-firmware && \
		git clone https://github.com/intel-gpu/intel-gpu-firmware.git ./intel-gpu-firmware && \
		cd ./intel-gpu-firmware && git checkout 494603a98360711c1977171997638cca17a48a7d && \
		sudo mkdir -p /lib/firmware/updates/i915/ && \
		sudo cp ${CURRENT_DIR}/intel-gpu-firmware/firmware/*.bin /lib/firmware/updates/i915/ && \
		touch ${CURRENT_DIR}/intel-gpu-firmware/.done; \
	fi

install_prerequisites: 	intel-gpu-cse intel-gpu-pmt intel-gpu-firmware

intel-gpu-i915: 
	@if [ ! -f "${CURRENT_DIR}/intel-gpu-i915/.done" ]; then \
		$(call msg,Installing intel-gpu-i915 ...) && \
		rm -rf ./intel-gpu-i915 && \
		git clone https://github.com/intel-gpu/intel-gpu-i915-backports.git ./intel-gpu-i915 && \
		cd intel-gpu-i915 && git checkout I915_23WW21.5_627.7_23.4.15_PSB_230307.15 && \
		touch ${CURRENT_DIR}/intel-gpu-i915/.done; \
	fi
	@$(call msg,Building i915dkmsrpm-pkg ...)
	@sudo rm -rf ~/rpmbuild/RPMS/x86_64/*.rpm  /var/lib/dkms/intel-i915-dkms
	@cd ${CURRENT_DIR}/intel-gpu-i915/ && \
		make i915dkmsrpm-pkg && \
		cd ~/rpmbuild/RPMS/x86_64/ && sudo rpm -ivh --force  intel-i915-dkms*.rpm



apply_patches:  
	@$(call msg,Applying Memory Eviction patches ...)
	@cd  ${CURRENT_DIR}/intel-gpu-i915/ && git checkout .  && \
	find ${CURRENT_DIR}/patches -type f -name '*.patch' -print0 | sort -z | xargs  -0 -n 1 patch -p1 -i
	make -C ${CURRENT_DIR}  intel-gpu-i915

clean:
	@rm -rf ${CURRENT_DIR}/intel-gpu-i915
#----------------------------------------------------------------------------------------------------------------------
# helper functions
#----------------------------------------------------------------------------------------------------------------------
define msg
	tput setaf 2 && \
	for i in $(shell seq 1 120 ); do echo -n "-"; done; echo  "" && \
	echo "         "$1 && \
	for i in $(shell seq 1 120 ); do echo -n "-"; done; echo "" && \
	tput sgr0
endef


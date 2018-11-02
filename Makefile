export ANSIBLE_NOCOWS=1
ANSIBLEFLAGS=-i hosts.sample
DESTDIR=
PREFIX=/usr

-include config.mk

help: ## This help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help


.PHONY: install-fprepo
install-fprepo: ## Ansible install fprepo
	ansible-playbook $(ANSIBLEFLAGS) $@.yml

.PHONY: install
install: ## Local install fprepo
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m755 fprepo-deb $(DESTDIR)$(PREFIX)/bin/fprepo-deb
	mkdir -p $(DESTDIR)$(PREFIX)/lib/systemd/system
	sed "s:/usr/bin/fprepo:$(PREFIX)/bin/fprepo:g" <fprepo-deb@.service >fprepo-deb@.service.inst
	sed 's:/usr/bin/fprepo:$(PREFIX)/bin/fprepo:g' <fprepo-deb@.path    >fprepo-deb@.path.inst
	install -m644 fprepo-deb@.service.inst $(DESTDIR)$(PREFIX)/lib/systemd/system/fprepo-deb@.service
	install -m644 fprepo-deb@.path.inst    $(DESTDIR)$(PREFIX)/lib/systemd/system/fprepo-deb@.path
	rm -f fprepo-deb@.service.inst fprepo-deb@.path.inst


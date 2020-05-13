SHELL := bash

update:
	@true

upgrade:
	ln -nfs .dotfiles/bashrc .bashrc.site
	ln -nfs .dotfiles/gitconfig .gitconfig
	ln -nfs .dotfiles/gitignore .gitignore
	mkdir -p .ssh && chmod 700 .ssh
	echo "@cert-authority * $(shell cat .dotfiles/trusted-user-ca-keys.pem)"  >> .ssh/known_hosts
	mkdir -p .gnupg && chmod 700 .gnupg
	ln -nfs ../.dotfiles/gnupg/pubring.kbx .gnupg/pubring.kbx
	ln -nfs ../.dotfiles/gnupg/trustdb.gpg .gnupg/trustdb.gpg
	mkdir -p .aws
	if [[ -f /efs/config/aws/config ]]; then ln -nfs /efs/config/aws/config .aws/config; fi
	if [[ -f /efs/config/pass ]]; then ln -nfs /efs/config/pass /app/src/.password-store; fi
	if [[ -x "$(HOME)/bin/pass-vault-helper" ]]; then ln -nfs "$(HOME)/bin/pass-vault-helper" /usr/local/bin/pass-vault-helper; fi
	rm -f /usr/local/bin/kubectl
	rm -f .profile

install:
	@true

SHELL := bash

update:
	if [[ ! -d .vim ]]; then git clone https://github.com/imma/junas .vim; fi
	cd .vim && git pull && git submodule update --init

upgrade:
	ln -nfs .dotfiles/vimrc .vimrc
	ln -nfs .dotfiles/bashrc .bashrc.site
	ln -nfs .dotfiles/gitconfig .gitconfig
	ln -nfs .dotfiles/gitignore .gitignore
	mkdir -p .ssh && chmod 700 .ssh
	(cat .dotfiles/authorized_keys .ssh/authorized_keys 2>/dev/null | sort) > .ssh/authorized_keys.1 && rm -f .ssh/authorized_keys && mv .ssh/authorized_keys.1 .ssh/authorized_keys
	mkdir -p .gnupg && chmod 700 .gnupg
	ln -nfs ../.dotfiles/gnupg/pubring.kbx .gnupg/pubring.kbx
	ln -nfs ../.dotfiles/gnupg/trustdb.gpg .gnupg/trustdb.gpg
	mkdir -p .aws
	if [[ -f /efs/config/aws/config ]]; then ln -nfs /efs/config/aws/config .aws/config; fi
	if [[ -f /efs/config/pass ]]; then ln -nfs /efs/config/pass /app/src/.password-store; fi
	rm -f /usr/local/bin/kubectl

install:
	@true

#!/bin/bash

if [[ -x /usr/local/bin/phpx ]]; then
	echo "Already Installed!"
else
	mkdir -p /tmp/stan
	pushd /tmp/stan
	cat <<EOF >> phpx
#!/usr/bin/env php
<?php

declare (strict_types=1);

Phar::loadPhar(__DIR__ . '/phpx.phar', 'phpstan.phar');

require 'phar://phpstan.phar/bin/phpstan';
EOF
    chmod 555 phpx
    sudo mv phpx /usr/local/bin/
	wget https://github.com/phpstan/phpstan/releases/latest/download/phpstan.phar
	mv phpstan.phar phpx.phar
	chmod 555 phpx.phar
	sudo mv phpx.phar /usr/local/bin/
	popd
	rmdir /tmp/stan
fi

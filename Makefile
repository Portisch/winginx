PHP_HOST=127.0.0.1
PHP_PORT=9000

NGINX_VERSION=1.15.8
NSSM_VERSION=2.24
PHP_VERSION=7.3.1-Win32-VC15-x64
WIN_ACME_VERSION=v2.0.0-alpha1

NGINX_LINK=http://nginx.org/download/nginx-$(NGINX_VERSION).zip
NGINX_PKG=nginx-$(NGINX_VERSION)

NSSM_LINK=http://nssm.cc/download/nssm-$(NSSM_VERSION).zip
NSSM_PKG=nssm-$(NSSM_VERSION)

PHP_LINK=https://windows.php.net/downloads/releases/php-$(PHP_VERSION).zip
PHP_PKG=php-$(PHP_VERSION)

WIN_ACME_LINK=https://github.com/PKISharp/win-acme/releases/download/$(WIN_ACME_VERSION)/win-acme.$(WIN_ACME_VERSION).zip
WIN_ACME_PKG=win-acme.$(WIN_ACME_VERSION)

BIN= build/nginx-service.exe

.PHONY: clean all $(BIN)

$(BIN): deps/$(NGINX_PKG)/* deps/$(NSSM_PKG)/* deps/$(PHP_PKG)/* deps/$(WIN_ACME_PKG)/*
	@cp -r deps/$(NGINX_PKG)/* tmp/
	@cp deps/$(NSSM_PKG)/win32/nssm.exe tmp/nssm.exe
	@mkdir -p tmp/php
	@cp -r deps/$(PHP_PKG)/* tmp/php/
	@mkdir -p tmp/Letsencrypt
	@cp -r deps/$(WIN_ACME_PKG)/* tmp/Letsencrypt/
	@cp -r src/*  tmp/
	@mv tmp/conf/nginx.conf tmp/conf/nginx.conf.orig
	@cp -r add-on/* tmp/
	@cd tmp && makensis -DNGINX_VERSION=$(NGINX_VERSION) -DPHP_HOST=$(PHP_HOST) -DPHP_PORT=$(PHP_PORT) nginx.nsi
	@mv tmp/nginx-service.exe build/nginx-service.exe

deps/$(NGINX_PKG)/*: deps/$(NGINX_PKG).zip
	@test -f $@ || unzip -qo deps/$(NGINX_PKG).zip -d deps/

deps/$(NSSM_PKG)/*: deps/$(NSSM_PKG).zip
	@test -f $@ || unzip -qo deps/$(NSSM_PKG).zip -d deps/

deps/$(PHP_PKG)/*: deps/$(PHP_PKG).zip
	@test -f $@ || unzip -qo deps/$(PHP_PKG).zip -d deps/$(PHP_PKG)

deps/$(WIN_ACME_PKG)/*: deps/$(WIN_ACME_PKG).zip
	@test -f $@ || unzip -qo deps/$(WIN_ACME_PKG).zip -d deps/$(WIN_ACME_PKG) | true

deps/$(NGINX_PKG).zip:
	cd deps && wget $(NGINX_LINK)

deps/$(NSSM_PKG).zip:
	cd deps && wget $(NSSM_LINK)

deps/$(PHP_PKG).zip:
	cd deps && wget --no-check-certificate $(PHP_LINK)

deps/$(WIN_ACME_PKG).zip:
	cd deps && wget --no-check-certificate $(WIN_ACME_LINK)

clean:
	rm -rf deps/*
	rm -rf build/*
	rm -rf tmp/*

all: clean $(BIN)

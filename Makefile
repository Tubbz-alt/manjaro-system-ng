Version=16.09

PREFIX = /usr/local

SCRIPTS = \
	scripts/grub-install \
	scripts/grub-remove \
	scripts/kernel-install \
	scripts/kernel-remove \
	scripts/mhwd-config

# 	scripts/keyring-upgrade \
# 	scripts/dev-keys-upgrade \

HOOKS = \
	hooks/grub-install.hook \
	hooks/grub-remove.hook \
	hooks/kernel-install.hook \
	hooks/kernel-remove.hook \
	hooks/mhwd-config.hook

# 	hooks/keyring-upgrade.hook \
# 	hooks/dev-keys-upgrade.hook \

LIB = \
	lib/util-manjaro.sh

all: $(SCRIPTS)

edit = sed -e "s|@prefix@|${PREFIX}|"

%: %.in Makefile
	@echo "GEN $@"
	@$(RM) "$@"
	@m4 -P $@.in | $(edit) >$@
	@chmod a-w "$@"
	@chmod +x "$@"

clean:
	rm -f $(SCRIPTS)

install:
	install -dm0755 $(DESTDIR)$(PREFIX)/share/libalpm/scripts
	install -m0755 ${SCRIPTS} $(DESTDIR)$(PREFIX)/share/libalpm/scripts

	install -dm0755 $(DESTDIR)$(PREFIX)/share/libalpm/hooks
	install -m0644 ${HOOKS} $(DESTDIR)$(PREFIX)/share/libalpm/hooks

	install -dm0755 $(DESTDIR)$(PREFIX)/share/libalpm
	install -m0644 ${LIB} $(DESTDIR)$(PREFIX)/share/libalpm

uninstall:
	for f in ${SCRIPTS}; do rm -f $(DESTDIR)$(PREFIX)/share/libalpm/scripts/$$f; done
	for f in ${HOOKS}; do rm -f $(DESTDIR)$(PREFIX)/share/libalpm/hooks/$$f; done
	for f in ${LIB}; do rm -f $(DESTDIR)$(PREFIX)/share/libalpm/$$f; done

install: install

uninstall: uninstall

dist:
	git archive --format=tar --prefix=manjaro-system-ng-$(Version)/ $(Version) | gzip -9 > manjaro-system-ng-$(Version).tar.gz
	gpg --detach-sign --use-agent manjaro-system-ng-$(Version).tar.gz

.PHONY: all clean install uninstall dist

Version=17.1

PREFIX = /usr/local
SYSCONFDIR = /etc

SCRIPTS = \
	$(wildcard scripts/*.in)

SCRIPTS_BIN = \
        scripts/keyring-upgrade

HOOKS = \
	$(wildcard hooks/*.hook)

LIB = \
	$(wildcard lib/*.sh)

BASHRC = \
	$(wildcard bashrc.d/*.bashrc)

all: $(SCRIPTS_BIN)

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

	install -dm0755 $(DESTDIR)$(PREFIX)/lib/manjaro
	install -m0644 ${LIB} $(DESTDIR)$(PREFIX)/lib/manjaro

	install -dm0755 $(DESTDIR)$(SYSCONFDIR)/bash/bashrc.d
	install -m0644 ${BASHRC} $(DESTDIR)$(SYSCONFDIR)/bash/bashrc.d

uninstall:
	for f in ${SCRIPTS}; do rm -f $(DESTDIR)$(PREFIX)/share/libalpm/scripts/$$f; done
	for f in ${HOOKS}; do rm -f $(DESTDIR)$(PREFIX)/share/libalpm/hooks/$$f; done
	for f in ${LIB}; do rm -f $(DESTDIR)$(PREFIX)/lib/manjaro/$$f; done
	for f in ${BASHRC}; do rm -f $(DESTDIR)$(SYSCONFDIR)/bash/bashrc.d/$$f; done

install: install

uninstall: uninstall

dist:
	git archive --format=tar --prefix=manjaro-system-ng-$(Version)/ $(Version) | gzip -9 > manjaro-system-ng-$(Version).tar.gz
	gpg --detach-sign --use-agent manjaro-system-ng-$(Version).tar.gz

.PHONY: all clean install uninstall dist

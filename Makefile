Version=17.1

PREFIX = /usr/local
SYSCONFDIR = /etc

SCRIPTS = \
	$(wildcard scripts/*)

HOOKS = \
	$(wildcard hooks/*.hook)

# DBUSCONF= \
# 	$(wildcard data/*.conf)

LIB = \
	$(wildcard lib/*.sh)

PROFILED = \
	$(wildcard profile.d/*.sh)

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

	install -dm0755 $(DESTDIR)$(PREFIX)/lib/manjaro/bin
	install -m0644 ${LIB} $(DESTDIR)$(PREFIX)/lib/manjaro/bin

	install -dm0755 $(DESTDIR)$(SYSCONFDIR)/profile.d
	install -m0755 ${PROFILED} $(DESTDIR)$(SYSCONFDIR)/profile.d

uninstall:
	for f in ${SCRIPTS}; do rm -f $(DESTDIR)$(PREFIX)/share/libalpm/scripts/$$f; done
	for f in ${HOOKS}; do rm -f $(DESTDIR)$(PREFIX)/share/libalpm/hooks/$$f; done
	for f in ${LIB}; do rm -f $(DESTDIR)$(PREFIX)/lib/manjaro/bin/$$f; done
	for f in ${PROFILED}; do rm -f $(DESTDIR)$(SYSCONFDIR)/profile.d/$$f; done


install: install

uninstall: uninstall

dist:
	git archive --format=tar --prefix=manjaro-system-ng-$(Version)/ $(Version) | gzip -9 > manjaro-system-ng-$(Version).tar.gz
	gpg --detach-sign --use-agent manjaro-system-ng-$(Version).tar.gz

.PHONY: all clean install uninstall dist

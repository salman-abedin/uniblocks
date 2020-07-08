PREFIX = /usr/local
install:
	@mkdir -p ${DESTDIR}${PREFIX}/bin
	@for e in *.sh; do \
		cp -f $$e ${DESTDIR}${PREFIX}/bin; \
		chmod 755 ${DESTDIR}${PREFIX}/bin/$$e; \
		mv ${DESTDIR}${PREFIX}/bin/$$e ${DESTDIR}${PREFIX}/bin/$${e%.*}; \
		done
	@echo Done installing executable files to ${DESTDIR}${PREFIX}/bin
uninstall:
	@for e in *.sh;do \
		rm -f ${DESTDIR}${PREFIX}/bin/$${e%.*}; \
		done
	@echo Done removing executable files from ${DESTDIR}${PREFIX}/bin

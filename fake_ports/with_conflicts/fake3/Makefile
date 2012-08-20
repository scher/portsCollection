PORTNAME=fake3
PORTVERSION=1.0
DISTFILES=fake-1.0.tar.gz
CATEGORIES=fake_ports


WRKSRC= ${WRKDIR}/fake-1.0

do-install:
	@echo "Port: "fake3" is installing now"
	@echo "Press any key to continue:"
	@read i
	touch ${PORTSDIR}/tmp/fake3;

pre-clean:
	rm -rf ${PORTSDIR}/tmp/fake3;

.include <bsd.port.mk>

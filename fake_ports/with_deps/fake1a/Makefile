PORTNAME=fake1a
PORTVERSION=1.0
DISTFILES=fake-1.0.tar.gz
CATEGORIES=fake_ports


WRKSRC= ${WRKDIR}/fake-1.0

do-install:
	@echo "Port: "fake1a" is installing now"
	sleep 6; \
	touch ${PORTSDIR}/tmp/fake1a;
	exit 1;

pre-clean:
	rm -rf ${PORTSDIR}/tmp/fake1a;

.include <bsd.port.mk>

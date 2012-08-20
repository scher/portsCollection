PORTNAME=fake1
PORTVERSION=1.0
DISTFILES=fake-1.0.tar.gz
CATEGORIES=fake_ports


WRKSRC= ${WRKDIR}/fake-1.0

do-install:
	@echo "Port: "fake1" is installing now"
	sleep 6;
	touch ${PORTSDIR}/tmp/fake1;

pre-clean:
	rm -rf ${PORTSDIR}/tmp/fake1;

.include <bsd.port.mk>

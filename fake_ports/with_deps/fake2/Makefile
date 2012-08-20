PORTNAME=fake2
PORTVERSION=1.0
DISTFILES=fake-1.0.tar.gz
CATEGORIES=fake_ports


WRKSRC= ${WRKDIR}/fake-1.0
FETCH_DEPENDS= ${PORTSDIR}/tmp/fake1:${PORTSDIR}/fake_ports/with_deps/fake1 \
	${PORTSDIR}/tmp/fake1a:${PORTSDIR}/fake_ports/with_deps/fake1a:install

NOCLEANDEPENDS=

do-install:
	@echo "Port: "fake2" is installing now"; \
	echo "Press any key to continue"; \
	read i


.include <bsd.port.mk>

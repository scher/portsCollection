PORTNAME=fake5opt
PORTVERSION=1.0
DISTFILES=fake-1.0.tar.gz
CATEGORIES=fake_ports

WRKSRC= ${WRKDIR}/fake-1.0

OPTIONS_DEFINE= FAKE5OPT_OPT1

FAKE5OPT_OPT1_DESC= just option


.include <bsd.port.options.mk>

do-install:
	@echo "Port: "fake5opt" is installing now"
	sleep 3; \
	touch ${PORTSDIR}/tmp/fake5opt;

pre-clean:
	rm -rf ${PORTSDIR}/tmp/fake5opt;

.include <bsd.port.mk>

PORTNAME=fake5
PORTVERSION=1.0
DISTFILES=fake-1.0.tar.gz
CATEGORIES=fake_ports

WRKSRC= ${WRKDIR}/fake-1.0

OPTIONS_DEFINE= FAKE5_OPT1 FAKE5_OPT2 FAKE5_FAKE5OPT

FAKE5_FAKE5OPT_DESC = Add optional port fake5opt to BUILD_DEPENDS
FAKE5_OPT1_DESC = Enable FAKE5_OPT1 support
FAKE5_OPT2_DESC = Use FAKE5_OPT2

.include <bsd.port.options.mk>

.if ${PORT_OPTIONS:MFAKE5_FAKE5OPT}
BUILD_DEPENDS= ${PORTSDIR}/tmp/fake5opt:${PORTSDIR}/fake_ports/with_options/fake5opt
.endif

do-install:
	echo ${PORT_OPTIONS}
	@echo "Port: "fake5" is installing now"
	sleep 3;
	touch ${PORTSDIR}/tmp/fake5;

pre-clean:
	rm -rf ${PORTSDIR}/tmp/fake5;

.include <bsd.port.mk>

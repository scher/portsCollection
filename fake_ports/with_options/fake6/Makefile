PORTNAME=fake6
PORTVERSION=1.0
DISTFILES=fake-1.0.tar.gz
CATEGORIES=fake_ports

WRKSRC= ${WRKDIR}/fake-1.0
FETCH_DEPENDS= ${PORTSDIR}/tmp/fake5:${PORTSDIR}/fake_ports/with_options/fake5 \
	${PORTSDIR}/tmp/fake5a:${PORTSDIR}/fake_ports/with_options/fake5a

NOCLEANDEPENDS=

OPTIONS_MULTI=		ML_GROUP
OPTIONS_MULTI_ML_GROUP= FAKE6_OPT1 FAKE6_OPT2 FAKE6_OPT3

FAKE6_OPT1_DESC= Some options
FAKE6_OPT2_DESC= Enable this options
FAKE6_OPT3_DESC= Use FAKE5A_OPT3 option

OPTIONS_DEFAULT= FAKE6_OPT2

.include <bsd.port.options.mk>

do-install:
	@echo "Port: "fake6" is installing now"; \
	echo "Press any key to continue"; \
	read i


.include <bsd.port.mk>

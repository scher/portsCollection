PORTNAME=fake5a
PORTVERSION=1.0
DISTFILES=fake-1.0.tar.gz
CATEGORIES=fake_ports


#DISABLE_LICENSES=
#_LICENSE_STATUS= ask

WRKSRC= ${WRKDIR}/fake-1.0
FETCH_DEPENDS= ${PORTSDIR}/tmp/fake5:${PORTSDIR}/fake_ports/with_options/fake5

OPTIONS_DEFINE= FAKE5A_OPT11 FAKE5A_OPT22

OPTIONS_SINGLE=		SG_GROUP
OPTIONS_SINGLE_SG_GROUP= FAKE5A_OPT1 FAKE5A_OPT2 FAKE5A_OPT3

FAKE5A_OPT1_DESC= Some options
FAKE5A_OPT2_DESC= Enable this options
FAKE5A_OPT3_DESC= Use FAKE5A_OPT3 option

OPTIONS_DEFAULT= FAKE5A_OPT2

.include <bsd.port.options.mk>

do-install:
	@echo "Port: "fake5a" is installing now"
	sleep 3; \
	touch ${PORTSDIR}/tmp/fake5a;

pre-clean:
	rm -rf ${PORTSDIR}/tmp/fake5a;

.include <bsd.port.mk>

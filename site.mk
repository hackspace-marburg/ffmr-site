GLUON_SITE_PACKAGES := \
gluon-mesh-batman-adv-15 \
gluon-alfred \
gluon-announced \
gluon-autoupdater \
gluon-config-mode-hostname \
gluon-config-mode-autoupdater \
gluon-config-mode-mesh-vpn \
gluon-config-mode-geo-location \
gluon-config-mode-contact-info \
gluon-ebtables-filter-multicast \
gluon-ebtables-filter-ra-dhcp \
gluon-luci-admin \
gluon-luci-autoupdater \
gluon-luci-portconfig \
gluon-next-node \
gluon-mesh-vpn-fastd \
gluon-fffd-autokey \
gluon-radvd \
gluon-status-page \
iwinfo \
iptables \
haveged


DEFAULT_GLUON_RELEASE := 0.5.0+0-exp$(shell date '+%Y%m%d')

# Allow overriding the release number from the command line
GLUON_RELEASE ?= $(DEFAULT_GLUON_RELEASE)

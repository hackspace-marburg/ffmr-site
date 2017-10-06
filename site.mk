GLUON_SITE_PACKAGES := \
    gluon-mesh-batman-adv-15 \
    gluon-alfred \
    gluon-respondd \
    gluon-autoupdater \
    gluon-config-mode-autoupdater \
    gluon-config-mode-contact-info \
    gluon-config-mode-core \
    gluon-config-mode-geo-location \
    gluon-config-mode-hostname \
    gluon-config-mode-mesh-vpn \
    gluon-ebtables-filter-multicast \
    gluon-ebtables-filter-ra-dhcp \
    gluon-ffmr-yolokey-client \
    gluon-web-admin \
    gluon-web-autoupdater \
    gluon-web-network \
    gluon-web-private-wifi \
    gluon-web-wifi-config \
    gluon-web-mesh-vpn-fastd \
    gluon-mesh-vpn-fastd \
    gluon-radvd \
    gluon-setup-mode \
    gluon-status-page \
    iwinfo \
    haveged

DEFAULT_GLUON_RELEASE := snapshot-$(shell date '+%Y%m%d%H%M%S')
DEFAULT_GLUON_PRIORITY := 0

# Region code required for some images; supported values: us eu
GLUON_REGION ?= eu

# Generate images with 11s meshing for ath10k devices
GLUON_ATH10K_MESH ?= 11s

# languages to include in images
GLUON_LANGS ?= en de

# Allow overriding the release number from the command line
GLUON_RELEASE ?= $(DEFAULT_GLUON_RELEASE)
GLUON_PRIORITY ?= ${DEFAULT_GLUON_PRIORITY}

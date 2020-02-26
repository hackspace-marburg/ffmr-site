# Continue building deprecated targets
GLUON_DEPRECATED ?= full

GLUON_FEATURES := \
    alfred \
    autoupdater \
    ebtables-filter-multicast \
    ebtables-filter-ra-dhcp \
    mesh-batman-adv-15 \
    mesh-vpn-fastd \
    radvd \
    respondd \
    status-page \
    web-advanced \
    web-logging \
    web-private-wifi \
    web-wizard

GLUON_SITE_PACKAGES := \
    ffmr-yolokey-client \
    gluon-config-mode-geo-location-osm \
    haveged \
    iwinfo

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

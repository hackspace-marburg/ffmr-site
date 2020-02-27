#!/bin/bash -e
# ======================================================================
# Build script for Freifunk Marburg firmware
#
# Source: https://github.com/hackspace-marburg/ffmr-site
# Original: https://github.com/freifunk-fulda
# Contact: freifunk@hsmr.cc
# Web: https://marburg.freifunk.net
#
# Credits:
#   - Freifunk Darmstadt for your great support
#   - Freifunk Fulda for the build process and their overall hospitality
# ======================================================================

# Default make options
MAKEOPTS="-j 4 V=s"

# Default to build all Gluon targets if parameter -t is not set
TARGETS="ar71xx-generic ar71xx-nand ar71xx-tiny ath79-generic brcm2708-bcm2708 brcm2708-bcm2709 ipq40xx-generic ipq806x-generic lantiq-xrx200 lantiq-xway mpc85xx-generic mpc85xx-p1020 ramips-mt7620 ramips-mt7621 ramips-mt76x8 ramips-rt305x sunxi-cortexa7 x86-generic x86-geode x86-64"

# Default is set to use current work directory
SITEDIR="$(pwd)"

# Default build identifier set to snapshot
BUILD="snapshot"

# Specify deployment server and user
DEPLOYMENT_SERVER="firmware.marburg.freifunk.net"
DEPLOYMENT_SERVER_PORT=7331
DEPLOYMENT_USER="firmware"

# Error codes
E_ILLEGAL_ARGS=126

# Help function used in error messages and -h option
usage() {
  echo ""
  echo "Build script for Freifunk Marburg gluon firmware."
  echo ""
  echo "-b: Firmware branch name (e.g. development)"
  echo "    Default: current git branch"
  echo "-c: Build command: update | download | build | manifest | sign | upload"
  echo "-d: Enable bash debug output"
  echo "-h: Show this help"
  echo "-m: Setting for make options (optional)"
  echo "    Default: \"${MAKEOPTS}\""
  echo "-n: Build identifier (optional)"
  echo "    Default: \"${BUILD}\""
  echo "-t: Gluon targets architectures to build"
  echo "    Default: \"${TARGETS}\""
  echo "-k: Allow broken targets (optional)"
  echo "    Default: 0"
  echo "-r: Release number (optional)"
  echo "    Default: fetched from release file"
  echo "-w: Path to site directory"
  echo "    Default: current working directory"
}

# Evaluate arguments for build script.
if [[ "${#}" == 0 ]]; then
  usage
  exit ${E_ILLEGAL_ARGS}
fi

# Evaluate arguments for build script.
while getopts b:c:dhm:n:t:r:kw: flag; do
  case ${flag} in
    b)
        BRANCH="${OPTARG}"
        ;;
    c)
      case "${OPTARG}" in
        update)
          COMMAND="${OPTARG}"
          ;;
        download)
          COMMAND="${OPTARG}"
          ;;
        build)
          COMMAND="${OPTARG}"
          ;;
        manifest)
          COMMAND="${OPTARG}"
          ;;
        sign)
          COMMAND="${OPTARG}"
          ;;
        upload)
          COMMAND="${OPTARG}"
          ;;
        *)
          echo "Error: Invalid build command set."
          usage
          exit ${E_ILLEGAL_ARGS}
          ;;
      esac
      ;;
    d)
      set -x
      ;;
    h)
      usage
      exit
      ;;
    m)
      MAKEOPTS="${OPTARG}"
      ;;
    n)
      BUILD="${OPTARG}"
      ;;
    t)
      TARGETS="${OPTARG}"
      ;;
    r)
      RELEASE="${OPTARG}"
      ;;
    k)
      BROKEN=1
      ;;
    w)
      # Use the root project as site-config for make commands below
      SITEDIR="${OPTARG}"
      ;;
    *)
      usage
      exit ${E_ILLEGAL_ARGS}
      ;;
  esac
done

# Strip of all remaining arguments
shift $((OPTIND - 1));

# Check if there are remaining arguments
if [[ "${#}" > 0 ]]; then
  echo "Error: To many arguments: ${*}"
  usage
  exit ${E_ILLEGAL_ARGS}
fi

# Set branch name
if [[ -z "${BRANCH}" ]]; then
  BRANCH=$(git symbolic-ref -q HEAD)
  BRANCH=${BRANCH##refs/heads/}
  BRANCH=${BRANCH:-HEAD}
fi

# Set command
if [[ -z "${COMMAND}" ]]; then
  echo "Error: Build command missing."
  usage
  exit ${E_ILLEGAL_ARGS}
fi

# Set release number
if [[ -z "${RELEASE}" ]]; then
  RELEASE=$(cat "${SITEDIR}/release")
fi

# Normalize the branch name
BRANCH="${BRANCH#origin/}" # Use the current git branch as autoupdate branch
BRANCH="${BRANCH//\//-}"   # Replace all slashes with dashes

# Add the build identifer to the release identifier.
RELEASE="${RELEASE}-${BUILD}"

# Number of days that may pass between releasing an updating
PRIORITY=1

update() {
  make ${MAKEOPTS} \
      GLUON_BRANCH="${BRANCH}" \
      GLUON_RELEASE="${RELEASE}" \
      GLUON_PRIORITY="${PRIORITY}" \
      GLUON_SITEDIR="${SITEDIR}" \
      BROKEN="${BROKEN}" \
      update

  for TARGET in ${TARGETS}; do
    echo "--- Updating Gluon Dependencies for target: ${TARGET}"
    make ${MAKEOPTS} \
        GLUON_BRANCH="${BRANCH}" \
        GLUON_RELEASE="${RELEASE}" \
        GLUON_PRIORITY="${PRIORITY}" \
        GLUON_SITEDIR="${SITEDIR}" \
        GLUON_TARGET="${TARGET}" \
        BROKEN="${BROKEN}" \
        dirclean
  done
}

download() {
  for TARGET in ${TARGETS}; do
    echo "--- Downloading Gluon Dependencies for target: ${TARGET}"
    make ${MAKEOPTS} \
        GLUON_BRANCH="${BRANCH}" \
        GLUON_RELEASE="${RELEASE}" \
        GLUON_PRIORITY="${PRIORITY}" \
        GLUON_SITEDIR="${SITEDIR}" \
        GLUON_TARGET="${TARGET}" \
        BROKEN="${BROKEN}" \
        download
  done
}

build() {
  for TARGET in ${TARGETS}; do
    echo "--- Building Gluon Images for target: ${TARGET}"
    make ${MAKEOPTS} \
        GLUON_BRANCH="${BRANCH}" \
        GLUON_RELEASE="${RELEASE}" \
        GLUON_PRIORITY="${PRIORITY}" \
        GLUON_SITEDIR="${SITEDIR}" \
        GLUON_TARGET="${TARGET}" \
        BROKEN="${BROKEN}" \
        all
  done
}

manifest() {
  echo "--- Building Gluon Manifest: ${TARGET}"
  [[ ! -d tmp ]] && mkdir tmp
  make ${MAKEOPTS} \
      GLUON_BRANCH="${BRANCH}" \
      GLUON_RELEASE="${RELEASE}" \
      GLUON_PRIORITY="${PRIORITY}" \
      GLUON_SITEDIR="${SITEDIR}" \
      BROKEN="${BROKEN}" \
      manifest
}

sign() {
  echo "--- Signing Gluon Firmware Build"

  # Add the signature to the local manifest
  contrib/sign.sh \
      "${HOME}/autoupdate_secret_ci" \
      "output/images/sysupgrade/${BRANCH}.manifest"
}

upload() {
  echo "--- Uploading Gluon Firmware Images and Manifest"

  # Build the ssh command to use
  SSH="ssh"
  #SSH="${SSH} -i ${HOME}/.ssh/id_rsa"
  #SSH="${SSH} -o stricthostkeychecking=no"
  SSH="${SSH} -p ${DEPLOYMENT_SERVER_PORT}"

  # Determine upload target prefix
  case "${BRANCH}" in
    stable| \
    snapshot| \
    experimental)
      TARGET="${BRANCH}"
      ;;

    *)
      TARGET="others/${BRANCH}"
      ;;
  esac

  # Create the module and target directories on server
  ${SSH} \
    ${DEPLOYMENT_USER}@${DEPLOYMENT_SERVER} \
    -- \
    mkdir \
      --parents \
      --verbose \
      "modules/" \
      "firmware/${TARGET}/${RELEASE}"

  # Copy packages / modules to server
  rsync \
    --verbose \
    --recursive \
    --compress \
    --copy-links \
    --rsh="${SSH}" \
    "output/packages/" \
    "${DEPLOYMENT_USER}@${DEPLOYMENT_SERVER}:modules/"

  # Copy images to server
  rsync \
    --verbose \
    --recursive \
    --compress \
    --progress \
    --copy-links \
    --rsh="${SSH}" \
    "output/images/" \
    "${DEPLOYMENT_USER}@${DEPLOYMENT_SERVER}:firmware/${TARGET}/${RELEASE}"

  # Link latest upload in target to web
  ${SSH} \
    ${DEPLOYMENT_USER}@${DEPLOYMENT_SERVER} \
    -- \
    ln \
      --symbolic \
      --force \
      --no-target-directory \
      "${RELEASE}" \
      "firmware/${TARGET}/current"
}

(
  # Change working directory to gluon tree
  cd "${SITEDIR}/gluon"

  # Execute the selected command
  ${COMMAND}
)

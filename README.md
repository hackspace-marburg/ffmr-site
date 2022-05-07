Freifunk Marburg - Site configuration
===================================

This repo holds the site configuration for the Freifunk Marburg build of gluon.


Repository structure
--------------------

The gluon version used to build the firmware is referenced as a git submodule.
To ensure that the submodule is initialized correctly, call ```git submodule update --init``` after a checkout.


Build the firmware
------------------

The firmware can be build using the ```./build.sh``` script contained in the repository.
To do a full build use the following commands:

```
./build.sh -c update -b snapshot -n b001
./build.sh -c download -b snapshot -n b001
./build.sh -c build -b snapshot -n b001
```

Upload and sign the firmware
----------------------------

To upload the firmware to the firmware repository, you can use the following command:

```
./build.sh -c upload -b snapshot -n 001
```

To sign already uploaded images, you can use the following command:

```
./sign.sh /path/to/your/private.key snapshot
```

Jenkins
-------

Sample configuration for Jenkins:

```
echo "BUILD_DATE=$(date '+%Y%m%d%H%M%S')"

rm -fR "${WORKSPACE}/gluon/images"
./build.sh -d -b "${GIT_BRANCH}" -c update -n "${BUILD_NUMBER}-${BUILD_DATE}" -w "${WORKSPACE}" -m "V=s"
./build.sh -d -b "${GIT_BRANCH}" -c download -n "${BUILD_NUMBER}-${BUILD_DATE}" -w "${WORKSPACE}" -m "V=s"
./build.sh -d -b "${GIT_BRANCH}" -c build -n "${BUILD_NUMBER}-${BUILD_DATE}" -w "${WORKSPACE}" -m "V=s"
./build.sh -d -b "${GIT_BRANCH}" -c sign -n "${BUILD_NUMBER}-${BUILD_DATE}" -w "${WORKSPACE}" -m "V=s"
./build.sh -d -b "${GIT_BRANCH}" -c upload -n "${BUILD_NUMBER}-${BUILD_DATE}" -w "${WORKSPACE}" -m "V=s"
```

Docker
------

The *gluon* submodule ships a `Dockerfile` to be used for building firmwares.

```
docker build -t gluon-builder -f gluon/contrib/docker/Dockerfile .
docker run -it -v $PWD:/gluon gluon-builder bash
# continue at *Build the firmware*
```

FAQ
---

### Errors with `hardening-wrapper`

If an error like the following occurs, it may be due to the `hardening-wrapper`
under Arch Linux.

```
Build dependency: \nPlease reinstall the GNU C Compiler (4.8 or later) - it appears to be broken
Build dependency: Please install ncurses. (Missing libncurses.so or ncurses.h)
```

To fix this, either adjust the internal link to the `gcc` or modify your `PATH`
before the first run of `./build.sh`.

```
# Fix path
export PATH=… # your previous PATH, just without the hardening part

# Update link
unlink gluon/openwrt/staging_dir/host/bin/gcc
ln -s /usr/bin/gcc gluon/openwrt/staging_dir/host/bin/gcc
```

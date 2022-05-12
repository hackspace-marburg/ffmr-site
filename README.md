# Freifunk Marburg - Site configuration

This repo holds the site configuration for the Freifunk Marburg build of gluon.


## Repository structure

The gluon version used to build the firmware is referenced as a git submodule.
To ensure that the submodule is initialized correctly, call `git submodule update --init` after a checkout.
Otherwise, clone this repository recursive:

```
git clone https://github.com/hackspace-marburg/ffmr-site.git -b __TAG__ --recursive
```


## Build the firmware

**Please always start by taking a look at the FAQ section below, even if you have built the firmware hundred times before!**

The firmware can be build using the `./build.sh` script contained in the repository.
To do a full build use the following commands:

```
./build.sh -c update -b snapshot -n b001
./build.sh -c download -b snapshot -n b001
./build.sh -c build -b snapshot -n b001
```


## Upload and sign the firmware

Before uploading the firmware, a manifest must be generated.
If a signing key exists on the building machine, a signature can also be attached:

```
./build.sh -c manifest -b snapshot -n 001
./build.sh -c sign -b snapshot -n 001
```

To upload the firmware to the firmware repository, you can use the following command:

```
./build.sh -c upload -b snapshot -n 001
```

To sign already uploaded images, you can use the following command:

```
./sign.sh /path/to/your/private.key snapshot
```


## Docker

The *gluon* submodule ships a `Dockerfile` to be used for building firmwares.

```
docker build -t gluon-builder -f gluon/contrib/docker/Dockerfile .
docker run -it -v $PWD:/gluon gluon-builder bash
# continue at *Build the firmware*
```


## FAQ

### Gluon Version Identifiers

The generated firmware will be identified by two identifiers:
- a *release* based on the release number and the branch, e.g., 23-stable, and
- a *Gluon version* identifer, e.g., gluon-v2020.1-535-geb9504b0.

While the *release* is generated by concatenating the release - either from the `release` file or the `-r` flag - and the branch (`-b`), the *Gluon version's* origin is not so obvious.
As it turns out, `git describe` is used within the gluon submodule.
Thus, it is necessary to push the latest git tag to our Gluon fork, as the resulting version would be misleading otherwise.


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

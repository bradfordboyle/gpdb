# Building Greenplum on FreeBSD

**Caveat Lector:** This instructions have only been tested on [FreeBSD][0] running on Google Compute Enginge (GCE). It is entirely possible that this commands *will not* work for FreeBSD running on other platforms.

[0]: https://console.cloud.google.com/marketplace/details/freebsd-cloud/freebsd-11

## FreeBSD 11.1

### Initial setup

Edit `/boot/loader.conf` and reboot

```text
kern.ipc.semmni=32000
kern.ipc.semmns=1024000000
kern.ipc.semmnu=32000
```

You will need to reboot in order for the changes to take effect

Edit `/etc/hosts` to include `localhost`

```text
127.0.0.1 localhost
```


```bash
sudo pkg update
sudo pkg upgrade

# only git is required; the other packages may be useful
sudo pkg install \
    git \
    tmux \
    vim-console
```

### Building

```bash
mkdir workspace
cd workspace

git clone https://github.com/greenplum-db/gpdb.git
cd gpdb

sudo pkg install \
    bash \
    bison \
    curl \
    gmake

./configure LDFLAGS='-lexecinfo' \
    --disable-gpcloud \
    --disable-gpfdist \
    --disable-orca \
    --disable-pxf \
    --without-zstd

gmake
```

### Installing

```bash
sudo gmake install
```

### Running demo cluster

```bash
sudo pkg install \
    py27-lockfile \
    py27-psutil

cd gpAux/gpdemo
source ~/gp_home/usr/local/gpdb/greenplum_path.sh
gmake

source gpdemo-env.sh
psql -p 15432 postgres
```

### Issues

1. `configure` doesn't complain about missing curl library but then linking fails

   ```bash
   cc -Wall -Wmissing-prototypes -Wpointer-arith -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -Wno-address -Wno-unused-command-line-argument -O3 -std=gnu99  -I/usr/local/include -Werror=uninitialized -Werror=implicit-function-declaration -fPIC -DPIC -shared -o pxf.so src/pxfprotocol.o src/pxfbridge.o src/pxfuriparser.o src/libchurl.o src/pxfutils.o src/pxfheaders.o src/pxffragment.o src/gpdbwritableformatter.o src/pxffilters.o -L../../src/port -L../../src/common  -lexecinfo  -Wl,--as-needed -Wl,-R'/usr/local/gpdb/lib'   -lcurl
   /usr/bin/ld: cannot find -lcurl
   ```

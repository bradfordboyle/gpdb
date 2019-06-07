# Building Greenplum on FreeBSD

## FreeBSD 11.1

### Initial setup

```bash
sudo pkg update
sudo pkg upgrade

# only git is required
# the other packages provide a nice dev environment
sudo pkg install \
    git \
    tmux \
    vim-console \
    zsh
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
```

Issues

1. `configure` doesn't complain about missing curl library but then linking fails

   ```bash
   cc -Wall -Wmissing-prototypes -Wpointer-arith -Wendif-labels -Wmissing-format-attribute -Wformat-security -fno-strict-aliasing -fwrapv -Wno-address -Wno-unused-command-line-argument -O3 -std=gnu99  -I/usr/local/include -Werror=uninitialized -Werror=implicit-function-declaration -fPIC -DPIC -shared -o pxf.so src/pxfprotocol.o src/pxfbridge.o src/pxfuriparser.o src/libchurl.o src/pxfutils.o src/pxfheaders.o src/pxffragment.o src/gpdbwritableformatter.o src/pxffilters.o -L../../src/port -L../../src/common  -lexecinfo  -Wl,--as-needed -Wl,-R'/usr/local/gpdb/lib'   -lcurl
   /usr/bin/ld: cannot find -lcurl
   ```

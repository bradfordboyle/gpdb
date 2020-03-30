#!/usr/bin/env bash
echo "deb [trusted=yes] file:///packages ./" >> /etc/apt/sources.list

# install gpdb
apt-get update
apt-get install -y greenplum-db-6

# maybe useful
apt-get install -y sudo

# XXX: not sure if this should be in debian/control
# this is more of a container issue
apt-get install -y locales
# XXX: uncomment en_US.UTF-8 UTF-8 in /etc/locale.gen
sed -i 's/^# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

# install missing deps
# XXX: add this deps into debian/control
apt-get install -y openssh-server less net-tools

# configure gpadmin user
useradd -U -G sudo,tty -m -s /bin/bash gpadmin
echo "gpadmin:password" | chpasswd gpadmin

# setup ssh for gpadmin

su gpadmin -c 'ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa'
su gpadmin -c 'cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys'


cat > /etc/security/limits.d/gpadmin.conf <<EOF
gpadmin soft core unlimited
gpadmin soft nproc 131072
gpadmin soft nofile 65536
EOF
su gpadmin -c 'ulimit -a'

# setup sshd
mkdir /run/sshd
/usr/sbin/sshd

su gpadmin -c 'ssh-keyscan localhost 0.0.0.0 "$(hostname)" > ~/.ssh/known_hosts'

export MASTER_DATADIR='/home/gpadmin'
export DEMO_PORT_BASE='6000'
export NUM_PRIMARY_MIRROR_PAIRS='3'

# su gpadmin -c 'mkdir /home/gpadmin/datadirs/qddir'

# start demo cluster
# XXX: PYTHONPATH is missing some paths
# XXX: LD_LIBRARY_PATH is missing `x86_64-linux-gnu`
sed -i 's@^PYTHONPATH=.*@PYTHONPATH=$GPHOME/lib/python:$GPHOME/lib/x86_64-linux-gnu/python@' /usr/lib/greenplum-db/6/greenplum_path.sh
sed -i 's@^LD_LIBRARY_PATH=.*@LD_LIBRARY_PATH=$GPHOME/lib/x86_64-linux-gnu:${LD_LIBRARY_PATH-}@' /usr/lib/greenplum-db/6/greenplum_path.sh
pushd /gpdb_src/gpAux/gpdemo || exit 1
su gpadmin -c '. /usr/lib/greenplum-db/6/greenplum_path.sh; ./demo_cluster.sh -c'
su gpadmin -c '. /usr/lib/greenplum-db/6/greenplum_path.sh; ./demo_cluster.sh'
su gpadmin -c '. /usr/lib/greenplum-db/6/greenplum_path.sh; ./probe_config.sh'
popd || exit 1

#!/usr/bin/env bash
# Installs CellProfiler and CellProfiler-Analyst on Centos 7 host
# cellprofiler.org
# https://github.com/CellProfiler/CellProfiler/wiki/Source-installation-%28Linux%29
# Notes:
#  Utilises the Python vitualenv to segregate dependancies from the host and other installed software on the system.
#  Provides a mechanism to allow multiple versions of CellProfiler and CellProfiler-Analyst to co-exist on the same host.
#  wxPython was installed via the hosts package manager as it can not be added via pip, the
#  "virtualenv --system-site-packages" was added to allow this module to be made available.
#  Run:
#    $ source /usr/local/CellProfiler/CellProfiler-2.2.0/bin/activate
#    $ cd /usr/local/CellProfiler/CellProfiler-2.2.0/CellProfiler-Analyst
#    $ python CellProfiler-Analyst.py
#    $ deactivate

name='CellProfiler'
ver='2.2.0'
name_ver="${name}-${ver}"
wd="/usr/local/${name}"
prefix="${wd}/${name_ver}"

set -e

[ -d "${wd}" ] || sudo mkdir -p "${wd}"
[ -w "${wd}" ] || sudo chown -R vagrant "${wd}"

# wxPython does not contain a setup.py file so you are not able to install it with pip
#  "virtualenv --system-site-packages" switch added to allow use of wxPython module
sudo yum -y install \
  gcc-c++ \
  java-1.8.0-openjdk \
  python \
  python-pip \
  unzip \
  wxPython

sudo yum -y install \
  czmq-devel \
  java-1.8.0-openjdk-devel \
  mariadb-devel \
  python-devel

sudo pip install -U pip

sudo pip install \
  virtualenv

cd "${wd}"
[ -d ${name_ver} ] || virtualenv --system-site-packages ${name_ver}
cd "${prefix}"
source bin/activate

# CellProfiler
pip install \
  Cython \
  matplotlib \
  NumPy \
  SciPy

[ -d CellProfiler ] || git clone https://github.com/CellProfiler/CellProfiler.git
cd CellProfiler
[[ $(git symbolic-ref --short -q HEAD) == *2.2.0 ]] || git checkout -b 2.2.0 2.2.0

pip install --editable . --process-dependency-links

# CellProfiler-Analyst
cd "${prefix}"
[ -d CellProfiler-Analyst ] || git clone https://github.com/CellProfiler/CellProfiler-Analyst.git
cd CellProfiler-Analyst
[[ $(git symbolic-ref --short -q HEAD) == *2.2.0 ]] || git checkout -b 2.2.0 2.2.0

# NB: May need to add database clients for this deployment?
pip install -r requirements.txt

deactivate

if [ ! -d "${wd}/examples/cpa_example" ]; then
  cd /tmp
  [ -f cpa_2.0_example.zip ] || curl -L -O http://d1zymp9ayga15t.cloudfront.net/content/Examplezips/cpa_2.0_example.zip
  unzip cpa_2.0_example.zip -d "${wd}/examples"
fi

exit 0

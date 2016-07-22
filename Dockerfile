# Copyright (C) 2016 by Maciej Serylak
# Licensed under the Academic Free License version 3.0
# This program comes with ABSOLUTELY NO WARRANTY.
# You are free to modify and redistribute this code as long
# as you do not remove the above attribution and reasonably
# inform receipients that you have modified the original work.


FROM sdp-ingest5.kat.ac.za:5000/docker-base-gpu:latest


MAINTAINER Maciej Serylak "mserylak@ska.ac.za"


# Switch account to root
USER root


# Create space for ssh deamon and update the system
RUN mkdir /var/run/sshd && \
    apt-get -y update && \
    apt-get -y update --fix-missing && \
    apt-get -y upgrade


# Install system packages
RUN apt-get -y install \
    autoconf \
    automake \
    autotools-dev \
    bison \
    build-essential \
    cmake \
    cmake-data \
    cmake-curses-gui \
    cpp \
    csh \
    cvs \
    cython \
    dkms \
    f2c \
    fftw2 \
    fftw-dev \
    flex \
    fort77 \
    gcc \
    g++ \
    gfortran \
    ghostscript \
    ghostscript-x \
    git \
    git-core \
    gnuplot \
    gnuplot-x11 \
    gsl-bin \
    gv \
    h5utils \
    hdf5-tools \
    htop \
    hdfview \
    hwloc \
    ipython \
    ipython-notebook \
    libbison-dev \
    libboost1.55-all-dev \
    libboost1.55-dev \
    libboost1.55-tools-dev \
    libc6-dev \
    libc-dev-bin \
    libcfitsio3 \
    libcfitsio3-dev \
    libcloog-isl4 \
    libcppunit-dev \
    libcppunit-subunit0 \
    libcppunit-subunit-dev \
    libfftw3-bin \
    libfftw3-dbg \
    libfftw3-dev \
    libfftw3-double3 \
    libfftw3-long3 \
    libfftw3-quad3 \
    libfftw3-single3 \
    libgd2-xpm-dev \
    libgd3 \
    libglib2.0-dev \
    libgmp3-dev \
    libgsl0-dev \
    libgsl0ldbl \
    libhdf5-7 \
    libhdf5-dev \
    libhdf5-serial-dev \
    libhwloc-dev \
    liblapack3 \
    liblapack3gf \
    liblapack-dev \
    liblapacke \
    liblapacke-dev \
    liblapack-pic \
    liblapack-test \
    libblas3 \
    libblas3gf \
    libblas-dev \
    liblua5.1-0 \
    liblua5.2-0 \
    libltdl7 \
    libltdl-dev \
    libncurses5-dev \
    libpng12-dev \
    libpng3 \
    libpng++-dev \
    libpth-dev \
    libreadline6 \
    libreadline6-dev \
    libsocket++1 \
    libsocket++-dev \
    libtool \
    libx11-dev \
    locate \
    lsof \
    m4 \
    make \
    man \
    mc \
    nano \
    nfs-common \
    numactl \
    openssh-server \
    pbzip2 \
    pgplot5 \
    pkgconf \
    pkg-config \
    python-qt4-dev \
    pyqt4-dev-tools \
    vim \
    wget \
    screen \
    subversion \
    swig \
    swig2.0 \
    tcsh \
    tk \
    tk-dev \
    tmux


# Switch account to kat
USER kat


# Define all environmental variables
RUN wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/.mysetenv.bash && \
    source .mysetenv.bash


# Define home, psrhome, software, OSTYPE and create the directory
RUN mkdir -p /home/kat/software


# Install python modules
RUN pip install pip -U && \
    pip install setuptools -U && \
    pip install ipython -U && \
    pip install six -U && \
    pip install numpy -U && \
    pip install scipy -U && \
    pip install pandas -U && \
    pip install h5py -U && \
    pip install fitsio -U && \
    pip install astropy -U && \
    pip install astroplan -U && \
    pip install pytz -U && \
    pip install paramz -U && \
    pip install APLpy -U && \
    pip install pyfits -U && \
    pip install bitstring -U && \
    pip install cycler -U && \
    pip install peakutils -U && \
    pip install pymc -U && \
    pip install matplotlib -U && \
    pip install seaborn -U && \
    pip install lmfit -U && \
    pip install pyephem -U


# Putting symlink to libpython so PSRCHIVE configure script can find it
RUN ln -s /usr/lib/x86_64-linux-gnu/libpython2.7.so $HOME/ve/lib/python2.7/libpython2.7.so


# Downloading all source codes
WORKDIR $PSRHOME
RUN wget http://www.imcce.fr/fr/presentation/equipes/ASD/inpop/calceph/calceph-2.2.4.tar.gz && \
    tar -xvvf calceph-2.2.4.tar.gz -C $PSRHOME && \ 
    wget http://www.atnf.csiro.au/people/pulsar/psrcat/downloads/psrcat_pkg.tar.gz && \
    tar -xvf psrcat_pkg.tar.gz -C $PSRHOME && \
    wget http://ds9.si.edu/download/linux64/ds9.linux64.7.4.tar.gz && \
    mkdir $PSRHOME/ds9-7.4 && \
    tar -xvvf ds9.linux64.7.4.tar.gz -C $PSRHOME/ds9-7.4 && \
    wget http://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/fv/fv5.4_pc_linux64.tar.gz && \
    tar -xvvf fv5.4_pc_linux64.tar.gz -C $PSRHOME && \
    wget http://www.iausofa.org/2016_0503_C/sofa_c-20160503.tar.gz && \
    tar -xvvf sofa_c-20160503.tar.gz && \
    wget http://www.iausofa.org/2016_0503_F/sofa_f-20160503.tar.gz && \
    tar -xvvf sofa_f-20160503.tar.gz && \
    wget http://www.hdfgroup.org/ftp/lib-external/szip/2.1/src/szip-2.1.tar.gz && \
    tar -xvvf szip-2.1.tar.gz && \
    wget https://www.hdfgroup.org/ftp/HDF5/tools/h5check/src/h5check-2.0.1.tar.gz && \
    tar -xvvf h5check-2.0.1.tar.gz && \
    wget http://bsdforge.com/projects/source/devel/clig/clig-1.9.11.2.tar.xz && \
    tar -xvvf clig-1.9.11.2.tar.xz && \
    wget http://www.bastoul.net/cloog/pages/download/cloog-0.18.4.tar.gz && \
    tar -xvvf cloog-0.18.4.tar.gz && \
    wget http://prdownloads.sourceforge.net/ctags/ctags-5.8.tar.gz && \
    tar -xvvf ctags-5.8.tar.gz && \
    wget http://downloads.sourceforge.net/project/geographiclib/distrib/GeographicLib-1.46.tar.gz && \
    tar -xvvf GeographicLib-1.46.tar.gz && \
    wget http://www.hdfgroup.org/ftp/HDF5/projects/jpss/h5edit/h5edit-1.3.1.tar.gz && \
    tar -xvvf h5edit-1.3.1.tar.gz && \
    wget http://www.leptonica.com/source/leptonica-1.73.tar.gz && \
    tar -xvvf leptonica-1.73.tar.gz && \
    wget http://downloads.sourceforge.net/project/tvmet/Tar.Gz_Bz2%20Archive/1.7.2/tvmet-1.7.2.tar.bz2 && \
    tar -xvvf tvmet-1.7.2.tar.bz2 && \
    wget http://www.fftw.org/fftw-2.1.5.tar.gz && \
    tar -xvvf fftw-2.1.5.tar.gz && \
    wget http://heasarc.gsfc.nasa.gov/docs/software/ftools/fitsverify/fitsverify-4.18.tar.gz && \
    tar -xvvf fitsverify-4.18.tar.gz && \
    wget ftp://ftp.astron.nl/outgoing/Measures/WSRT_Measures.ztar && \
    wget https://svn.cv.nrao.edu/casa/distro/linux/release/el6/casa-release-4.6.0-el6.tar.gz && \
    tar -xvvf casa-release-4.6.0-el6.tar.gz && \
    wget http://downloads.sourceforge.net/project/wsclean/wsclean-1.12/wsclean-1.12.tar.bz2 && \
    tar -xvvf wsclean-1.12.tar.bz2 && \
    wget https://github.com/NVlabs/cub/archive/1.5.2.zip && \
    mv 1.5.2.zip cub-1.5.2.zip && \
    unzip cub-1.5.2.zip && \
    cvs -z3 -d:pserver:anonymous@tempo2.cvs.sourceforge.net:/cvsroot/tempo2 co tempo2 && \
    cvs -z3 -d:pserver:anonymous@psrdada.cvs.sourceforge.net:/cvsroot/psrdada co -P psrdada && \
    git clone git://git.code.sf.net/p/tempo/tempo && \
    git clone git://git.code.sf.net/p/psrchive/code psrchive && \
    git clone https://github.com/SixByNine/sigproc.git && \
    git clone https://github.com/ewanbarr/sigpyproc.git && \
    git clone https://github.com/nextgen-astrodata/DAL.git && \
    git clone git://git.code.sf.net/p/dspsr/code dspsr && \
    git clone https://github.com/weltevrede/psrsalsa.git && \
    git clone https://github.com/demorest/pypsrfits.git && \
    git clone https://github.com/scottransom/presto.git && \
    git clone https://github.com/scottransom/wapp2psrfits.git && \
    git clone https://github.com/scottransom/psrfits2psrfits.git && \
    git clone https://github.com/scottransom/psrfits_utils.git && \
    git clone https://github.com/scottransom/pyslalib.git && \
    git clone https://github.com/ArisKarastergiou/Vpsr.git && \
    git clone https://github.com/SheffieldML/GPy.git && \
    git clone https://katpull:katpull4git@github.com/ska-sa/katversion.git && \
    git clone https://katpull:katpull4git@github.com/ska-sa/katpoint.git && \
    git clone https://katpull:katpull4git@github.com/ska-sa/katdal.git && \
    git clone https://katpull:katpull4git@github.com/ska-sa/katconfig.git && \
    git clone https://katpull:katpull4git@github.com/ska-sa/katsdpscripts.git && \
    git clone https://katpull:katpull4git@github.com/ska-sa/katsdpinfrastructure.git && \
    git clone https://katpull:katpull4git@github.com/ska-sa/katpulse.git && \
    git clone https://github.com/casacore/casacore.git && \
    git clone https://github.com/casacore/python-casacore.git && \
    git clone https://github.com/ska-sa/makems.git && \
    git clone https://github.com/plazar/coast_guard.git


# calceph
WORKDIR $PSRHOME/calceph-2.2.4
RUN ./configure --prefix=$PSRHOME/calceph-2.2.4/install --with-pic --enable-shared --enable-static --enable-fortran --enable-thread && \
    make && \
    make check && \
    make install


# psrcat
WORKDIR $PSRHOME/psrcat_tar
RUN /bin/bash makeit


# tempo
WORKDIR $PSRHOME/tempo
RUN ./prepare && \
    ./configure --prefix=$PSRHOME/tempo && \
    make && \
    make install && \
    mv obsys.dat obsys.dat_ORIGINAL && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/obsys.dat


# tempo2
WORKDIR $PSRHOME/tempo2
RUN sync && perl -pi -e 's/chmod \+x/#chmod +x/' bootstrap # Get rid of: returned a non-zero code: 126.
RUN ./bootstrap && \
    ./configure --x-libraries=/usr/lib/x86_64-linux-gnu --with-calceph=$PSRHOME/calceph-2.2.4/install/lib --enable-shared --enable-static --with-pic F77=gfortran CPPFLAGS="-I/home/kat/software/calceph-2.2.4/install/include" && \
    make && \
    make install && \
    make plugins-install
WORKDIR $PSRHOME/tempo2/T2runtime/observatory
RUN mv observatories.dat observatories.dat_ORIGINAL && \
    mv oldcodes.dat oldcodes.dat_ORIGINAL && \
    mv aliases aliases_ORIGINAL && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/observatories.dat && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/oldcodes.dat && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/aliases


# PSRCHIVE
WORKDIR $PSRCHIVE/Base/Extensions/Pulsar
RUN mv Telescopes.h Telescopes.h_ORIGINAL && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/Telescopes.h
WORKDIR $PSRCHIVE/Base/Extensions
RUN mv Telescopes.C Telescopes.C_ORIGINAL && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/Telescopes.C
WORKDIR $PSRCHIVE/Util/tempo
RUN mv itoa.C itoa.C_ORIGINAL && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/itoa.C
WORKDIR $PSRCHIVE
RUN ./bootstrap && \
    ./configure --prefix=$PSRCHIVE/install --x-libraries=/usr/lib/x86_64-linux-gnu --enable-shared --enable-static F77=gfortran && \
    make -j $(nproc) && \
    make && \
    make install
WORKDIR /home/kat
RUN wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/.psrchive.cfg


# SOFA C-library
WORKDIR $SOFA/20160503/c/src
RUN sed -i 's|INSTALL_DIR = $(HOME)|INSTALL_DIR = $(PSRHOME)/sofa/20160503/c/install|g' makefile && \
    make && \
    make test


# SOFA FORTRAN-library
WORKDIR $SOFA/20160503/f77/src
RUN sed -i 's|INSTALL_DIR = $(HOME)|INSTALL_DIR = $(PSRHOME)/sofa/20160503/f77/install|g' makefile && \
    make && \
    make test


# SIGPROC
WORKDIR $SIGPROC/src
RUN mv aliases.c aliases.c_ORIGINAL && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/aliases.c
WORKDIR $SIGPROC
RUN ./bootstrap && \
    ./configure --prefix=$SIGPROC/install --x-libraries=/usr/lib/x86_64-linux-gnu --enable-shared LDFLAGS="-L/home/kat/software/tempo2/T2runtime/lib" LIBS="-ltempo2" && \
    make && \
    make install


# sigpyproc
WORKDIR $PSRHOME/sigpyproc
RUN python setup.py install --record list.txt


# PSRDADA
WORKDIR $PSRHOME/psrdada
RUN ./bootstrap && \
    ./configure --prefix=$PSRDADA/install --x-libraries=/usr/lib/x86_64-linux-gnu --with-sofa-lib-dir=$SOFA/20160503/c/install/lib --with-cuda-dir=/usr/local/cuda F77="gfortran" LDFLAGS="-L/usr/lib" LIBS="-lpgplot -lcpgplot -libverbs -lstdc++" CPPFLAGS="-I$PSRHOME/cub-1.5.2" && \
    make -j $(nproc) && \
    make && \
    make install


# szlib
WORKDIR $SZIP
RUN ./configure --prefix=$SZIP/install && \
    make && \
    make install


# h5check
WORKDIR $H5CHECK
RUN ./configure --prefix=$H5CHECK/install && \
    make && \
    make install


# DAL
WORKDIR $DAL
RUN mkdir build
WORKDIR $DAL/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=$DAL/install && \
    make -j $(nproc) && \
    make && \
    make install


# DSPSR
WORKDIR $DSPSR
RUN ./bootstrap && \
    echo "lump fits sigproc dada lofar_dal" > backends.list && \
    ./configure --prefix=$DSPSR/install --x-libraries=/usr/lib/x86_64-linux-gnu --with-cuda-dir=/usr/local/cuda-7.5 --with-cuda-include-dir=/usr/local/cuda-7.5/include/ --with-cuda-lib-dir=//usr/local/cuda-7.5/lib64 CPPFLAGS="-I$DAL/install/include" LDFLAGS="-L$DAL/install/lib" && \
    make -j $(nproc) && \
    make && \
    make install


# clig
WORKDIR $CLIG
RUN sed -i 's|prefix =/usr|prefix=$(CLIG)/instal|g' makefile && \
    make && \
    make install


# CLooG
WORKDIR $CLOOG
RUN ./configure --prefix=$CLOOG/install && \
    make && \
    make install


# Ctags
WORKDIR $CTAGS
RUN ./configure --prefix=$CTAGS/install && \
    make && \
    make install


# GeographicLib
WORKDIR $GEOLIB
RUN ./configure --prefix=$GEOLIB/install && \
    make && \
    make install


# h5edit
WORKDIR $H5EDIT
RUN ./configure --prefix=$H5EDIT/install CFLAGS="-Doff64_t=__off64_t" LDFLAGS="-L/usr/lib/x86_64-linux-gnu" LIBS="-lhdf5 -lhdf5_hl" && \
    make && \
    make install


# Leptonica
WORKDIR $LEPTONICA
RUN ./configure --prefix=$LEPTONICA/install && \
    make && \
    make install


# tvmet
WORKDIR $TVMET
RUN ./configure --prefix=$TVMET/install && \
    make && \
    make install


# FFTW2
WORKDIR $FFTW2
RUN ./configure --prefix=$FFTW2/install --enable-threads --enable-float && \
    make -j $(nproc) && \
    make && \
    make install


# fitsverify
WORKDIR $FITSVERIFY
RUN gcc -o fitsverify ftverify.c fvrf_data.c fvrf_file.c fvrf_head.c fvrf_key.c fvrf_misc.c -DSTANDALONE -I/usr/include -L/usr/lib/x86_64-linux-gnu -lcfitsio -lm -lnsl


# PSRSALSA
WORKDIR $PSRSALSA
RUN make


# pypsrfits
WORKDIR $PYPSRFITS
RUN python setup.py install --record list.txt


# PRESTO
WORKDIR $PRESTO/src
# RUN make makewisdom
RUN make prep && \
    make
WORKDIR $PRESTO/python/ppgplot_src
RUN mv _ppgplot.c _ppgplot.c_ORIGINAL && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/_ppgplot.c
WORKDIR $PRESTO/python
RUN make


# wapp2psrfits
WORKDIR $WAPP2PSRFITS
RUN make


# psrfits2psrfits
WORKDIR $PSRFITS2PSRFITS
RUN make


# psrfits_utils
WORKDIR $PSRFITS_UTILS
RUN sed -i 's|-Werror foreign|-Werror foreign -Wno-extra-portability|g' configure.ac && \
    ./prepare && \
    ./configure --prefix=$PSRFITS_UTILS/install && \
    make && \
    make install


# pyslalib
WORKDIR $PYSLALIB
RUN python setup.py install --record list.txt


# GPy
WORKDIR $GPY
RUN python setup.py install --record list.txt


# katversion
WORKDIR $KATVERSION
RUN python setup.py install --record list.txt


# katpoint
WORKDIR $KATPOINT
RUN python setup.py install --record list.txt


# katdal
WORKDIR $KATDAL
RUN python setup.py install --record list.txt


# katsdpscripts
WORKDIR $KATSDPSCRIPTS
RUN python setup.py install --record list.txt


# casacore measures_data
WORKDIR $PSRHOME
RUN mkdir measures_data
RUN tar -xvvf WSRT_Measures.ztar -C $MEASURES_DATA


# casacore
WORKDIR $CASACORE
RUN mkdir build
WORKDIR $CASACORE/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=$CASACORE/build/install -DCMAKE_BUILD_PYTHON=ON -DCMAKE_BUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TESTING=ON -DCMAKE_CASA_BUILD=ON -DCMAKE_CMAKE_BUILD_TYPE=Release -DCMAKE_ENABLE_SHARED=ON -DCMAKE_USE_FFTW3=ON -DCMAKE_USE_HDF5=ON -DCMAKE_USE_OPENMP=ON -DCMAKE_USE_STACKTRACE=ON -DCMAKE_USE_THREADS=ON && \
    make -j $(nproc) && \
    make && \
    make install


# python-casacore
WORKDIR $PYTHON_CASACORE
RUN python setup.py install --record list.txt


# makems
WORKDIR $MAKEMS/LOFAR
RUN mkdir -p $MAKEMS/LOFAR/build/gnu_opt
WORKDIR $MAKEMS/LOFAR/build/gnu_opt
RUN cmake -DCMAKE_MODULE_PATH:PATH=$PSRHOME/makems/LOFAR/CMake -DUSE_LOG4CPLUS=OFF -DBUILD_TESTING=OFF ../.. && \
    make && \
    make install


# wsclean
WORKDIR $WSCLEAN
RUN mkdir build
WORKDIR $WSCLEAN/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=$WSCLEAN/build/install && \
    make && \
    make install


# coast_guard
WORKDIR $COAST_GUARD
RUN mv utils.py utils.py_ORIGINAL && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/utils.py


# clean downloaded source codes
WORKDIR $PSRHOME
RUN rm -rf ./*.bz2 ./*.gz ./*.xz ./*.ztar ./*.zip

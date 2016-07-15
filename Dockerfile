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


# Create space for ssh deamon
RUN mkdir /var/run/sshd


# Update system
RUN apt-get -y update && apt-get -y upgrade


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
    libgeographiclib9 \
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
    python-dev \
    python-h5py \
    python-matplotlib \
    python-nose \
    python-numpy \
    python-pandas \
    python \
    python-pip \
    python-qt4-dev \
    pyqt4-dev-tools \
    vim \
    wget \
    python-dev \
    python-scipy \
    python-sympy \
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


# Install python modules
RUN pip install pip -U && \
    pip install setuptools -U && \
    pip install ipython -U && \
    pip install six -U && \
    pip install h5py -U && \
    pip install numpy -U && \
    pip install fitsio -U && \
    pip install astropy -U && \
    pip install scipy -U && \
    pip install astroplan -U && \
    pip install APLpy -U && \
    pip install GPy -U && \
    pip install pyfits -U && \
    pip install bitstring -U && \
    pip install cycler -U && \
    pip install peakutils -U && \
    pip install pymc -U && \
    pip install seaborn -U && \
    pip install lmfit -U && \
    pip install pyephem -U


RUN mkdir -p /home/kat/software #&& \


# Define home
ENV HOME /home/kat


# Path to the pulsar software installation directory
ENV PSRHOME /home/kat/software


# Python packages
ENV PYTHONPATH $PYTHONPATH:$HOME/ve/lib/python2.7/site-packages
ENV PYTHONPATH $PYTHONPATH:/usr/lib/python2.7/dist-packages


# Putting symlink to libpython so PSRCHIVE configure script can find it
RUN ln -s /usr/lib/x86_64-linux-gnu/libpython2.7.so $HOME/ve/lib/python2.7/libpython2.7.so


# Set up OSTYPE
ENV OSTYPE linux


# PGPLOT
ENV PGPLOT_DIR /usr/lib/pgplot5
ENV PGPLOT_FONT /usr/lib/pgplot5/grfont.dat
ENV PGPLOT_INCLUDES /usr/include
ENV PGPLOT_BACKGROUND white
ENV PGPLOT_FOREGROUND black
ENV PGPLOT_DEV /xs


# calceph
ENV PATH $PATH:$PSRHOME/calceph-2.2.4/install/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRHOME/calceph-2.2.4/install/lib
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRHOME/calceph-2.2.4/install/include
WORKDIR $PSRHOME
RUN wget http://www.imcce.fr/fr/presentation/equipes/ASD/inpop/calceph/calceph-2.2.4.tar.gz && \
    tar -xvf calceph-2.2.4.tar.gz -C $PSRHOME
WORKDIR $PSRHOME/calceph-2.2.4
RUN ./configure --prefix=$PSRHOME/calceph-2.2.4/install --with-pic --enable-shared --enable-static --enable-fortran --enable-thread && \
    make && \
    make check && \
    make install


# ds9
ENV PATH $PATH:$PSRHOME/ds9-7.4
WORKDIR $PSRHOME
RUN wget http://ds9.si.edu/download/linux64/ds9.linux64.7.4.tar.gz && \
    mkdir $PSRHOME/ds9-7.4 && \
    tar -xvf ds9.linux64.7.4.tar.gz -C $PSRHOME/ds9-7.4


# fv
ENV PATH $PATH:$PSRHOME/fv5.4
WORKDIR $PSRHOME
RUN wget http://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/fv/fv5.4_pc_linux64.tar.gz && \
    tar -xvf fv5.4_pc_linux64.tar.gz -C $PSRHOME


# psrcat
ENV PSRCAT_FILE $PSRHOME/psrcat_tar/psrcat.db
ENV PATH $PATH:$PSRHOME/psrcat_tar
WORKDIR $PSRHOME
RUN wget http://www.atnf.csiro.au/people/pulsar/psrcat/downloads/psrcat_pkg.tar.gz && \
    tar -xvf psrcat_pkg.tar.gz -C $PSRHOME
WORKDIR $PSRHOME/psrcat_tar
RUN /bin/bash makeit


# tempo
ENV TEMPO $PSRHOME/tempo
ENV PATH $PATH:$PSRHOME/tempo/bin
WORKDIR $PSRHOME
RUN git clone git://git.code.sf.net/p/tempo/tempo
WORKDIR $PSRHOME/tempo
RUN ./prepare && \
    ./configure --prefix=$PSRHOME/tempo && \
    make && \
    make install && \
    mv obsys.dat obsys.dat_ORIGINAL && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/obsys.dat


# tempo2
ENV TEMPO2 $PSRHOME/tempo2/T2runtime
ENV PATH $PATH:$PSRHOME/tempo2/T2runtime/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRHOME/tempo2/T2runtime/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRHOME/tempo2/T2runtime/lib
WORKDIR $PSRHOME
RUN cvs -z3 -d:pserver:anonymous@tempo2.cvs.sourceforge.net:/cvsroot/tempo2 co tempo2
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
ENV PSRCHIVE $PSRHOME/psrchive
ENV PATH $PATH:$PSRCHIVE/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRCHIVE/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRCHIVE/install/lib
ENV PYTHONPATH $PYTHONPATH:$PSRCHIVE/install/lib/python2.7/site-packages
WORKDIR $PSRHOME
RUN git clone git://git.code.sf.net/p/psrchive/code psrchive
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
ENV SOFA $PSRHOME/sofa
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$SOFA/20160503/c/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$SOFA/20160503/c/install/lib
WORKDIR $PSRHOME
RUN wget http://www.iausofa.org/2016_0503_C/sofa_c-20160503.tar.gz && \
    tar -xvvf sofa_c-20160503.tar.gz
WORKDIR $SOFA/20160503/c/src
RUN sed -i 's|INSTALL_DIR = $(HOME)|INSTALL_DIR = $(PSRHOME)/sofa/20160503/c/install|g' makefile && \
    make && \
    make test


# SOFA FORTRAN-library
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$SOFA/20160503/f77/install/lib
WORKDIR $PSRHOME
RUN wget http://www.iausofa.org/2016_0503_F/sofa_f-20160503.tar.gz && \
    tar -xvvf sofa_f-20160503.tar.gz
WORKDIR $SOFA/20160503/f77/src
RUN sed -i 's|INSTALL_DIR = $(HOME)|INSTALL_DIR = $(PSRHOME)/sofa/20160503/f77/install|g' makefile && \
    make && \
    make test


# SIGPROC
ENV SIGPROC $PSRHOME/sigproc
ENV PATH $PATH:$SIGPROC/install/bin
ENV FC gfortran
ENV F77 gfortran
ENV CC gcc
ENV CXX g++
WORKDIR $PSRHOME
RUN git clone https://github.com/SixByNine/sigproc.git
WORKDIR $SIGPROC/src
RUN mv aliases.c aliases.c_ORIGINAL && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/aliases.c
WORKDIR $SIGPROC
RUN ./bootstrap && \
    ./configure --prefix=$SIGPROC/install --x-libraries=/usr/lib/x86_64-linux-gnu --enable-shared LDFLAGS="-L/home/kat/software/tempo2/T2runtime/lib" LIBS="-ltempo2" && \
    make && \
    make install


# sigpyproc
ENV SIGPYPROC $PSRHOME/sigpyproc
ENV PYTHONPATH $PYTHONPATH:$SIGPYPROC/lib/python
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$SIGPYPROC/lib/c
WORKDIR $PSRHOME
RUN git clone https://github.com/ewanbarr/sigpyproc.git
WORKDIR $PSRHOME/sigpyproc
RUN python setup.py install --record list.txt


# CUB
ENV CUB $PSRHOME:cub-1.5.2
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH/$CUB
WORKDIR $PSRHOME
RUN wget https://github.com/NVlabs/cub/archive/1.5.2.zip && \
    mv 1.5.2.zip cub-1.5.2.zip && \
    unzip cub-1.5.2.zip


# PSRDADA
ENV PSRDADA $PSRHOME/psrdada
ENV PATH $PATH:$PSRDADA/install/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRDADA/install/lib
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRDADA/install/include
ENV CUDA_NVCC_FLAGS "-O3 -arch sm_30 -m64 -lineinfo -I$PSRHOME/cub-1.5.2"
WORKDIR $PSRHOME
RUN cvs -z3 -d:pserver:anonymous@psrdada.cvs.sourceforge.net:/cvsroot/psrdada co -P psrdada
WORKDIR $PSRHOME/psrdada
RUN ./bootstrap && \
    ./configure --prefix=$PSRDADA/install --x-libraries=/usr/lib/x86_64-linux-gnu --with-sofa-lib-dir=$SOFA/20160503/c/install/lib --with-cuda-dir=/usr/local/cuda F77="gfortran" LDFLAGS="-L/usr/lib" LIBS="-lpgplot -lcpgplot -libverbs -lstdc++" CPPFLAGS="-I$PSRHOME/cub-1.5.2" && \
    make -j $(nproc) && \
    make && \
    make install


# szlib
ENV SZIP $PSRHOME/szip-2.1
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$SZIP/install/lib
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$SZIP/install/include
WORKDIR $PSRHOME
RUN wget http://www.hdfgroup.org/ftp/lib-external/szip/2.1/src/szip-2.1.tar.gz && \
    tar -xvvf szip-2.1.tar.gz
WORKDIR $SZIP
RUN ./configure --prefix=$SZIP/install && \
    make && \
    make install


# h5check
ENV H5CHECK $PSRHOME/h5check-2.0.1
ENV PATH $PATH:$H5CHECK/install/bin
WORKDIR $PSRHOME
RUN wget https://www.hdfgroup.org/ftp/HDF5/tools/h5check/src/h5check-2.0.1.tar.gz && \
    tar -xvvf h5check-2.0.1.tar.gz
WORKDIR $H5CHECK
RUN ./configure --prefix=$H5CHECK/install && \
    make && \
    make install


# DAL
ENV DAL $PSRHOME/DAL
ENV PATH $PATH:$DAL/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$DAL/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$DAL/install/lib
WORKDIR $PSRHOME
RUN git clone https://github.com/nextgen-astrodata/DAL.git
WORKDIR $DAL
RUN mkdir build
WORKDIR $DAL/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=$DAL/install && \
    make -j $(nproc) && \
    make && \
    make install


# DSPSR
ENV DSPSR $PSRHOME/dspsr
ENV PATH $PATH:$DSPSR/install/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$DSPSR/install/lib
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$DSPSR/install/include
WORKDIR $PSRHOME
RUN git clone git://git.code.sf.net/p/dspsr/code dspsr
WORKDIR $DSPSR
RUN ./bootstrap && \
    echo "lump fits sigproc dada lofar_dal" > backends.list && \
    ./configure --prefix=$DSPSR/install --x-libraries=/usr/lib/x86_64-linux-gnu --with-cuda-dir=/usr/local/cuda-7.5 --with-cuda-include-dir=/usr/local/cuda-7.5/include/ --with-cuda-lib-dir=//usr/local/cuda-7.5/lib64 CPPFLAGS="-I$DAL/install/include" LDFLAGS="-L$DAL/install/lib" && \
    make -j $(nproc) && \
    make && \
    make install


# clig
ENV CLIG $PSRHOME/clig
ENV PATH $PATH:$CLIG/instal/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$CLIG/instal/lib
WORKDIR $PSRHOME
RUN wget http://bsdforge.com/projects/source/devel/clig/clig-1.9.11.2.tar.xz && \
    tar -xvvf clig-1.9.11.2.tar.xz
WORKDIR $CLIG
RUN sed -i 's|prefix =/usr|prefix=$(CLIG)/instal|g' makefile && \
    make && \
    make install


# CLooG
ENV CLOOG $PSRHOME/cloog-0.18.4
ENV PATH $PATH:$CLOOG/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$CLOOG/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$CLOOG/install/lib
WORKDIR $PSRHOME
RUN wget http://www.bastoul.net/cloog/pages/download/cloog-0.18.4.tar.gz && \
    tar -xvvf cloog-0.18.4.tar.gz
WORKDIR $CLOOG
RUN ./configure --prefix=$CLOOG/install && \
    make && \
    make install


# Ctags
ENV CTAGS $PSRHOME/ctags-5.8
ENV PATH $PATH:$CTAGS/install/bin
WORKDIR $PSRHOME
RUN wget http://prdownloads.sourceforge.net/ctags/ctags-5.8.tar.gz && \
    tar -xvvf ctags-5.8.tar.gz
WORKDIR $CTAGS
RUN ./configure --prefix=$CTAGS/install && \
    make && \
    make install


# GeographicLib
ENV GEOLIB $PSRHOME/GeographicLib-1.46
ENV PATH $PATH:$GEOLIB/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$GEOLIB/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$GEOLIB/install/lib
ENV PYTHONPATH $PYTHONPATH:$GEOLIB/install/lib/python/site-packages
WORKDIR $PSRHOME
RUN wget http://downloads.sourceforge.net/project/geographiclib/distrib/GeographicLib-1.46.tar.gz && \
    tar -xvvf GeographicLib-1.46.tar.gz
WORKDIR $GEOLIB
RUN ./configure --prefix=$GEOLIB/install && \
    make && \
    make install


# h5edit
ENV H5EDIT $PSRHOME/h5edit-1.3.1
ENV PATH $PATH:$H5EDIT/install/bin
WORKDIR $PSRHOME
RUN wget http://www.hdfgroup.org/ftp/HDF5/projects/jpss/h5edit/h5edit-1.3.1.tar.gz && \
    tar -xvvf h5edit-1.3.1.tar.gz
WORKDIR $H5EDIT
RUN ./configure --prefix=$H5EDIT/install CFLAGS="-Doff64_t=__off64_t" LDFLAGS="-L/usr/lib/x86_64-linux-gnu" LIBS="-lhdf5 -lhdf5_hl" && \
    make && \
    make install


# Leptonica
ENV LEPTONICA $PSRHOME/leptonica-1.73
ENV PATH $PATH:$LEPTONICA/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$LEPTONICA/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$LEPTONICA/install/lib
WORKDIR $PSRHOME
RUN wget http://www.leptonica.com/source/leptonica-1.73.tar.gz && \
    tar -xvvf leptonica-1.73.tar.gz
WORKDIR $LEPTONICA
RUN ./configure --prefix=$LEPTONICA/install && \
    make && \
    make install


# tvmet
ENV TVMET $PSRHOME/tvmet-1.7.2
ENV PATH $PATH:$TVMET/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$TVMET/install/include
WORKDIR $PSRHOME
RUN wget http://downloads.sourceforge.net/project/tvmet/Tar.Gz_Bz2%20Archive/1.7.2/tvmet-1.7.2.tar.bz2 && \
    tar -xvvf tvmet-1.7.2.tar.bz2
WORKDIR $TVMET
RUN ./configure --prefix=$TVMET/install && \
    make && \
    make install


# FFTW2
ENV FFTW2 $PSRHOME/fftw-2.1.5
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$FFTW2/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$FFTW2/install/lib
WORKDIR $PSRHOME
RUN wget http://www.fftw.org/fftw-2.1.5.tar.gz && \
    tar -xvvf fftw-2.1.5.tar.gz
WORKDIR $FFTW2
RUN ./configure --prefix=$FFTW2/install --enable-threads --enable-float && \
    make -j $(nproc) && \
    make && \
    make install


# fitsverify
ENV FITSVERIFY $PSRHOME/fitsverify
ENV PATH $PATH:$FITSVERIFY
WORKDIR $PSRHOME
RUN wget http://heasarc.gsfc.nasa.gov/docs/software/ftools/fitsverify/fitsverify-4.18.tar.gz && \
    tar -xvvf fitsverify-4.18.tar.gz
WORKDIR $FITSVERIFY
RUN gcc -o fitsverify ftverify.c fvrf_data.c fvrf_file.c fvrf_head.c fvrf_key.c fvrf_misc.c -DSTANDALONE -I/usr/include -L/usr/lib/x86_64-linux-gnu -lcfitsio -lm -lnsl


# PSRSALSA
ENV PSRSALSA $PSRHOME/psrsalsa
ENV PATH $PATH:$PSRSALSA/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRSALSA/src/lib
WORKDIR $PSRHOME
RUN git clone https://github.com/weltevrede/psrsalsa.git
WORKDIR $PSRSALSA
RUN make


# pypsrfits
ENV PYPSRFITS $PSRHOME/pypsrfits
WORKDIR $PSRHOME
RUN git clone https://github.com/demorest/pypsrfits.git
WORKDIR $PYPSRFITS
RUN python setup.py install --record list.txt


# PRESTO
ENV PRESTO $PSRHOME/presto
ENV PATH $PATH:$PRESTO/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PRESTO/lib
ENV PYTHONPATH $PYTHONPATH:$PRESTO/lib/python
WORKDIR $PSRHOME
RUN git clone https://github.com/scottransom/presto.git
WORKDIR $PRESTO/src
RUN make makewisdom && \
    make prep && \
    make
WORKDIR $PRESTO/python
RUN make


# wapp2psrfits
ENV WAPP2PSRFITS $PSRHOME/wapp2psrfits
ENV PATH $PATH:$WAPP2PSRFITS
WORKDIR $PSRHOME
RUN git clone https://github.com/scottransom/wapp2psrfits.git
WORKDIR $WAPP2PSRFITS
RUN make


# psrfits2psrfits
ENV PSRFITS2PSRFITS $PSRHOME/psrfits2psrfits
ENV PATH $PATH:$PSRFITS2PSRFITS
WORKDIR $PSRHOME
RUN git clone https://github.com/scottransom/psrfits2psrfits.git
WORKDIR $PSRFITS2PSRFITS
RUN make


# psrfits_utils
ENV PSRFITS_UTILS $PSRHOME/psrfits_utils
ENV PATH $PATH:$PSRFITS_UTILS/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRFITS_UTILS/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRFITS_UTILS/install/lib
WORKDIR $PSRHOME
RUN git clone https://github.com/scottransom/psrfits_utils.git
WORKDIR $PSRFITS_UTILS
RUN sed -i 's|-Werror foreign|-Werror foreign -Wno-extra-portability|g' configure.ac && \
    ./prepare && \
    ./configure --prefix=$PSRFITS_UTILS/install && \
    make && \
    make install


# pyslalib
ENV PYSLALIB $PSRHOME/pyslalib
WORKDIR $PSRHOME
RUN git clone https://github.com/scottransom/pyslalib.git
WORKDIR $PYSLALIB
RUN python setup.py install --record list.txt


# Vpsr
ENV VPSR $PSRHOME/Vpsr
ENV PATH $PATH:$VPSR
WORKDIR $PSRHOME
RUN git clone https://github.com/ArisKarastergiou/Vpsr.git
WORKDIR $VPSR


# # coast_guard
# ENV COAST_GUARD $PSRHOME/coast_guard
# ENV PATH $PATH:$COAST_GUARD
# ENV COASTGUARD_CFG COAST_GUARD/configurations
# ENV PYTHONPATH $PYTHONPATH:$COAST_GUARD
# WORKDIR $PSRHOME
# RUN git clone https://github.com/plazar/coast_guard.git
# WORKDIR $COAST_GUARD
# RUN mv utils.py utils.py_ORIGINAL && \
#     wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/utils.py


WORKDIR $PSRHOME


#  # 
#  ENV  $PSRHOME/
#  ENV PATH $PATH:$ /install/bin
#  ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$ /install/include
#  ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$ /install/lib
#  ENV PYTHONPATH $PYTHONPATH:$ /install/lib/python/site-packages
#  WORKDIR $PSRHOME
#  RUN wget   && \
#      tar -xvvf 
#  WORKDIR $
#  RUN ./configure --prefix=$ /install && \
#      make && \
#      make install

# multinest
# ppgplot-1.4
# rpfits
# makems
# katdal
# katpoint
# katpulse
# katsdpscripts
# katversion
# wsclean-1.11
# measures_data
# casacore
# casa-release-4.6.0-el6
# python-casacore - pip install python-casacore -U

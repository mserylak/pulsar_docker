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


# Define home, psrhome, OSTYPE and create the directory
ENV HOME /home/kat
ENV PSRHOME /home/kat/software
ENV OSTYPE linux
RUN mkdir -p /home/kat/software


# Put in file with all environmental variables
WORKDIR $HOME
RUN echo "" >> .bashrc && \
    echo "if [ -e $HOME/.mysetenv.bash ]; then" >> .bashrc && \
    echo "   source $HOME/.mysetenv.bash" >> .bashrc && \
    echo "fi" >> .bashrc && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/.mysetenv.bash


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


# Python packages
ENV PYTHONPATH $HOME/ve/lib/python2.7/site-packages


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
WORKDIR $PSRHOME/calceph-2.2.4
RUN ./configure --prefix=$PSRHOME/calceph-2.2.4/install --with-pic --enable-shared --enable-static --enable-fortran --enable-thread && \
    make && \
    make check && \
    make install


# ds9
ENV PATH $PATH:$PSRHOME/ds9-7.4


# fv
ENV PATH $PATH:$PSRHOME/fv5.4


# psrcat
ENV PSRCAT_FILE $PSRHOME/psrcat_tar/psrcat.db
ENV PATH $PATH:$PSRHOME/psrcat_tar
WORKDIR $PSRHOME/psrcat_tar
RUN /bin/bash makeit


# tempo
ENV TEMPO $PSRHOME/tempo
ENV PATH $PATH:$PSRHOME/tempo/bin
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
WORKDIR $SOFA/20160503/c/src
RUN sed -i 's|INSTALL_DIR = $(HOME)|INSTALL_DIR = $(PSRHOME)/sofa/20160503/c/install|g' makefile && \
    make && \
    make test


# SOFA FORTRAN-library
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$SOFA/20160503/f77/install/lib
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
WORKDIR $PSRHOME/sigpyproc
RUN python setup.py install --record list.txt


# CUB
ENV CUB $PSRHOME:cub-1.5.2
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH/$CUB


# PSRDADA
ENV PSRDADA $PSRHOME/psrdada
ENV PATH $PATH:$PSRDADA/install/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRDADA/install/lib
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRDADA/install/include
ENV CUDA_NVCC_FLAGS "-O3 -arch sm_30 -m64 -lineinfo -I$PSRHOME/cub-1.5.2"
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
WORKDIR $SZIP
RUN ./configure --prefix=$SZIP/install && \
    make && \
    make install


# h5check
ENV H5CHECK $PSRHOME/h5check-2.0.1
ENV PATH $PATH:$H5CHECK/install/bin
WORKDIR $H5CHECK
RUN ./configure --prefix=$H5CHECK/install && \
    make && \
    make install


# DAL
ENV DAL $PSRHOME/DAL
ENV PATH $PATH:$DAL/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$DAL/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$DAL/install/lib
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
WORKDIR $CLIG
RUN sed -i 's|prefix =/usr|prefix=$(CLIG)/instal|g' makefile && \
    make && \
    make install


# CLooG
ENV CLOOG $PSRHOME/cloog-0.18.4
ENV PATH $PATH:$CLOOG/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$CLOOG/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$CLOOG/install/lib
WORKDIR $CLOOG
RUN ./configure --prefix=$CLOOG/install && \
    make && \
    make install


# Ctags
ENV CTAGS $PSRHOME/ctags-5.8
ENV PATH $PATH:$CTAGS/install/bin
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
WORKDIR $GEOLIB
RUN ./configure --prefix=$GEOLIB/install && \
    make && \
    make install


# h5edit
ENV H5EDIT $PSRHOME/h5edit-1.3.1
ENV PATH $PATH:$H5EDIT/install/bin
WORKDIR $H5EDIT
RUN ./configure --prefix=$H5EDIT/install CFLAGS="-Doff64_t=__off64_t" LDFLAGS="-L/usr/lib/x86_64-linux-gnu" LIBS="-lhdf5 -lhdf5_hl" && \
    make && \
    make install


# Leptonica
ENV LEPTONICA $PSRHOME/leptonica-1.73
ENV PATH $PATH:$LEPTONICA/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$LEPTONICA/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$LEPTONICA/install/lib
WORKDIR $LEPTONICA
RUN ./configure --prefix=$LEPTONICA/install && \
    make && \
    make install


# tvmet
ENV TVMET $PSRHOME/tvmet-1.7.2
ENV PATH $PATH:$TVMET/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$TVMET/install/include
WORKDIR $TVMET
RUN ./configure --prefix=$TVMET/install && \
    make && \
    make install


# FFTW2
ENV FFTW2 $PSRHOME/fftw-2.1.5
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$FFTW2/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$FFTW2/install/lib
WORKDIR $FFTW2
RUN ./configure --prefix=$FFTW2/install --enable-threads --enable-float && \
    make -j $(nproc) && \
    make && \
    make install


# fitsverify
ENV FITSVERIFY $PSRHOME/fitsverify
ENV PATH $PATH:$FITSVERIFY
WORKDIR $FITSVERIFY
RUN gcc -o fitsverify ftverify.c fvrf_data.c fvrf_file.c fvrf_head.c fvrf_key.c fvrf_misc.c -DSTANDALONE -I/usr/include -L/usr/lib/x86_64-linux-gnu -lcfitsio -lm -lnsl


# PSRSALSA
ENV PSRSALSA $PSRHOME/psrsalsa
ENV PATH $PATH:$PSRSALSA/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRSALSA/src/lib
WORKDIR $PSRSALSA
RUN make


# pypsrfits
ENV PYPSRFITS $PSRHOME/pypsrfits
WORKDIR $PYPSRFITS
RUN python setup.py install --record list.txt


# PRESTO
ENV PRESTO $PSRHOME/presto
ENV PATH $PATH:$PRESTO/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PRESTO/lib
ENV PYTHONPATH $PYTHONPATH:$PRESTO/lib/python
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
ENV WAPP2PSRFITS $PSRHOME/wapp2psrfits
ENV PATH $PATH:$WAPP2PSRFITS
WORKDIR $WAPP2PSRFITS
RUN make


# psrfits2psrfits
ENV PSRFITS2PSRFITS $PSRHOME/psrfits2psrfits
ENV PATH $PATH:$PSRFITS2PSRFITS
WORKDIR $PSRFITS2PSRFITS
RUN make


# psrfits_utils
ENV PSRFITS_UTILS $PSRHOME/psrfits_utils
ENV PATH $PATH:$PSRFITS_UTILS/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRFITS_UTILS/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRFITS_UTILS/install/lib
WORKDIR $PSRFITS_UTILS
RUN sed -i 's|-Werror foreign|-Werror foreign -Wno-extra-portability|g' configure.ac && \
    ./prepare && \
    ./configure --prefix=$PSRFITS_UTILS/install && \
    make && \
    make install


# pyslalib
ENV PYSLALIB $PSRHOME/pyslalib
ENV VPSR $PSRHOME/Vpsr
WORKDIR $PYSLALIB
RUN python setup.py install --record list.txt


# Vpsr
ENV PATH $PATH:$VPSR


# GPy
ENV GPY $PSRHOME/GPy
ENV PATH $PATH:$GPY
WORKDIR $GPY
RUN python setup.py install --record list.txt


# katversion
ENV KATVERSION $PSRHOME/katversion
WORKDIR $KATVERSION
RUN python setup.py install --record list.txt


# katpoint
ENV KATPOINT $PSRHOME/katpoint
WORKDIR $KATPOINT
RUN python setup.py install --record list.txt


# katdal
ENV KATDAL $PSRHOME/katdal
WORKDIR $KATDAL
RUN python setup.py install --record list.txt


# katconfig
ENV KATCONFIG $PSRHOME/katconfig


# katsdpscripts
ENV KATSDPSCRIPTS $PSRHOME/katsdpscripts
WORKDIR $KATSDPSCRIPTS
RUN python setup.py install --record list.txt


# katsdpinfrastructure
ENV KATSDPINFRASTRUCTURE $PSRHOME/katsdpinfrastructure


# katpulse
ENV KATPULSE $PSRHOME/katpulse


# casacore measures_data
ENV MEASURES_DATA $PSRHOME/measures_data
WORKDIR $PSRHOME
RUN mkdir measures_data
RUN tar -xvvf WSRT_Measures.ztar -C $MEASURES_DATA


# casa
ENV CASA $PSRHOME/casa-release-4.6.0-el6
ENV PATH $PATH:$PSRHOME/casa-release-4.6.0-el6/bin


# casacore
ENV CASACORE $PSRHOME/casacore
ENV PATH $PATH:$CASACORE/build/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$CASACORE/build/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$CASACORE/build/install/lib
WORKDIR $CASACORE
RUN mkdir build
WORKDIR $CASACORE/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=$CASACORE/build/install -DCMAKE_BUILD_PYTHON=ON -DCMAKE_BUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TESTING=ON -DCMAKE_CASA_BUILD=ON -DCMAKE_CMAKE_BUILD_TYPE=Release -DCMAKE_ENABLE_SHARED=ON -DCMAKE_USE_FFTW3=ON -DCMAKE_USE_HDF5=ON -DCMAKE_USE_OPENMP=ON -DCMAKE_USE_STACKTRACE=ON -DCMAKE_USE_THREADS=ON && \
    make -j $(nproc) && \
    make && \
    make install


# python-casacore
ENV PYTHON_CASACORE $PSRHOME/python-casacore
WORKDIR $PYTHON_CASACORE
RUN python setup.py install --record list.txt


# makems
ENV MAKEMS $PSRHOME/makems
ENV PATH $PATH:$MAKEMS/LOFAR/installed/gnu_opt/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$MAKEMS/LOFAR/installed/gnu_opt/LOFAR/installed/gnu_opt/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$MAKEMS/LOFAR/installed/gnu_opt/lib64
WORKDIR $MAKEMS/LOFAR
RUN mkdir -p $MAKEMS/LOFAR/build/gnu_opt
WORKDIR $MAKEMS/LOFAR/build/gnu_opt
RUN cmake -DCMAKE_MODULE_PATH:PATH=$PSRHOME/makems/LOFAR/CMake -DUSE_LOG4CPLUS=OFF -DBUILD_TESTING=OFF ../.. && \
    make && \
    make install


# wsclean
ENV WSCLEAN $PSRHOME/wsclean-1.12
ENV PATH $PATH:$WSCLEAN/build/install/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$WSCLEAN/build/install/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$WSCLEAN/build/install/lib
WORKDIR $WSCLEAN
RUN mkdir build
WORKDIR $WSCLEAN/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=$WSCLEAN/build/install && \
    make && \
    make install


# coast_guard
ENV COAST_GUARD $PSRHOME/coast_guard
ENV PATH $PATH:$COAST_GUARD
ENV COASTGUARD_CFG $COAST_GUARD/configurations
ENV PYTHONPATH $PYTHONPATH:$COAST_GUARD
WORKDIR $COAST_GUARD
RUN mv utils.py utils.py_ORIGINAL && \
    wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/utils.py


# clean downloaded source codes
WORKDIR $PSRHOME
RUN rm -rf ./*.bz2 ./*.gz ./*.xz ./*.ztar ./*.zip

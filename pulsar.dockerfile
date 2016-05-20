FROM ubuntu:14.04

MAINTAINER Maciej Serylak <mserylak@gmail.com>


# Update system
RUN apt-get -y update && apt-get -y upgrade


# Install system packages
RUN apt-get -y install \
    autoconf \
    automake \
    cmake \
    cmake-data \
    cmake-curses-gui \
    csh \
    cvs \
    cython \
    f2c \
    fftw2 \
    fftw-dev \
    flex \
    fort77 \
    gfortran \
    ghostscript \
    ghostscript-x \
    git \
    gnuplot \
    gnuplot-x11 \
    gsl-bin \
    gv \
    htop \
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
    libgd2-xpm-dev \
    libgeographiclib9 \
    libglib2.0-dev \
    libgsl0-dev \
    libgsl0ldbl \
    libhdf5-7 \
    libhdf5-dev \
    libhdf5-serial-dev \
    liblapack3 \
    liblapack3gf \
    liblapack-dev \
    liblapacke \
    liblapacke-dev \
    liblapack-pic \
    liblapack-test \
    liblua5.1-0 \
    liblua5.2-0 \
    libpng12-dev \
    libpng3 \
    libpng++-dev \
    libtool \
    locate \
    m4 \
    make \
    nano \
    nfs-common \
    openssh-server \
    pbzip2 \
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
    git-core \
    wget \
    python-scipy \
    python-sympy \
    subversion \
    swig \
    swig2.0 \
    tcsh \
    tk \
    tk-dev \
    tmux


# Update system again (just in case)
RUN apt-get -y update && apt-get -y upgrade


#
RUN mkdir /var/run/sshd


# Add new user kat with passwd kat and give it sudo privileges
RUN adduser --disabled-password --gecos 'unprivileged user' kat \
    && (echo kat; echo kat) | passwd kat \
    && adduser kat sudo \
    && mkdir -p /home/kat/pulsar_software


# Define home
ENV HOME /home/kat


# Path to the pulsar software installation directory
ENV PSRHOME /home/kat/pulsar_software


# Set up OSTYPE
ENV OSTYPE linux


# PGPLOT
ENV PGPLOT_DIR $PSRHOME/pgplot
ENV PGPLOT_DEV /xs
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRHOME/pgplot
ENV PGPLOT_FONT $PSRHOME/pgplot/grfont.dat
ENV PGPLOT_BACKGROUND white
ENV PGPLOT_FOREGROUND black
ENV PGPLOT_INCLUDES $PSRHOME:/pgplot
ENV FCOMPL gfortran
WORKDIR $HOME
RUN wget ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot5.2.tar.gz
RUN tar -xvf pgplot5.2.tar.gz -C $PSRHOME
WORKDIR $PSRHOME/pgplot
RUN /bin/sed -i 's/\! PSDRIV 1/ PSDRIV 1/g;s/\! PSDRIV 2/ PSDRIV 2/g;s/\! PSDRIV 3/ PSDRIV 3/g;s/\! PSDRIV 4/ PSDRIV 4/g;s/\! XWDRIV 1/ XWDRIV 1/g;s/\! XWDRIV 2/ XWDRIV 2/g' drivers.list
RUN /bin/bash makemake . linux g77_gcc_aout
RUN /bin/sed -i 's/FCOMPL=g77/FCOMPL=gfortran/g' makefile
RUN /bin/sed -i 's/FFLAGC=-Wall -O/FFLAGC=-Wall -fPIC -O/g' makefile
RUN /bin/sed -i 's/FFLAGD=-fno-backslash/FFLAGD=-fPIC -fno-backslash/g' makefile
RUN /bin/sed -i 's/CFLAGC=-DPG_PPU -O2 -I./CFLAGC=-DPG_PPU -fPIC -O2 -I./g' makefile
RUN /bin/sed -i 's/CFLAGD=-O2/CFLAGD=-fPIC -O2/g' makefile
RUN make \
    && make clean \
    && make cpg \
    && ld -shared -o libcpgplot.so --whole-archive libcpgplot.a


# fftw-3.3.4
ENV PATH $PATH:$PSRHOME/fftw-3.3.4/install/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRHOME/fftw-3.3.4/install/lib
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRHOME/fftw-3.3.4/install/include
WORKDIR $HOME
RUN wget http://www.fftw.org/fftw-3.3.4.tar.gz
RUN tar -xvf fftw-3.3.4.tar.gz -C $PSRHOME
WORKDIR $PSRHOME/fftw-3.3.4
RUN ./configure --prefix=$PSRHOME/fftw-3.3.4/install --enable-single --enable-float --enable-shared --enable-sse2 --enable-avx --enable-openmp --enable-mpi --enable-threads --enable-float F77=gfortran CFLAGS=-fPIC FFLAGS=-fPIC
RUN make \
    && make check \
    && make install \
    && make clean


# calceph-2.2.4
ENV PATH $PATH:$PSRHOME/calceph-2.2.4/install/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRHOME/calceph-2.2.4/install/lib
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRHOME/calceph-2.2.4/install/include
WORKDIR $HOME
RUN wget http://www.imcce.fr/fr/presentation/equipes/ASD/inpop//calceph/calceph-2.2.4.tar.gz
RUN tar -xvf calceph-2.2.4.tar.gz -C $PSRHOME
WORKDIR $PSRHOME/calceph-2.2.4
RUN ./configure --prefix=$PSRHOME/calceph-2.2.4/install --with-pic --enable-shared --enable-static --enable-fortran --enable-thread
RUN make \
    && make check \
    && make install \
    && make clean


# cfitsio
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRHOME/cfitsio/install/lib
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRHOME/cfitsio/install/include
WORKDIR $HOME
RUN wget ftp://heasarc.gsfc.nasa.gov/software/fitsio/c/cfitsio_latest.tar.gz
RUN tar -xvf cfitsio_latest.tar.gz -C $PSRHOME
WORKDIR $PSRHOME/cfitsio
RUN ./configure --prefix=$PSRHOME/cfitsio/install --with-bzip2 --enable-sse2 --enable-reentrant
RUN make \
    && make install \
    && make clean


# DAL
ENV PATH $PATH:$PSRHOME/DAL/install/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRHOME/DAL/install/lib
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRHOME/DAL/install/include
WORKDIR $PSRHOME
RUN git clone https://github.com/nextgen-astrodata/DAL.git
WORKDIR $PSRHOME/DAL
RUN mkdir build
RUN mkdir install
WORKDIR $PSRHOME/DAL/build
RUN cmake ../ -DCMAKE_CMAKE_INSTALL_PREFIX=$PSRHOME/DAL/install
RUN make \
    && make install


# astropy
ENV PATH $PATH:$PSRHOME/astropy/install/bin
ENV PYTHONPATH $PYTHONPATH:$PSRHOME/astropy/install/lib/python2.7/site-packages/
WORKDIR $PSRHOME
RUN git clone https://github.com/astropy/astropy.git
WORKDIR $PSRHOME/astropy
RUN python setup.py install --prefix=$PSRHOME/astropy/install --record list.txt


# hdf5
ENV PATH $PATH:$PSRHOME/hdf5-1.8.16/hdf5/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRHOME/hdf5-1.8.15-patch1/hdf5/lib
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRHOME/hdf5-1.8.15-patch1/hdf5/include
WORKDIR $HOME
RUN wget http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.16.tar.bz2
RUN tar -xvf hdf5-1.8.16.tar.bz2 -C $PSRHOME
WORKDIR $PSRHOME/hdf5-1.8.16
RUN ./configure --enable-cxx
RUN make \
    && make install


# h5edit
ENV PATH $PATH:$PSRHOME/h5edit-1.3.1/
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRHOME/h5edit-1.3.1/
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:$PSRHOME/h5edit-1.3.1/
WORKDIR $HOME
RUN wget http://www.hdfgroup.org/ftp/HDF5/projects/jpss/h5edit/h5edit-1.3.1.tar.gz
RUN tar -xvf h5edit-1.3.1.tar.gz -C $PSRHOME
WORKDIR $PSRHOME/h5edit-1.3.1
RUN ./configure 
RUN make \
    && make install


# ds9
ENV PATH $PATH:$PSRHOME/ds9-7.4
RUN wget http://ds9.si.edu/download/linux64/ds9.linux64.7.4.tar.gz
RUN tar -xvf ds9.linux64.7.4.tar.gz -C $PSRHOME


# psrcat
ENV PSRCAT_FILE $PSRHOME/psrcat_tar/psrcat.db
ENV PATH $PATH:$PSRHOME/psrcat_tar
WORKDIR $HOME
RUN wget http://www.atnf.csiro.au/people/pulsar/psrcat/downloads/psrcat_pkg.tar.gz
RUN tar -xvf psrcat_pkg.tar.gz -C $PSRHOME
WORKDIR $PSRHOME/psrcat_tar
RUN /bin/bash makeit


# Tempo
ENV TEMPO $PSRHOME/tempo
ENV PATH $PATH:$PSRHOME/tempo/install/bin
WORKDIR $PSRHOME
RUN git clone git://git.code.sf.net/p/tempo/tempo
WORKDIR $PSRHOME/tempo
# NEED TO REPLACE OBSYS.DAT FILE -> GIT???!!!
RUN ./prepare \
    && ./configure --prefix=/home/kat/pulsar_software/tempo/install \
    && make \
    && make install


# Tempo2
ENV TEMPO2 $PSRHOME/tempo2/T2runtime
ENV PATH $PATH:$PSRHOME/tempo2/T2runtime/bin
ENV C_INCLUDE_PATH $C_INCLUDE_PATH:/usr/local/src/tempo2/T2runtime/include
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/src/tempo2/T2runtime/lib
WORKDIR $PSRHOME
RUN cvs -z3 -d:pserver:anonymous@tempo2.cvs.sourceforge.net:/cvsroot/tempo2 co tempo2
WORKDIR $PSRHOME/tempo2
# NEED TO REPLACE OBSYS.DAT FILE -> GIT???!!!
#RUN ./bootstrap \
#    && ./configure --x-libraries=/usr/lib/x86_64-linux-gnu --with-cfitsio-lib-dir=$PSRHOME/cfitsio/install/lib --with-calceph=$PSRHOME/calceph-2.2.4/install/lib --enable-shared --enable-static --with-pic F77=gfortran CPPFLAGS="-I/home/kat/pulsar_software/calceph-2.2.4/install/include"
#    && make \
#    && make install \
#    && make plugins-install

APLpy
baudline_1.08_linux_x86_64
bitstring-3.1.4
briss-0.9
casacore
casa-release-4.6.0-el6
clig-1.9.11.1
cloog-0.18.4
coast_guard
coast_guard2
ctags-5.8
cub
ddrescue-1.20
ds9-7.3.2
dspsr
ephem-3.7.6.0
fftw-2.1.5
GPy
h5check-2.0.1
h5edit-1.3.1
hdf5-1.8.15-patch1
makems
measures_data
Montage
mpfit
n-spell
peakutils
presto
proas-2.2.0
psrchive
psrfits2psrfits
psrfits_utils
pymc
pyslalib
python-casacore
rpfits
seaborn
sigproc
sigpyproc
splot
src-highlite
stuffit520.611
szip-2.1
tempo
tempo2
tornado-4.3
t_sky
tvmet-1.7.2
wapp2psrfits
wsclean-1.11

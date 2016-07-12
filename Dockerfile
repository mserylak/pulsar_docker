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


# Install python modules
RUN /usr/bin/pip install pip -U && \
    /usr/bin/pip install setuptools -U && \
    /usr/bin/pip install ipython -U && \
    /usr/bin/pip install six -U && \
    /usr/bin/pip install h5py -U && \
    /usr/bin/pip install numpy -U && \
    /usr/bin/pip install fitsio -U && \
    /usr/bin/pip install astropy -U && \
    /usr/bin/pip install scipy -U && \
    /usr/bin/pip install astroplan -U && \
    /usr/bin/pip install APLpy -U && \
    /usr/bin/pip install GPy -U && \
    /usr/bin/pip install pyfits -U && \
    /usr/bin/pip install bitstring -U && \
    /usr/bin/pip install cycler -U && \
    /usr/bin/pip install peakutils -U && \
    /usr/bin/pip install pymc -U && \
    /usr/bin/pip install seaborn -U


RUN mkdir -p /home/kat/software && \
    chown -R kat:kat /home/kat #&& \
#    adduser kat sudo


# Switch account to kat
USER kat


# Define home
ENV HOME /home/kat


# Path to the pulsar software installation directory
ENV PSRHOME /home/kat/software


# Set up OSTYPE
ENV OSTYPE linux


# PGPLOT
ENV PGPLOT_DIR /usr/lib/pgplot5
ENV PGPLOT_FONT /usr/lib/pgplot5/grfont.dat
ENV PGPLOT_INCLUDES /usr/include
ENV PGPLOT_BACKGROUND white
ENV PGPLOT_FOREGROUND black
ENV PGPLOT_DEV /xs
#ENV FCOMPL gfortran
#ENV PGPLOT_DIR $PSRHOME/pgplot
#ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$PSRHOME/pgplot
#ENV PGPLOT_FONT $PSRHOME/pgplot/grfont.dat
#ENV PGPLOT_INCLUDES $PSRHOME/pgplot
#ENV PGPLOT_DEV /xs
#ENV PGPLOT_BACKGROUND white
#ENV PGPLOT_FOREGROUND black
#WORKDIR $PSRHOME
#RUN wget ftp://ftp.astro.caltech.edu/pub/pgplot/pgplot5.2.tar.gz && \
#    tar -xvf pgplot5.2.tar.gz -C $PSRHOME
#WORKDIR $PSRHOME/pgplot
#RUN /bin/sed -i 's/\! PSDRIV 1/ PSDRIV 1/g;s/\! PSDRIV 2/ PSDRIV 2/g;s/\! PSDRIV 3/ PSDRIV 3/g;s/\! PSDRIV 4/ PSDRIV 4/g;s/\! XWDRIV 1/ XWDRIV 1/g;s/\! XWDRIV 2/ XWDRIV 2/g' drivers.list && \
#    /bin/bash makemake . linux g77_gcc_aout && \
#    /bin/sed -i 's/FCOMPL=g77/FCOMPL=gfortran/g' makefile && \
#    /bin/sed -i 's/FFLAGC=-Wall -O/FFLAGC=-Wall -fPIC -O/g' makefile && \
#    /bin/sed -i 's/FFLAGD=-fno-backslash/FFLAGD=-fPIC -fno-backslash/g' makefile && \
#    /bin/sed -i 's/CFLAGC=-DPG_PPU -O2 -I./CFLAGC=-DPG_PPU -fPIC -O2 -I./g' makefile && \
#    /bin/sed -i 's/CFLAGD=-O2/CFLAGD=-fPIC -O2/g' makefile
#RUN make && \
#    make clean && \
#    make cpg && \
#    ld -shared -o libcpgplot.so --whole-archive libcpgplot.a


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
    make install && \
    make clean


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
WORKDIR $HOME
RUN wget https://raw.githubusercontent.com/mserylak/pulsar_docker/master/.psrchive.cfg && \
    chown kat:kat /home/kat/.psrchive.cfg
WORKDIR $PSRHOME
RUN git clone git://git.code.sf.net/p/psrchive/code psrchive
WORKDIR $PSRHOME/psrchive
RUN ./bootstrap && \
    ./configure --prefix=$PSRCHIVE/install --x-libraries=/usr/lib/x86_64-linux-gnu F77=gfortran && \
    make -j $(nproc) && \
    make && \
    make install


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


# CUB
RUN wget https://github.com/NVlabs/cub/archive/1.5.2.zip && \
    mv 1.5.2.zip cub-1.5.2.zip


# sigproc
ENV SIGPROC $PSRHOME/sigproc
ENV PATH $PATH:$SIGPROC/install/bin
ENV FC gfortran
ENV F77 gfortran
ENV CC gcc
ENV CXX g++
WORKDIR $PSRHOME
RUN git clone https://github.com/SixByNine/sigproc.git
WORKDIR SIGPROC/src
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
USER root
RUN python setup.py install --record list.txt
USER kat

# PSRDADA
ENV PSRDADA $PSRHOME/psrdada
ENV CUDA_NVCC_FLAGS "-O3 -arch sm_30 -m64 -lineinfo -I$PSRHOME/cub-1.5.2"
WORKDIR $PSRHOME
RUN cvs -z3 -d:pserver:anonymous@psrdada.cvs.sourceforge.net:/cvsroot/psrdada co -P psrdada && \
    ./bootstrap && \
    ./configure --prefix=$PSRDADA/install --x-libraries=/usr/lib/x86_64-linux-gnu --with-sofa-lib-dir=$SOFA/20160503/c/install/lib --with-cuda-dir=/usr/local/cuda F77="gfortran" LDFLAGS="-L/usr/lib" LIBS="-lpgplot -lcpgplot -libverbs -lstdc++" CPPFLAGS="-I$PSRHOME/cub-1.5.2" && \
    make && \
    make install

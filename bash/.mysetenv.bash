# Change LS_COLORS
export LS_COLORS="no=00:fi=00:di=01;30:ln=00;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=41;33;01:ex=00;32:*.cmd=00;32:*.exe=01;32:*.com=01;32:*.bat=01;32:*.btm=01;32:*.dll=01;32:*.tar=00;31:*.tbz=00;31:*.tgz=00;31:*.rpm=00;31:*.deb=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.zip=00;31:*.zoo=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31:*.bz2=00;31:*.lrz=00;31:*.tb2=00;31:*.tz2=00;31:*.tbz2=00;31:*.xz=00;31:*.avi=01;35:*.bmp=01;35:*.fli=01;35:*.gif=01;35:*.jpg=01;35:*.jpeg=01;35:*.mng=01;35:*.mov=01;35:*.mpg=01;35:*.pcx=01;35:*.pbm=01;35:*.pgm=01;35:*.png=01;35:*.ppm=01;35:*.tga=01;35:*.tif=01;35:*.xbm=01;35:*.xpm=01;35:*.dl=01;35:*.gl=01;35:*.wmv=01;35:*.aiff=00;32:*.au=00;32:*.mid=00;32:*.mp3=00;32:*.ogg=00;32:*.voc=00;32:*.wav=00;32:"

# Set up PS1
export PS1="\u@\h [\$(date +%d\ %b\ %Y\ %H:%M)] \w> "

# Define home, psrhome, software, OSTYPE
export HOME=/home/psr
export PSRHOME=/home/psr/software
export OSTYPE=linux

# Up arrow search
export HISTFILE=$HOME/.bash_eternal_history
export HISTFILESIZE=
export HISTSIZE=
export HISTCONTROL=ignoreboth
export HISTIGNORE="l:ll:lt:ls:bg:fg:mc:history::ls -lah:..:ls -l;ls -lh;lt;la"
export HISTTIMEFORMAT="%F %T "
export PROMPT_COMMAND="history -a"
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

# PGPLOT
export PGPLOT_DIR=/usr/lib/pgplot5
export PGPLOT_FONT=/usr/lib/pgplot5/grfont.dat
export PGPLOT_INCLUDES=/usr/include
export PGPLOT_BACKGROUND=white
export PGPLOT_FOREGROUND=black
export PGPLOT_DEV=/xs

# calceph
export CALCEPH=$PSRHOME/calceph-2.3.0
export PATH=$PATH:$CALCEPH/install/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CALCEPH/install/lib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$CALCEPH/install/include

# ds9
export DS9=$PSRHOME/ds9-7.4
export PATH=$PATH:$DS9

# fv
export FV=$PSRHOME/fv5.4
export PATH=$PATH:$FV

# psrcat
export PSRCAT=$PSRHOME/psrcat_tar
export PSRCAT_FILE=$PSRCAT/psrcat.db
export PATH=$PATH:$PSRCAT

# tempo
export TEMPO=$PSRHOME/tempo
export PATH=$PATH:$PSRHOME/tempo/bin

# tempo2
export TEMPO2=$PSRHOME/tempo2/T2runtime
export PATH=$PATH:$PSRHOME/tempo2/T2runtime/bin
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$PSRHOME/tempo2/T2runtime/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PSRHOME/tempo2/T2runtime/lib

# PSRXML
export PSRXML=$PSRHOME/psrxml
export PATH=$PATH:$PSRXML/install/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PSRXML/install/lib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$PSRXML/install/include

# PSRCHIVE
export PSRCHIVE=$PSRHOME/psrchive
export PATH=$PATH:$PSRCHIVE/install/bin
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$PSRCHIVE/install/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PSRCHIVE/install/lib
export PYTHONPATH=$PYTHONPATH:$PSRCHIVE/install/lib/python2.7/site-packages

# SOFA C-library
export SOFA=$PSRHOME/sofa
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$SOFA/20160503/c/install/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFA/20160503/c/install/lib

# SOFA FORTRAN-library
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SOFA/20160503/f77/install/lib

# SIGPROC
export SIGPROC=$PSRHOME/sigproc
export PATH=$PATH:$SIGPROC/install/bin
export FC=gfortran
export F77=gfortran
export CC=gcc
export CXX=g++

# sigpyproc
export SIGPYPROC=$PSRHOME/sigpyproc
export PYTHONPATH=$PYTHONPATH:$SIGPYPROC/lib/python
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SIGPYPROC/lib/c

# szlib
export SZIP=$PSRHOME/szip-2.1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$SZIP/install/lib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$SZIP/install/include

# h5check
export H5CHECK=$PSRHOME/h5check-2.0.1
export PATH=$PATH:$H5CHECK/install/bin

# DAL
export DAL=$PSRHOME/DAL
export PATH=$PATH:$DAL/install/bin
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$DAL/install/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DAL/install/lib

# DSPSR
export DSPSR=$PSRHOME/dspsr
export PATH=$PATH:$DSPSR/install/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DSPSR/install/lib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$DSPSR/install/include

# clig
export CLIG=$PSRHOME/clig
export PATH=$PATH:$CLIG/instal/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CLIG/instal/lib

# CLooG
export CLOOG=$PSRHOME/cloog-0.18.4
export PATH=$PATH:$CLOOG/install/bin
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$CLOOG/install/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CLOOG/install/lib

# Ctags
export CTAGS=$PSRHOME/ctags-5.8
export PATH=$PATH:$CTAGS/install/bin

# GeographicLib
export GEOLIB=$PSRHOME/GeographicLib-1.46
export PATH=$PATH:$GEOLIB/install/bin
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$GEOLIB/install/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$GEOLIB/install/lib
export PYTHONPATH=$PYTHONPATH:$GEOLIB/install/lib/python/site-packages

# h5edit
export H5EDIT=$PSRHOME/h5edit-1.3.1
export PATH=$PATH:$H5EDIT/install/bin

# Leptonica
export LEPTONICA=$PSRHOME/leptonica-1.73
export PATH=$PATH:$LEPTONICA/install/bin
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$LEPTONICA/install/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LEPTONICA/install/lib

# tvmet
export TVMET=$PSRHOME/tvmet-1.7.2
export PATH=$PATH:$TVMET/install/bin
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$TVMET/install/include

# FFTW2
export FFTW2=$PSRHOME/fftw-2.1.5
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$FFTW2/install/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$FFTW2/install/lib

# fitsverify
export FITSVERIFY=$PSRHOME/fitsverify
export PATH=$PATH:$FITSVERIFY

# PSRSALSA
export PSRSALSA=$PSRHOME/psrsalsa
export PATH=$PATH:$PSRSALSA/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PSRSALSA/src/lib

# pypsrfits
export PYPSRFITS=$PSRHOME/pypsrfits
export PYTHONPATH=$PYTHONPATH:$PYPSRFITS/install

# PRESTO
export PRESTO=$PSRHOME/presto
export PATH=$PATH:$PRESTO/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PRESTO/lib
export PYTHONPATH=$PYTHONPATH:$PRESTO/lib/python

# wapp2psrfits
export WAPP2PSRFITS=$PSRHOME/wapp2psrfits
export PATH=$PATH:$WAPP2PSRFITS

# psrfits2psrfits
export PSRFITS2PSRFITS=$PSRHOME/psrfits2psrfits
export PATH=$PATH:$PSRFITS2PSRFITS

# psrfits_utils
export PSRFITS_UTILS=$PSRHOME/psrfits_utils
export PATH=$PATH:$PSRFITS_UTILS/install/bin
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$PSRFITS_UTILS/install/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PSRFITS_UTILS/install/lib

# pyslalib
export PYSLALIB=$PSRHOME/pyslalib
export VPSR=$PSRHOME/Vpsr

# Vpsr
export PATH=$PATH:$VPSR

# GPy
export GPY=$PSRHOME/GPy
export PATH=$PATH:$GPY

## casacore measures_data
#export MEASURES_DATA=$PSRHOME/measures_data

## casa
#export CASA=$PSRHOME/casa-release-4.6.0-el6
#export PATH=$PATH:$PSRHOME/casa-release-4.6.0-el6/bin

## casacore
#export CASACORE=$PSRHOME/casacore
#export PATH=$PATH:$CASACORE/build/install/bin
#export C_INCLUDE_PATH=$C_INCLUDE_PATH:$CASACORE/build/install/include
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CASACORE/build/install/lib

## python-casacore
#export PYTHON_CASACORE=$PSRHOME/python-casacore

## makems
#export MAKEMS=$PSRHOME/makems
#export PATH=$PATH:$MAKEMS/LOFAR/installed/gnu_opt/bin
#export C_INCLUDE_PATH=$C_INCLUDE_PATH:$MAKEMS/LOFAR/installed/gnu_opt/LOFAR/installed/gnu_opt/include
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MAKEMS/LOFAR/installed/gnu_opt/lib64

## wsclean
#export WSCLEAN=$PSRHOME/wsclean-1.12
#export PATH=$PATH:$WSCLEAN/build/install/bin
#export C_INCLUDE_PATH=$C_INCLUDE_PATH:$WSCLEAN/build/install/include
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WSCLEAN/build/install/lib

# coast_guard
export COAST_GUARD=$PSRHOME/coast_guard
export PATH=$PATH:$COAST_GUARD:$COAST_GUARD/coast_guard
export COASTGUARD_CFG=$COAST_GUARD/configurations
export PYTHONPATH=$PYTHONPATH:$COAST_GUARD:$COAST_GUARD/coast_guard


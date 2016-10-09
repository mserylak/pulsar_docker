//-*-C++-*-
/***************************************************************************
 *
 *   Copyright (C) 2008 by Paul Demorest
 *   Licensed under the Academic Free License version 2.1
 *
 ***************************************************************************/

#ifndef __Telescopes_h
#define __Telescopes_h

namespace Pulsar {

  class Archive;
  class Telescope;

  //! Namespace contains general info for each telescope
  namespace Telescopes {

    //! Fill the Telescope Extension based on tempo code in Archive.
    void set_telescope_info (Telescope *t, Archive *a);

    //! Initialize the Telescope Extension with GBT info
    void GBT (Telescope* t);

    //! Initialize the Telescope Extension with GB 85-3 info
    void GB85_3 (Telescope* t);

    //! Initialize the Telescope Extension with GB 140ft info
    void GB140 (Telescope* t);

    //! Initialize the Telescope Extension with Arecibo info
    void Arecibo (Telescope* t);

    //! Initialize the Telescope Extension with Nancay info
    void Nancay (Telescope* t);

    //! Initialize the Telescope Extension with Effelsberg info
    void Effelsberg (Telescope* t);

    //! Initialize the Telescope Extension with LOFAR info
    void LOFAR (Telescope* t);

    //! Initialize the Telescope Extension with MeerKAT info
    void MeerKAT (Telescope* t);

    //! Initialize the Telescope Extension with Parkes info
    void Parkes (Telescope* t);

    //! Initialize the Telescope Extension with Jodrell Bank info
    void Jodrell (Telescope* t);

    //! Initialize the Telescope Extension with Mt Pleasant 26m info
    void MtPleasant26 (Telescope *t);

    //! Initialize the Telescope Extension with WSRT info
    void WSRT (Telescope* t);

    //! Initialize the Telescope Extension with VLA info
    void VLA (Telescope* t);

    //! Initialize the Telescope Extension with SHAO info
    void SHAO (Telescope* t);

    //! Initialize the Telescope Extension with LWA info
    void LWA (Telescope* t);
  } 

}

#endif

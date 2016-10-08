/***************************************************************************
 *
 *   Copyright (C) 2008 by Paul Demorest
 *   Licensed under the Academic Free License version 2.1
 *
 ***************************************************************************/

#include "config.h"
#include "Pulsar/Archive.h"
#include "Pulsar/Telescopes.h"
#include "Pulsar/Telescope.h"
#include "tempo++.h"
#include "coord.h"

#ifdef HAVE_TEMPO2
#include "T2Observatory.h"
#endif

#include <ostream>

void Pulsar::Telescopes::set_telescope_info (Telescope *t, Archive *a)
{
    std::string emsg;

    char oldcode = ' '; // should replace with new codes , before we run out of letters!
#ifdef HAVE_TEMPO2
    try {
        std::string newcode = Tempo2::observatory (a->get_telescope())->get_name();
        if (newcode.compare("JB_42ft")==0){
            Telescopes::Jodrell(t);
            t->set_name("JB_42ft");
            oldcode=0;
        }
        if (newcode.compare("JB_MKII")==0){
            Telescopes::Jodrell(t);
            t->set_name("JB_MKII");
            oldcode=0;
        }



        if(oldcode != -1) oldcode = Tempo2::observatory (a->get_telescope())->get_code();
    }
    catch (Error& error)
    {
        oldcode = Tempo::code( a->get_telescope() );
    }
#else

    oldcode=Tempo::code( a->get_telescope() );
#endif


    switch ( oldcode )
    {

        case 0:
            // code was set by tempo2
            break;

        case '1':
            Telescopes::GBT(t);
            // Hack to pick correct focus type for GBT
            if (a->get_centre_frequency()<1200.0)
                t->set_focus(Telescope::PrimeFocus);
            break;

        case '3':
            Telescopes::Arecibo(t);
            break;

        case '4':
            Telescopes::MtPleasant26(t);
            break;

        case '6':
        case 'c':
            Telescopes::VLA(t);
            break;

        case '7':
            Telescopes::Parkes(t);
            break;

        case '8':
            Telescopes::Jodrell(t);
            break;

        case 'a':
            Telescopes::GB140(t);
            break;

        case 'b':
            Telescopes::GB85_3(t);
            break;

        case 'f':
            Telescopes::Nancay(t);
            break;

        case 'g':
            Telescopes::Effelsberg(t);
            break;

        case 't':
            Telescopes::LOFAR(t);
            break;

        case 'm':
            Telescopes::MeerKAT(t);
            break;

        case 'i':
            Telescopes::WSRT(t);
            break;

        case 's':
            Telescopes::SHAO(t);
            break;

        case 'x':
            Telescopes::LWA(t);
            break;

        default: 
            // Unknown code, throw error after calling Telecope::set_coordinates
            emsg = "Unrecognized telescope code (" + a->get_telescope() + ")";
            break;
    }

    try
    {
        t->set_coordinates();
    }
    catch (Error& error)
    {
        throw error += "Pulsar::Telescopes::set_telescope_info";
    }

    if (!emsg.empty())
        throw Error (InvalidParam, "Pulsar::Telescopes::set_telescope_info", emsg);
}

// Info for each telescope below.  Maybe the coordinate setting
// routine could be incorporated here, to have a centralized 
// location for all this.  Also would be good to not have to use
// the Tempo codes explicitly below.

void Pulsar::Telescopes::GBT(Telescope *t) 
{
    t->set_name("GBT");
    t->set_mount(Telescope::Horizon);
    t->set_primary(Telescope::Parabolic);
    t->set_focus(Telescope::Gregorian); // XXX only true for L-band and up
}

void Pulsar::Telescopes::Arecibo(Telescope *t)
{
    t->set_name("Arecibo");
    t->set_mount(Telescope::Horizon);
    t->set_primary(Telescope::Spherical);
    t->set_focus(Telescope::Gregorian); // What about CH receivers?
}

void Pulsar::Telescopes::GB140(Telescope *t)
{
    t->set_name("GB 140ft");
    t->set_mount(Telescope::Equatorial);
    t->set_primary(Telescope::Parabolic);
    t->set_focus(Telescope::PrimeFocus); 
}

void Pulsar::Telescopes::GB85_3(Telescope *t)
{
    t->set_name("GB 85-3");
    t->set_mount(Telescope::Equatorial);
    t->set_primary(Telescope::Parabolic);
    t->set_focus(Telescope::PrimeFocus); 
}

void Pulsar::Telescopes::Nancay(Telescope *t)
{
    t->set_name("Nancay");
    t->set_mount(Telescope::KrausType);
    t->set_primary(Telescope::Spherical);
    t->set_focus(Telescope::Gregorian); 
}

void Pulsar::Telescopes::Effelsberg(Telescope *t)
{
    t->set_name("Effelsberg");
    t->set_mount(Telescope::Horizon);
    t->set_primary(Telescope::Parabolic);
    t->set_focus(Telescope::Gregorian); // XXX also varies by receiver
}

void Pulsar::Telescopes::LOFAR(Telescope *t)
{
    t->set_name ("LOFAR");
    // XXX what about other settings? mount, focus,...
}

void Pulsar::Telescopes::MeerKAT(Telescope *t)
{
    t->set_name ("MeerKAT");
    t->set_mount (Telescope::Horizon);
    t->set_primary (Telescope::Parabolic);
    t->set_focus(Telescope::Gregorian);
}

void Pulsar::Telescopes::MtPleasant26(Telescope *t)
{
    t->set_name ("Hobart");
    t->set_mount (Telescope::Meridian);
    t->set_primary (Telescope::Parabolic);
    t->set_focus (Telescope::PrimeFocus);
}

void Pulsar::Telescopes::Parkes(Telescope *t)
{
    t->set_name ("Parkes");
    t->set_mount (Telescope::Horizon);
    t->set_primary (Telescope::Parabolic);
    t->set_focus (Telescope::PrimeFocus);
}

void Pulsar::Telescopes::Jodrell(Telescope *t)
{
    t->set_name ("Jodrell");
    t->set_mount (Telescope::Horizon);
    t->set_primary (Telescope::Parabolic);
    t->set_focus (Telescope::PrimeFocus);
}

void Pulsar::Telescopes::WSRT(Telescope *t)
{
    t->set_name("WSRT");
    t->set_mount(Telescope::Equatorial);
    t->set_primary(Telescope::Parabolic);
    t->set_focus(Telescope::PrimeFocus);
}

void Pulsar::Telescopes::VLA(Telescope *t)
{
    t->set_name("VLA");
    t->set_mount(Telescope::Horizon);
    t->set_primary(Telescope::Parabolic);
    t->set_focus(Telescope::Gregorian);
}

void Pulsar::Telescopes::SHAO(Telescope *t)
{
    t->set_name("SHAO");
    t->set_mount(Telescope::Horizon);
    t->set_primary(Telescope::Parabolic);
    t->set_focus(Telescope::Gregorian);
}

void Pulsar::Telescopes::LWA(Telescope *t)
{
    t->set_name("LWA");
    // XXX Not sure if these are correct...
    t->set_mount(Telescope::Fixed);
    t->set_focus(Telescope::PrimeFocus);
}


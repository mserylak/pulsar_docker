
/***************************************************************************
 *
 *   Copyright (C) 2008 by Willem van Straten
 *   Licensed under the Academic Free License version 2.1
 *
 ***************************************************************************/

#include "tempo_impl.h"

#include <string.h>
#include <assert.h>

using namespace std;

static void add_alias (const string& itoa_code, const string& alias);

static int default_aliases ()
{
  add_alias ("GB", "gbt");
  add_alias ("GB", "green bank");
  add_alias ("GB", "greenbank");

  add_alias ("G1", "gb43m");
  add_alias ("G1", "gb 140ft");
  add_alias ("G1", "gb140ft");

  add_alias ("G8", "gb85-3");
  add_alias ("G8", "gb853");
  add_alias ("G8", "gb 85-3");

  add_alias ("NA", "atca");
  add_alias ("NA", "narrabri");

  add_alias ("AO", "arecibo");

  add_alias ("HO", "hobart");

  add_alias ("NS", "urumqi");

  add_alias ("TD", "tid");
  add_alias ("TD", "tidbinbilla");
  add_alias ("TD", "DSS43");
  add_alias ("TD", "DSS 43");

  add_alias ("PK", "pks");
  add_alias ("PK", "parkes");

  add_alias ("JB", "jodrell");
  add_alias ("JB", "jodrell bank");
  add_alias ("JB", "lovell");

  add_alias ("VL", "vla");

  add_alias ("BO", "northern cross");

  add_alias ("MO", "most");

  add_alias ("NC", "nancay");

  add_alias ("EF", "effelsberg");

  add_alias ("LF", "LOFAR");
  add_alias ("LF", "lofar");
  add_alias ("FL", "FR606");
  add_alias ("DL", "DE601");
  add_alias ("D3", "DE603");
  add_alias ("D5", "DE605");
  add_alias ("UL", "UK608");

  add_alias ("WT", "wsrt");
  add_alias ("WT", "westerbork");

  add_alias ("GM", "gmrt");

  add_alias ("SH", "shao");
  add_alias ("SH", "shao65");

  add_alias ("LW", "lwa");
  add_alias ("LW", "lwa1");

  add_alias ("PV", "pico veleta");

  // Sardinia Radio Telescope
  add_alias ("SR", "srt");

  // MeerKAT
  add_alias ("MK", "meerkat");
  add_alias ("MK", "MeerKAT");
  add_alias ("MK", "MEERKAT");

  return 1;
}

static int init = default_aliases();

class aliases
{
public:
  aliases (const string& code, const string& alias)
  {
    itoa_code = code;
    aka.push_back (alias);
  }

  bool match (const string& name) const
  {
    for (unsigned i=0; i<aka.size(); i++)
      if (strcasecmp (aka[i].c_str(), name.c_str()) == 0)
        return true;
    return false;
  }

  string itoa_code;
  vector<string> aka;
};

static vector<aliases>* itoa_aliases = 0;

string Tempo::itoa_code (const string& telescope_name)
{
  assert (itoa_aliases != 0);

  const vector<aliases>& itoa = *itoa_aliases;

  for (unsigned i=0; i<itoa.size(); i++)
    if (itoa[i].match( telescope_name ))
      return itoa[i].itoa_code;

  cerr << "itoa_code no alias found for " << telescope_name << endl;

  return string();
}

void add_alias (const string& itoa_code, const string& alias)
{
  if (!itoa_aliases)
    itoa_aliases = new vector<aliases>;

  vector<aliases>& itoa = *itoa_aliases;

  for (unsigned i=0; i<itoa.size(); i++)
    if (itoa[i].itoa_code == itoa_code)
    {
      itoa[i].aka.push_back (alias);
      return;
    }

  itoa.push_back ( aliases( itoa_code, alias ) );
}



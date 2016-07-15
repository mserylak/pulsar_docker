"""
This file contains various utility code that is used in various 
parts of the CoastGuard timing pipeline.

Patrick Lazarus, Nov. 10, 2011
"""
import os
import os.path
import warnings
import hashlib
import glob
import optparse
import sys
import subprocess
import types
import inspect
import datetime
import argparse
import string
import tempfile
import stat

import numpy as np

from coast_guard import config
from coast_guard import errors
from coast_guard import colour
from coast_guard import log

header_param_types = {'freq': float, \
                      'length': float, \
                      'bw': float, \
                      'chbw': float, \
                      'mjd': float, \
                      'intmjd': int, \
                      'fracmjd': float, \
                      'backend': str, \
                      'rcvr': str, \
                      'telescop': str, \
                      'name': str, \
                      'nchan': int, \
                      'npol': int, \
                      'nbin': int, \
                      'nsub': int, \
                      'tbin': float, \
                      'period': float, \
                      'dm': float, \
                      'pol_c': bool}

site_to_telescope = {'i': 'WSRT',
                     'wt': 'WSRT',
                     'wsrt': 'WSRT',
                     'westerbork': 'WSRT',
                     'g': 'Effelsberg', 
                     'ef': 'Effelsberg',
                     'eff': 'Effelsberg',
                     'effelsberg': 'Effelsberg',
                     '8': 'Jodrell',
                     'jb': 'Jodrell',
                     'jbo': 'Jodrell',
                     'jodrell bank': 'Jodrell',
                     'jodrell bank observatory': 'Jodrell',
                     'lovell': 'Jodrell',
                     'f': 'Nancay',
                     'nc': 'Nancay',
                     'ncy': 'Nancay',
                     'nancay': 'Nancay',
                     'sardinia': 'SRT',
                     'srt': 'SRT',
                     'z': 'SRT',
                     'parkes':'Parkes',
                     '7':'Parkes', 
                     'arecibo':'Arecibo', 
                     'ao':'Arecibo',
                     'ao 305m':'Arecibo', 
                     '3':'Arecibo',
                     'lofar':'LOFAR',
                     'kat7': 'KAT7',
                     'k7': 'KAT7',
                     'k': 'KAT7',
                     'm': 'MEERKAT',
                     'mk': 'MEERKAT',
                     'MK': 'MEERKAT',
                     'meerkat': 'MEERKAT',
                     'MeerKAT': 'MEERKAT',
                     'j': 'EMBRACE',
                     'EE': 'EMBRACE',
                     'w': 'UTR-2',
                     'U2': 'UTR-2',
                     'EFlfrlba': 'DE601LBA',
                     'EFlfrlbh': 'DE601LBH',
                     'EFlfrhba': 'DE601HBA',
                     'EFlfr': 'DE601',
                     'de601': 'DE601',
                     'UWlfrlba': 'DE602LBA',
                     'UWlfrlbh': 'DE602LBH',
                     'UWlfrhba': 'DE602HBA',
                     'UWlfr': 'DE602',
                     'de602': 'DE602',
                     'TBlfrlba': 'DE603LBA',
                     'TBlfrlbh': 'DE603LBH',
                     'TBlfrhba': 'DE603HBA',
                     'TBlfr': 'DE603',
                     'de603': 'DE603',
                     'POlfrlba': 'DE604LBA',
                     'POlfrlbh': 'DE604LBH',
                     'POlfrhba': 'DE604HBA',
                     'POlfr': 'DE604',
                     'de604': 'DE604',
                     'JUlfrlba': 'DE605LBA',
                     'JUlfrlbh': 'DE605LBH',
                     'JUlfrhba': 'DE605HBA',
                     'JUlfr': 'DE605',
                     'de605': 'DE605',
                     'FRlfrlba': 'FR606LBA',
                     'FRlfrlbh': 'FR606LBH',
                     'FRlfrhba': 'FR606HBA',
                     'FRlfr': 'FR606',
                     'fr606': 'FR606',
                     'u': 'FR606',
                     'ONlfrlba': 'SE607LBA',
                     'ONlfrlbh': 'SE607LBH',
                     'ONlfrhba': 'SE607HBA',
                     'ONlfr': 'SE607',
                     'se607': 'SE607',
                     'UKlfrlba': 'UK608LBA',
                     'UKlfrlbh': 'UK608LBH',
                     'UKlfrhba': 'UK608HBA',
                     'UKlfr': 'UK608',
                     'uk608': 'UK608',
                     'NDlfrlba': 'DE609LBA',
                     'NDlfrlbh': 'DE609LBH',
                     'NDlfrhba': 'DE609HBA',
                     'NDlfr': 'DE609',
                     'de609': 'DE609',
                     'v': 'eff_psrix',
                     'ex': 'eff_psrix',
                     'effix': 'eff_psrix',
                     'psrix': 'eff_psrix',
                     'asterix': 'eff_psrix',
                     'eff_psrix': 'eff_psrix'}

# A cache for pulsar J-names
jname_cache = {}
# A cache for pulsar preferred names
prefname_cache = {}
# A cache for version IDs
versionid_cache = {}
# A cache for fluxcal names
__fluxcals = None
# A cache for psrchive configurations
__psrchive_configs = None

def get_psrchive_configs():
    global __psrchive_configs
    if __psrchive_configs is None:
        __psrchive_configs = {}
        cmd = ['psrchive_config']
        stdout, stderr = execute(cmd)
        for line in stdout.split('\n'):
            line, sep, comment = line.partition('#')
            line = line.strip()
            if not line:
                continue
            key, val = line.split('=')
            __psrchive_configs[key.strip()] = val.strip()
    return __psrchive_configs

def read_fluxcal_names(fluxcalfn=None):
    """Read names of flux calibrators from PSRCHIVE configuration
        file and return a list.

        Input:
            fluxcalfn: The PSRCHIVE fluxcal.cfg file.

        Output:
            fluxcals: A list of names of flux calibrators.
                Aliases are included.
    """
    if fluxcalfn is None:
        fluxcalfn = config.fluxcal_cfg
    global __fluxcals
    if __fluxcals is None:
        __fluxcals = []
        with open(fluxcalfn, 'r') as ff:
            for line in ff:
                line = line.partition('#')[0].strip()
                if not line:
                    continue
                split = line.split()
                if line.startswith("&"):
                    # Second format
                    __fluxcals.append(split[0][1:])
                elif line.lower().startswith("aka"):
                    # Alias
                    __fluxcals.append(split[1])
                else:
                    # First format
                    __fluxcals.append(split[0])
    return __fluxcals


def show_progress(iterator, width=0, tot=None):
    """Wrap an iterator so that a progress counter is printed
        as we iterate.

        Inputs:
            iterator: The object to iterate over.
            width: The width of the progress bar.
                (Default: Don't show a progress bar, only the percentage)
            tot: The total number of iterations.
                (Default: Use len(iterator) to determine 
                    total number of iterations)

        Outputs:
            None
    """
    if tot is None:
        tot = len(iterator)
    old = -1
    curr = 1
    for toreturn in iterator:
        if config.show_progress:
            progfrac = curr/float(tot)
            progpcnt = int(100*progfrac)
            if progpcnt > old:
                bar = "["*bool(width) + \
                        "="*int(width*progfrac+0.5) + \
                        " "*int(width*(1-progfrac)+0.5) + \
                        "]"*bool(width)
                old = progpcnt
                sys.stdout.write("     " + bar + " %d %% \r" % progpcnt)
                sys.stdout.flush()
            curr += 1
        yield toreturn
    if config.show_progress:
        print "Done"


def set_warning_mode(mode=None, reset=True):
    """Add a simple warning filter.
        
        Inputs:
            mode: The action to use for warnings.
                (Default: take value of 'warnmode' configuration.
            reset: Remove warning filters previously set.

        Outputs:
            None
    """
    if mode is None:
        mode = config.warnmode
    if reset:
        warnings.resetwarnings()
    warnings.simplefilter(mode)


def log_message(msg, level='info'):
    """Log a message

        Inputs:
            msg: The message to print.
            level: The logging level (see python's logging module) 
                (Default: info)

        Outputs:
            None
    """
    fn, lineno, funcnm = inspect.stack()[1][1:4]
    log.log("Log message: [%s:%d - %s(...)]\n%s" % \
            (os.path.split(fn)[-1], lineno, funcnm, msg), level)


def print_info(msg, level=1):
    """Print an informative message if the current verbosity is
        higher than the 'level' of this message.

        The message will be colourized as 'info'.

        Inputs:
            msg: The message to print.
            level: The verbosity level of the message.
                (Default: 1 - i.e. don't print unless verbosity is on.)

        Outputs:
            None
    """
    fn, lineno, funcnm = inspect.stack()[1][1:4]
    if config.log_verbosity >= level:
        log.log("verbosity: %d [%s:%d - %s(...)]\n%s" % \
                (level, os.path.split(fn)[-1], lineno, funcnm, msg), 'info')

    if config.verbosity >= level:
        if config.excessive_verbosity:
            # Get caller info
            colour.cprint("INFO (level: %d) [%s:%d - %s(...)]:" % 
                    (level, os.path.split(fn)[-1], lineno, funcnm), 'infohdr')
            msg = msg.replace('\n', '\n    ')
            colour.cprint("    %s" % msg, 'info')
        else:
            colour.cprint(msg, 'info')


def print_debug(msg, category, stepsback=1):
    """Print a debugging message if the given debugging category
        is turned on.

        The message will be colourized as 'debug'.

        Inputs:
            msg: The message to print.
            category: The debugging category of the message.
            stepsback: The number of steps back into the call stack
                to get function calling information from. 
                (Default: 1).

        Outputs:
            None
    """
    if config.debug.is_on(category):
        fn, lineno, funcnm = inspect.stack()[stepsback][1:4]
        log.log("mode: %s [%s:%d - %s(...)]\n%s" % \
                (category.upper(), os.path.split(fn)[-1], lineno, 
                    funcnm, msg), 'debug')
        if config.helpful_debugging:
            # Get caller info
            to_print = colour.cstring("DEBUG %s [%s:%d - %s(...)]:\n" % \
                        (category.upper(), os.path.split(fn)[-1], lineno, funcnm), \
                            'debughdr')
            msg = msg.replace('\n', '\n    ')
            to_print += colour.cstring("    %s" % msg, 'debug')
        else:
            to_print = colour.cstring(msg, 'debug')
        sys.stderr.write(to_print + '\n')
        sys.stderr.flush()


def extract_parfile(arfn):
    """Given an archive file extract its ephemeris and return
        it as a string

        Input:
            arfn: Name of archive file.

        Output:
            parfn: Name of (temporary) parfile.
    """
    cmd = ['vap', '-E', arfn]
    stdoutstr, stderrstr = execute(cmd)
    if "has no ephemeris" in stdoutstr:
        raise errors.InputError("Input archive (%s) has no parfile. " % arfn)
    print_info("Extracted parfile from %s" % arfn, 3)
    return stdoutstr


def get_norm_parfile(arfn):
    """Given an archive file extract its ephemeris and normalise it
        by removing empty lines, fit-flags, uncertainties, and
        polyco-creation related lines (ie "TZ*")

        Input:
            arfn: Name of archive file.

        Output:
            parfn: Name of (temporary) parfile.
    """
    return normalise_parfile(extract_parfile(arfn))


def normalise_parfile(par):
    """Given a parfile normalise it by removing empty
        lines, fit-flags, uncertainties, 
        polyco-creation related lines (ie "TZ*")
        JUMPs, EFACs, EQUADs, DM models and Red noise models.
        Input:
            par: This can be either:
                a) path to parfile
                b) Contents of parfile as a single string
                c) A list of parfile lines (ie a list of strings)

        Output:
            parfn: Name of (temporary) parfile.
    """
    if isinstance(par, types.StringTypes):
        # Assume input is
        if os.path.isfile(par):
            # Assume input is par filename
            lines = open(par, 'r').readlines()
        else:
            # Assume input is parfile contents
            lines = par.split('\n')
    else:
        # Assume input is list of lines
        lines = par
    parlines = ["% -15s %s" % tuple(line.split()[:2]) for line
                in lines
                if line.strip() and ("TZ" not in line)
                    and (not line.startswith("TN"))
                    and (not line.startswith("JUMP"))]
    
    # Make a temporary file for the parfile
    tmpfd, tmpfn = tempfile.mkstemp(suffix='.par', dir=config.tmp_directory)
    tmpfile = os.fdopen(tmpfd, 'w')
    tmpfile.write("\n".join(parlines)+"\n")
    tmpfile.close()
    print_info("Normalised parfile output to %s." % tmpfn, 3)
    return tmpfn


def get_md5sum(fn, block_size=16*8192):
    """Compute and return the MD5 sum for the given file.
        The file is read in blocks of 'block_size' bytes.

        Inputs:
            fn: The name of the file to get the md5 for.
            block_size: The number of bytes to read at a time.
                (Default: 16*8192)

        Output:
            md5: The hexidecimal string of the MD5 checksum.
    """
    f = open(fn, 'rb')
    md5 = hashlib.md5()
    block = f.read(block_size)
    while block:
        md5.update(block)
        block = f.read(block_size)
    f.close()
    return md5.hexdigest()


def get_version_id(db):
    """Get the version ID number from the database.
        If the version number isn't in the database, add it.

        Input:
            db: A database connection object.

        Output:
            version_id: The version ID for the current pipeline/psrchive
                combination.
    """
    # Check to make sure the repositories are clean
    is_gitrepo_dirty(config.coastguard_repo)
    is_gitrepo_dirty(config.psrchive_repo)
    # Get git hashes
    coastguard_githash = get_githash(config.coastguard_repo)
    if is_gitrepo(config.psrchive_repo):
        psrchive_githash = get_githash(config.psrchive_repo)
    else:
        warnings.warn("PSRCHIVE directory (%s) is not a git repository! " \
                        "Falling back to 'psrchive --version' for version " \
                        "information." % config.psrchive_repo, \
                        errors.CoastGuardWarning)
        cmd = ["psrchive", "--version"]
        stdout, stderr = execute(cmd)
        psrchive_githash = stdout.strip()
  
    if (coastguard_githash, psrchive_githash) in versionid_cache:
        version_id = versionid_cache[(coastguard_githash, psrchive_githash)]
    else:
        import sqlalchemy as sa
        try:
            # Take a 'shoot-first-ask-questions-later' approach.
            # Try to insert a new version entry into the database
            # if the combination of Coast Guard githas and PSRCHIVE
            # githash already exist the UNIQUE constraint won't be 
            # satisfied and a sa.exc.IntegrityError will be thrown
            # catch it and select the appropriate version_id from
            # the database
            with db.transaction() as conn:
                # Insert the current versions
                ins = db.versions.insert().\
                            values(cg_githash=coastguard_githash, \
                                    psrchive_githash=psrchive_githash)
                result = conn.execute(ins)
                # Get the newly add version ID
                version_id = result.inserted_primary_key[0]
                result.close()
        except sa.exc.IntegrityError:
            with db.transaction() as conn:
                # Get the version_id from the DB
                select = db.select([db.versions.c.version_id]).\
                            where((db.versions.c.cg_githash==coastguard_githash) & \
                                  (db.versions.c.psrchive_githash==psrchive_githash))
                result = conn.execute(select)
                rows = result.fetchall()
                result.close()
            if len(rows) == 1:
                version_id = rows[0].version_id
            else:
                raise errors.DatabaseError("Bad number of rows (%d) in versions " \
                                "table with CoastGuard githash='%s' and " \
                                "PSRCHIVE githash='%s'!" % \
                                (len(rows), coastguard_githash, psrchive_githash))
        # Add version ID to cache
        versionid_cache[(coastguard_githash, psrchive_githash)] = version_id
    return version_id


def get_githash(repodir=None):
    """Get the git hash of a repository.

        Inputs:
            repodir: Directory containing repository to check.

        Output:
            githash: The githash
    """
    if repodir is None:
        # Use directory containing this file
        repodir = os.path.split(__file__)[0]
    if is_gitrepo_dirty(repodir):
        warnings.warn("Git repository (%s) has uncommitted changes!" % \
                        repodir, errors.LoggedCoastGuardWarning)
    stdout, stderr = execute("git rev-parse HEAD", dir=repodir)
    githash = stdout.strip()
    return githash


def is_gitrepo(repodir):
    """Return True if the given dir is a git repository.

        Input:
            repodir: The location of the git repository.

        Output:
            is_git: True if directory is part of a git repository. False otherwise.
    """
    print_info("Checking if directory '%s' contains a Git repo..." % repodir, 2)
    try:
        cmd = ["git", "rev-parse"]
        stdout, stderr = execute(cmd, dir=repodir, \
                                    stderr=open(os.devnull))
    except errors.SystemCallError:
        # Exit code is non-zero
        return False
    else:
        # Success error code (i.e. dir is in a git repo)
        return True


def is_gitrepo_dirty(repodir=None):
    """Return True if the git repository has local changes.

        Inputs:
            repodir: Directory containing repository to check.

        Output:
            is_dirty: True if git repository has local changes. False otherwise.
    """
    if repodir is None:
        # Use directory containing this file
        repodir = os.path.split(__file__)[0]
    try:
        stdout, stderr = execute("git diff --quiet", dir=repodir)
    except errors.SystemCallError:
        # Exit code is non-zero
        return True
    else:
        # Success error code (i.e. no differences)
        return False


def get_header_vals(fn, hdritems):
    """Get a set of header params from the given file.
        Returns a dictionary.

        Inputs:
            fn: The name of the file to get params for.
            hdritems: List of parameters (recognized by vap) to fetch.

        Output:
            params: A dictionary. The keys are values requested from 'vap'
                the values are the values reported by 'vap'.
    """
    hdrstr = ",".join(hdritems)
    if '=' in hdrstr:
        raise ValueError("'hdritems' passed to 'get_header_vals' " \
                         "should not perform and assignments!")
    cmd = ["vap", "-n", "-c", hdrstr, fn]
    outstr, errstr = execute(cmd)
    outvals = outstr.split()[1:] # First value is filename (we don't need it)
    if errstr:
        raise errors.SystemCallError("The command: %s\nprinted to stderr:\n%s" % \
                                (cmd, errstr))
    elif len(outvals) != len(hdritems):
        raise errors.SystemCallError("The command: %s\nreturn the wrong " \
                            "number of values. (Was expecting %d, got %d.)" % \
                            (cmd, len(hdritems), len(outvals)))
    params = {}
    for key, val in zip(hdritems, outvals):
        if val == "INVALID":
            raise errors.SystemCallError("The vap header key '%s' " \
                                            "is invalid!" % key)
        elif val == "*" or val == "UNDEF":
            warnings.warn("The vap header key '%s' is not " \
                            "defined in this file (%s)" % (key, fn), \
                            errors.LoggedCoastGuardWarning)
            params[key] = None
        elif val == '*error*':
            raise errors.SystemCallError("The vap header key '%s' returned " \
                            "'*error*'!" % key)
        else:
            # Get param's type to cast value
            caster = header_param_types.get(key, str)
            params[key] = caster(val)
    return params


def get_archive_snr(fn):
    """Get the SNR of an archive using psrstat.
        Fully scrunch the archive first.

        Input:
            fn: The name of the archive.

        Output:
            snr: The signal-to-noise ratio of the fully scrunched archive.
    """
    cmd = "psrstat -Qq -j DTFp -c 'snr' %s" % fn
    outstr, errstr = execute(cmd)
    snr = float(outstr)
    return snr


def exclude_files(file_list, to_exclude):
    return [f for f in file_list if f not in to_exclude]


def execute(cmd, stdout=subprocess.PIPE, stderr=sys.stderr, dir=None): 
    """Execute the command 'cmd' after logging the command
        to STDOUT. Execute the command in the directory 'dir',
        which defaults to the current directory is not provided.

        Output standard output to 'stdout' and standard
        error to 'stderr'. Both are strings containing filenames.
        If values are None, the out/err streams are not recorded.
        By default stdout is subprocess.PIPE and stderr is sent 
        to sys.stderr.

        Returns (stdoutdata, stderrdata). These will both be None, 
        unless subprocess.PIPE is provided.
    """
    # Log command to stdout
    print_debug("'%s'" % cmd, 'syscalls', stepsback=2)

    stdoutfile = False
    stderrfile = False
    if type(stdout) == types.StringType:
        stdout = open(stdout, 'w')
        stdoutfile = True
    if type(stderr) == types.StringType:
        stderr = open(stderr, 'w')
        stderrfile = True
    
    # Run (and time) the command. Check for errors.
    if type(cmd) == types.StringType:
        shell=True
    else:
        shell=False
    pipe = subprocess.Popen(cmd, shell=shell, cwd=dir, \
                            stdout=stdout, stderr=subprocess.PIPE)
    (stdoutdata, stderrdata) = pipe.communicate()
    
    # Close file objects, if any
    if stdoutfile:
        stdout.close()
    if stderrfile:
        stderr.write(stderrdata)
        stderr.close()
    
    retcode = pipe.returncode 
    if retcode < 0:
        raise errors.SystemCallError("Execution of command (%s) " \
                                    "terminated by signal (%s)!" % \
                                (cmd, -retcode))
    elif retcode > 0:
        raise errors.SystemCallError("Execution of command (%s) failed " \
                                "with status (%s)!\nError output:\n%s" % \
                                (cmd, retcode, stderrdata))
    else:
        # Exit code is 0, which is "Success". Do nothing.
        pass

    return (stdoutdata, stderrdata)


def group_by_ctr_freq(infns):
    """Given a list of input files group them according to their
        centre frequencies.

        Input:
            infns: A list of input ArchiveFile objects.

        Outputs:
            grouped: A dict where each key is the centre frequency
                in MHz and where each value is a list of archive
                names with all the same centre frequency.

    """
    ctr_freqs = np.asarray([fn['freq'] for fn in infns])
    groups_dict = {}
    for ctr_freq in np.unique(ctr_freqs):
        # Collect the input files that are part of this sub-band
        indices = np.argwhere(ctr_freqs==ctr_freq)
        groups_dict[ctr_freq] = [infns[ii] for ii in indices]
    return groups_dict


def group_subints(infns):
    """Given a list of input subint files group them.
        This function assumes files with the same name exist in
        seperate subdirectories. Each subdirectory corresponds to
        a subband. Only subints from the same time that appear in
        all subbands are included in the groups, others are discarded.

        Input:
            infns: A list of input PSRCHIVE subints.

            grouped: A dict where each key is the centre frequency
                in MHz and where each value is a list of archive
                names with all the same centre frequency.
    """
    groups_dict = {}

    for infn in infns:
        dir, fn = os.path.split(infn.fn)
        groups_dict.setdefault(dir, set()).add(fn)

    # Determine intersection of all subbands
    intersection = set.intersection(*groups_dict.values())
    union = set.union(*groups_dict.values())
    
    print "Number of subints not present in all subbands: %s" % \
                len(union-intersection)

    subbands_dict = {}
    for infn in infns:
        dir, fn = os.path.split(infn.fn)
        if fn in intersection:
            subbands_dict.setdefault(float(infn['freq']), list()).append(infn)
    return subbands_dict


def enforce_file_consistency(infns, param, expected=None, discard=False, warn=False):
    """Check that all files have the same value for param
        in their header.

        Inputs:
            infns: The ArchiveFile objects that should have consistent header params.
            param: The header param to use when checking consistency.
            expected: The expected value. If None use the mode.
            discard: A boolean value. If True, files with param not matching
                the mode will be discarded. (Default: False)
            warn: A boolean value. If True, issue a warning if files are
                inconsistent. If False, raise an error. (Default: raise errors).

        Output:
            outfns: (optional - only if 'discard' is True) A list of consistent files.
    """
    params = [infn[param] for infn in infns]
    if expected is None:
        mode, count = get_mode(params)
    else:
        mode = expected
        count = len([p for p in params if p==expected])

    if discard:
        if count != len(infns):
            outfns = [fn for (fn, p) in zip(infns, params) if p==mode]
            if count != len(outfns):
                raise ValueError("Wrong number of files discarded! (%d != %d)" % \
                                    (len(infns)-count, len(infns)-len(outfns)))
            print_info("Check of header parameter '%s' has caused %d files " \
                        "with value != '%s' to be discarded" % \
                                (param, len(infns)-count, mode), 2)
            return outfns
        else:
            return infns
    else:
        if count != len(infns):
            msg = "There are %d files where the value of '%s' doesn't " \
                    "match other files (modal value: %s)" % \
                            (len(infns)-count, param, mode)
            if warn:
                warnings.warn(msg)
            else:
                raise errors.BadFile(msg)


def get_mode(vals):
    counts = {}
    for val in vals:
        count = counts.setdefault(val, 0)
        counts[val] = 1+count

    maxcount = max(counts.values())
    for key in counts.keys():
        if counts[key] == maxcount:
            return key, counts[key]


def group_subbands(infns):
    """Group subband files according to their base filename 
        (i.e. ignoring their extension).

        Input:
            infns: A list of input file names.

        Output:
            groups: A list of tuples, each being a group of subband
                files to combine.
    """
    get_basenm = lambda arf: os.path.splitext(os.path.split(arf.fn)[-1])[0]
    basenms = set([get_basenm(infn) for infn in infns])

    print_debug("Base names: %s" % ", ".join(basenms), 'grouping')

    groups = []
    for basenm in basenms:
        groups.append([arf for arf in infns if get_basenm(arf)==basenm])
    return groups


def get_files_from_glob(option, opt_str, value, parser):
    """optparse Callback function to turn a glob expression into
        a list of input files.

        Inputs:
            options: The Option instance.
            opt_str: The option provided on the command line.
            value: The value provided to the command line option.
            parser: The OptionParser.

        Outputs:
            None
    """
    glob_file_list = getattr(parser.values, option.dest)
    glob_file_list.extend(glob.glob(value))


def get_flux_density(name):
    """Use 'psrcat' program to find the flux density of the given pulsar.

        Input:
            name: Name of the pulsar.

        Output:
            flux: Flux density of the pulsar.
    """
    search = name
    if not name[0] in ('J', 'B') and len(name)==7:
        # Could be B-name, or truncated J-name. Add wildcard at end just in case.
        search += '*'
    try:   
        cmd = ['psrcat', '-nohead', '-nonumber', '-c', 'S1400', \
                        '-null', '', search]
        stdout, stderr = execute(cmd)
        lines = [line for line in stdout.split('\n') \
                    if line.strip() and not line.startswith("WARNING:")]
        fluxes = [line.strip().split() for line in lines]
    except errors.SystemCallError:
        warnings.warn("Error occurred while trying to run 'psrcat' " \
                        "to get L-band flux density for '%s'" % \
                        name, \
                        errors.CoastGuardWarning)
        fluxes = []
    
    if len(fluxes) == 1:
        if len(fluxes[0]) != 3:
            raise ValueError("There aren't 3 elements returned by psrcat when looking for S1400 for %s:\n%s" % (search, fluxes))
        flux = (fluxes[0][0], fluxes[0][1], fluxes[0][2])
    elif len(fluxes) == 0:
        warnings.warn("No L-band flux density found in psrcat for %s. " % \
                        name, \
                        errors.CoastGuardWarning)
        flux = None
    elif len(names) > 1:
        warnings.warn("Pulsar name '%s' is ambiguous. It has " \
                        "multiple matches (%d) in psrcat " \
                        "(search pattern used: '%s'):\n%s" % \
                (srcname, len(names), search, '\n'.join(lines)), \
                                errors.CoastGuardWarning)
        flux = None
    return flux


def get_spectral_index(name):
    """Use 'psrcat' program to find the spectral index of the given pulsar.

        Input:
            name: Name of the pulsar.

        Output:
            spindex: Spectral of the pulsar.
    """
    search = name
    if not name[0] in ('J', 'B') and len(name)==7:
        # Could be B-name, or truncated J-name. Add wildcard at end just in case.
        search += '*'
    try:   
        cmd = ['psrcat', '-nohead', '-nonumber', '-c', 'SPINDX', \
                        '-o', 'short', '-null', '', search]
        stdout, stderr = execute(cmd)
        lines = [line for line in stdout.split('\n') \
                    if line.strip() and not line.startswith("WARNING:")]
        spinds = [float(line.strip()) for line in lines]
    except errors.SystemCallError:
        warnings.warn("Error occurred while trying to run 'psrcat' " \
                        "to get prefname for '%s'" % name, \
                        errors.CoastGuardWarning)
        spinds = []
    
    if len(spinds) == 1:
        spindex = spinds[0]
    elif len(spinds) == 0:
        warnings.warn("No spectral index found in psrcat for %s. " % name, \
                        errors.CoastGuardWarning)
        spindex = None
    elif len(names) > 1:
        warnings.warn("Pulsar name '%s' is ambiguous. It has " \
                        "multiple matches (%d) in psrcat " \
                        "(search pattern used: '%s'):\n%s" % \
                (srcname, len(names), search, '\n'.join(lines)), \
                                errors.CoastGuardWarning)
        spindex = None
    return spindex


def get_jname(name):
    """Use 'psrcat' program to find the J-name of the given pulsar.

        Input:
            name: Name of the pulsar.

        Output:
            jname: J-name of the pulsar.
    """
    global jname_cache
        
    # Strip '_R' tail if present. It is added back on just before
    # returning the J-name
    if name.endswith("_R"):
        # Is a calibration observation
        tail = "_R"
        srcname = name[:-2]
    else:
        # Is not a cal obs
        tail = ""
        srcname = name

    if srcname in jname_cache:
        jname = jname_cache[srcname]
    else:
        search = srcname
        if not srcname[0] in ('J', 'B') and len(srcname)==7:
            # Could be B-name, or truncated J-name. Add wildcard at end just in case.
            search += '*'
        try:   
            cmd = ['psrcat', '-nohead', '-nonumber', '-c', 'PSRJ', \
                            '-o', 'short', '-null', '', search]
            stdout, stderr = execute(cmd)
            lines = [line for line in stdout.split('\n') \
                        if line.strip() and not line.startswith("WARNING:")]
            names = [line.strip().split() for line in lines]
        except errors.SystemCallError:
            warnings.warn("Error occurred while trying to run 'psrcat' " \
                            "to get J-name for '%s'" % srcname, \
                            errors.CoastGuardWarning)
            names = []
    
        if len(names) == 1:
            jname = names[0][-1]
        elif len(names) == 0:
            jname = srcname
            warnings.warn("Pulsar name '%s' cannot be found in psrcat. " \
                            "No J-name available." % srcname, \
                            errors.CoastGuardWarning)
        elif len(names) > 1:
            jname = srcname
            warnings.warn("Pulsar name '%s' is ambiguous. It has " \
                            "multiple matches (%d) in psrcat " \
                            "(search pattern used: '%s'):\n%s" % \
                    (srcname, len(names), search, '\n'.join(lines)), \
                                    errors.CoastGuardWarning)
        jname_cache[srcname] = jname
    return jname+tail


def get_prefname(name):
    """Use 'psrcat' program to find the preferred name of the given pulsar.
        NOTE: B-names are preferred over J-names.

        Input:
            name: Name of the pulsar.

        Output:
            prefname: Preferred name of the pulsar.
    """
    global prefname_cache
        
    # Strip '_R' tail if present. It is added back on just before
    # returning the preferred name
    if name.endswith("_R"):
        # Is a calibration observation
        tail = "_R"
        srcname = name[:-2]
    else:
        # Is not a cal obs
        tail = ""
        srcname = name

    if srcname in prefname_cache:
        prefname = prefname_cache[srcname]
    else:
        search = srcname
        if not srcname[0] in ('J', 'B') and len(srcname)==7:
            # Could be B-name, or truncated J-name. Add wildcard at end just in case.
            search += '*'
        try:   
            cmd = ['psrcat', '-nohead', '-nonumber', '-c', 'PSRJ PSRB', \
                            '-o', 'short', '-null', '', search]
            stdout, stderr = execute(cmd)
            lines = [line for line in stdout.split('\n') \
                        if line.strip() and not line.startswith("WARNING:")]
            names = [line.strip().split() for line in lines]
        except errors.SystemCallError:
            warnings.warn("Error occurred while trying to run 'psrcat' " \
                            "to get prefname for '%s'" % srcname, \
                            errors.CoastGuardWarning)
            names = []
    
        if len(names) == 1:
            prefname = names[0][-1]
        elif len(names) == 0:
            prefname = srcname
            warnings.warn("Pulsar name '%s' cannot be found in psrcat. " \
                            "No preferred name available." % srcname, \
                            errors.CoastGuardWarning)
        elif len(names) > 1:
            prefname = srcname
            warnings.warn("Pulsar name '%s' is ambiguous. It has " \
                            "multiple matches (%d) in psrcat " \
                            "(search pattern used: '%s'):\n%s" % \
                    (srcname, len(names), search, '\n'.join(lines)), \
                                    errors.CoastGuardWarning)
        prefname_cache[srcname] = prefname
    return prefname+tail


def is_fluxcal_source(name):
    raise NotImplementedError


def get_outfn(fmtstr, arf):
    """Replace any format string codes using file header info
        to get the output file name.

        Inputs:
            fmtstr: The string to replace header info into.
            arf: An archive file object to get header info from using vap.

        Output:
            outfn: The output filename with (hopefully) all
                format string codes replace.
    """
    if '%' not in fmtstr:
        # No format string codes
        return fmtstr

    # Cast some values and compute others
    outfn = fmtstr % arf

    if '%' in outfn:
        raise errors.BadFile("Interpolated file name (%s) shouldn't " \
                                 "contain the character '%%'!" % outfn)
    return outfn


def locate_cal(ar, calfrac=0.5):
    """Locate the profile bins that contain the cal signal.

        Inputs:
            ar: A psrchive.Archive object.
            calfrac: The fraction of phase bins occupied by the cal.
                (Default: 0.5)

        Output:
            is_cal: A list of boolean values (on for each phase bin).
                True values contain the cal signal.
    """
    prof = ar.get_data()[:,0,:].sum(axis=1).sum(axis=0)
    nn = len(prof)
    box = np.zeros(nn)
    ncalbins = int(nn*calfrac + 0.5)
    box[:ncalbins] = 1
    corr = np.fft.irfft(np.conj(np.fft.rfft(box))*np.fft.rfft(prof))
    calstart = corr.argmax()
    print_debug("Cal starts at bin %d" % calstart, 'clean')
    calbins = np.roll(box, calstart).astype(bool)
    return calbins


def correct_asterix_header(arfn):
    """Effelsberg Asterix data doesn't have backend and receiver
        information correctly written into archive headers. It is
        necessary to add the information. This function guesses
        the receiver used.

        NOTES:
            - An error is raised if the receiver is uncertain.
            - The corrected archive is written with the extension 'rcvr'.

        Input:
            arfn: An ArchiveFile object.

        Output:
            outarfn: The corrected ArchiveFile object.
    """
    codedir = os.path.join(os.getcwd(), os.path.split(__file__)[0])
    cmd = "%s/correct_archives.sh %s | bash" % (codedir, arfn.fn)
    stdout, stderr = execute(cmd)
    if stdout.strip().endswith("written to disk"):
        outarf = ArchiveFile(stdout.split()[0])
    else:
        raise errors.HeaderCorrectionError("Correction of Asterix archive (%s) " \
                                    "header failed: \n%s" % (arfn.fn, stderr))
    return outarf


def mjd_to_date(mjds):
    """Convert Modified Julian Day (MJD) to the year, month, day.

        Input:
            mjds: Array of Modified Julian days

        Outputs:
            years: Array of years.
            months: Array of months.
            days: Array of (fractional) days.

        (Follow Jean Meeus' Astronomical Algorithms, 2nd Ed., Ch. 7)
    """
    JD = np.atleast_1d(mjds)+2400000.5

    if np.any(JD<0.0):
        raise ValueError("This function does not apply for JD < 0.")

    JD += 0.5

    # Z is integer part of JD
    Z = np.floor(JD)
    # F is fractional part of JD
    F = np.mod(JD, 1)

    A = np.copy(Z)
    alpha = np.floor((Z-1867216.25)/36524.25)
    A[Z>=2299161] = Z + 1 + alpha - np.floor(0.25*alpha)

    B = A + 1524
    C = np.floor((B-122.1)/365.25)
    D = np.floor(365.25*C)
    E = np.floor((B-D)/30.6001)

    day = B - D - np.floor(30.6001*E) + F
    month = E - 1
    month[(E==14.0) | (E==15.0)] = E - 13
    year = C - 4716
    year[(month==1.0) | (month==2.0)] = C - 4715

    return (year.astype('int').squeeze(), month.astype('int').squeeze(), \
                day.squeeze())


def mjd_to_datetime(mjd):
    """Given an MJD return a datetime.datetime object.
        
        Input:
            mjds: Array of Modified Julian days

        Output:
            date: The datetime object.
    """
    yy, mm, dd = mjd_to_date(mjd)
    date = datetime.datetime(int(yy), int(mm), int(dd)) + \
            datetime.timedelta(days=(mjd%1))
    return date


def sort_by_keys(tosort, keys):
    """Sort a list of dictionaries, or database rows
        by the list of keys provided. Keys provided
        later in the list take precedence over earlier
        ones. If a key ends in '_r' sorting by that key
        will happen in reverse.

        Inputs:
            tosort: The list to sort.
            keys: The keys to use for sorting.

        Outputs:
            None - sorting is done in-place.
    """
    if not tosort:
        return tosort
    print_info("Sorting by keys (%s)" % " then ".join(keys), 3)
    for sortkey in keys:
        if sortkey.endswith("_r"):
            sortkey = sortkey[:-2]
            rev = True
            print_info("Reverse sorting by %s..." % sortkey, 2)
        else:
            rev = False
            print_info("Sorting by %s..." % sortkey, 2)
        if type(tosort[0][sortkey]) is types.StringType:
            tosort.sort(key=lambda x: x[sortkey].lower(), reverse=rev)
        else:
            tosort.sort(key=lambda x: x[sortkey], reverse=rev)


PERMS = {"w": stat.S_IWGRP,
         "r": stat.S_IRGRP,
         "x": stat.S_IXGRP}
def add_group_permissions(fn, perms=""):
    mode = os.stat(fn)[stat.ST_MODE]
    for perm in perms:
        mode |= PERMS[perm]
    os.chmod(fn, mode)


class ArchiveFile(object):
    def __init__(self, fn):
        self.fn = str(os.path.abspath(fn)) # Cast to string in case fn is unicode
        self.ar = None
        if not os.path.isfile(self.fn):
            raise errors.BadFile("Archive file could not be found (%s)!" % \
                                 self.fn)
        
        self.hdr = get_header_vals(self.fn, ['freq', 'length', 'bw', 'mjd', 
                                            'intmjd', 'fracmjd', 'backend', 
                                            'rcvr', 'telescop', 'name', 
                                            'nchan', 'asite', 'period', 'dm',
                                            'nsub', 'nbin', 'npol',
                                            'ra', 'dec'])
        self.hdr['origname'] = self.hdr['name'] # Original file name
        self.hdr['name'] = get_prefname(self.hdr['name']) # Use preferred name
        self.hdr['secs'] = int(self.hdr['fracmjd']*24*3600+0.5) # Add 0.5 so we actually round
        self.datetime = mjd_to_datetime(self.hdr['mjd'])
        self.hdr['yyyymmdd'] = self.datetime.strftime("%Y%m%d")
        self.hdr['pms'] = self.hdr['period']*1000.0
        self.hdr['inputfn'] = os.path.split(self.fn)[-1]
        self.hdr['inputbasenm'] = os.path.splitext(self.hdr['inputfn'])[0]
        self.hdr['telname'] = site_to_telescope[self.hdr['telescop'].lower()]
        if self.hdr['freq'] < 1000:
            self.hdr['band'] = 'Pband'
        elif self.hdr['freq'] < 2000:
            self.hdr['band'] = 'Lband'
        elif self.hdr['freq'] < 4000:
            self.hdr['band'] = 'Sband'
        elif self.hdr['freq'] < 8000:
            self.hdr['band'] = 'Cband'
        elif self.hdr['freq'] < 12000:
            self.hdr['band'] = 'Xband'
        else:
            self.hdr['band'] = 'Kband'

        rastr = self.hdr['ra']
        decstr = self.hdr['dec']
        if decstr[0] not in ('+', '-'):
            decstr = "+%s" % decstr
        self.hdr['coords'] = "%s%s" % (rastr, decstr)

    def __getitem__(self, key):
        filterfunc = lambda x: x # A do-nothing filter
        if (type(key) in (type('str'), type(u'str'))) and key.endswith("_L"):
            filterfunc = string.lower
            key = key[:-2]
        elif (type(key) in (type('str'), type(u'str'))) and key.endswith("_U"):
            filterfunc = string.upper
            key = key[:-2]
        if key not in self.hdr:
            if key == 'snr':
                self.hdr['snr'] = get_archive_snr(self.fn)
                val = self.hdr[key]
            elif key.startswith("date:"):
                val = self.datetime.strftime(key[5:])    
            else:
                try:
                    self.hdr.update(get_header_vals(self.fn, [key]))
                    val = self.hdr[key]
                except:
                    raise errors.CoastGuardError("Parameter '%s' is not " \
                            "recognized. Valid keys are '%s'" % \
                            (key, "', '".join([str(xx) for xx in self.hdr.keys()])))
        else:
            val = self.hdr[key]
        return filterfunc(val)
    
    def get_archive(self):
        if self.ar is None:
            import psrchive
            self.ar = psrchive.Archive_load(self.fn)
        return self.ar

    def get_usable_bw(self):
        ar = self.get_archive()
        clone = ar.clone()
        clone.pscrunch()
        clone.tscrunch()
        data = np.flipud(clone.get_data().squeeze())
        data = np.ma.masked_where(data==0, data)
        usebw = self['bw']*np.ma.count(data.sum(1))/float(data.shape[0])
        return usebw


class DefaultOptions(optparse.OptionParser):
    def __init__(self, *args, **kwargs):
        optparse.OptionParser.__init__(self, *args, **kwargs)

    def parse_args(self, *args, **kwargs):
        # Add debug group just before parsing so it is the last set of
        # options displayed in help text
        self.add_standard_group()
        self.add_debug_group()
        return optparse.OptionParser.parse_args(self, *args, **kwargs)

    def add_standard_group(self):
        group = optparse.OptionGroup(self, "Standard Options", \
                    "The following options are used to set standard " \
                    "behaviour shared by multiple modules.")
        group.add_option('-v', '--more-verbose', action='callback', \
                          callback=self.increment_config, \
                          callback_args=('verbosity',), \
                          help="Turn up verbosity level. " \
                                "(Default: level=%d)" % \
                                config.verbosity)
        group.add_option('--less-verbose', action='callback', \
                          callback=self.decrement_config, \
                          callback_args=('verbosity',), \
                          help="Turn down verbosity level. " \
                                "(Default: level=%d)" % \
                                config.verbosity)
        group.add_option('-c', '--toggle-colour', action='callback', \
                          callback=self.toggle_config, \
                          callback_args=('colour',), \
                          help="Toggle colourised output. " \
                                "(Default: colours are %s)" % \
                                ((config.colour and "on") or "off"))
        group.add_option('--toggle-exverb', action='callback', \
                          callback=self.toggle_config, \
                          callback_args=('excessive_verbosity',), \
                          help="Toggle excessive verbosity. " \
                                "(Default: excessive verbosity is %s)" % \
                                ((config.excessive_verbosity and "on") or "off"))
        self.add_option_group(group)

    def add_debug_group(self):
        group = optparse.OptionGroup(self, "Debug Options", \
                    "The following options turn on various debugging " \
                    "statements. Multiple debugging options can be " \
                    "provided.")
        group.add_option('--toggle-helpful-debug', action='callback', \
                          callback=self.toggle_config, \
                          callback_args=('helpful_debugging',), \
                          help="Toggle helpful debugging. " \
                                "(Default: helpful debugging is %s)" % \
                                ((config.helpful_debugging and "on") or "off"))
        group.add_option('-d', '--debug', action='callback', \
                          callback=self.debugall_callback, \
                          help="Turn on all debugging modes. (Same as --debug-all).")
        group.add_option('--debug-all', action='callback', \
                          callback=self.debugall_callback, \
                          help="Turn on all debugging modes. (Same as -d/--debug).")
        group.add_option('--set-debug-mode', action='callback', \
                          type='str', callback=self.debug_callback, \
                          help="Turn on specified debugging mode. Use --list-debug-modes " \
                            "to see the list of available modes and descriptions. " \
                            "(Default: all debugging modes are off)")
        group.add_option('--list-debug-modes', action='callback', \
                          callback=self.list_debug, \
                          help="List available debugging modes and descriptions, " \
                            "and then exit.")
        self.add_option_group(group)

    def increment_config(self, option, opt_str, value, parser, param):
        val = getattr(config, param)
        setattr(config, param, val+1)

    def decrement_config(self, option, opt_str, value, parser, param):
        val = getattr(config, param)
        setattr(config, param, val-1)

    def toggle_config(self, option, opt_str, value, parser, param):
        val = getattr(config, param)
        setattr(config, param, not val)

    def override_config(self, option, opt_str, value, parser):
        config.cfg.set_override_config(option.dest, value)

    def set_override_config(self, option, opt_str, value, parser):
        config.cfg.set_override_config(option.dest, True)

    def unset_override_config(self, option, opt_str, value, parser):
        config.cfg.set_override_config(option.dest, False)
    
    def debug_callback(self, option, opt_str, value, parser):
        config.debug.set_mode_on(value)

    def debugall_callback(self, option, opt_str, value, parser):
        config.debug.set_allmodes_on()

    def list_debug(self, options, opt_str, value, parser):
        print "Available debugging modes:"
        for name, desc in config.debug.modes:
            print "    %s: %s" % (name, desc)
        sys.exit(1)


class DefaultArguments(argparse.ArgumentParser):
    def __init__(self, *args, **kwargs):
        self.added_std_group = False
        self.added_debug_group = False
        self.added_file_group = False
        argparse.ArgumentParser.__init__(self, *args, **kwargs)

    def parse_args(self, *args, **kwargs):
        if not self._subparsers:
            # Add default groups just before parsing so it is the last set of
            # options displayed in help text
            self.add_standard_group()
            self.add_debug_group()
        args = argparse.ArgumentParser.parse_args(self, *args, **kwargs)
        if not self._subparsers:
            set_warning_mode(args.warnmode)
        return args

    def add_file_selection_group(self):
        if self.added_file_group:
            # Already added file selection group
            return
        group = self.add_argument_group("File Selection Options", \
                    "The following options are used to select files to process.")
        group.add_argument('-g', '--glob', dest='from_glob', \
                            action=self.GetFilesFromGlobAction, default=[], \
                            type=str, \
                            help="Glob expression of input files. Glob expression " \
                                "should be properly quoted to not be expanded by " \
                                "the shell prematurely. (Default: no glob " \
                                "expression is used.)") 
        group.add_argument('-x', '--exclude-file', dest='excluded_files', \
                            type=str, action='append', default=[], \
                            help="Exclude a single file. Multiple -x/--exclude-file " \
                                "options can be provided. (Default: don't exclude " \
                                "any files.)")
        group.add_argument('--exclude-glob', dest='excluded_by_glob', \
                            action=self.GetFilesFromGlobAction, default=[], \
                            type=str, \
                            help="Glob expression of files to exclude as input. Glob " \
                                "expression should be properly quoted to not be " \
                                "expanded by the shell prematurely. (Default: " \
                                "exclude any files.)")
        self.added_file_group = True

    def add_standard_group(self):
        if self.added_std_group:
            # Already added standard group
            return
        group = self.add_argument_group("Standard Options", \
                    "The following options get used by various programs.")
        group.add_argument('-v', '--more-verbose', nargs=0, \
                            action=self.TurnUpVerbosity, \
                            help="Be more verbose. (Default: " \
                                 "verbosity level = %d)." % config.verbosity)
        group.add_argument('-q', '--less-verbose', nargs=0, \
                            action=self.TurnDownVerbosity, \
                            help="Be less verbose. (Default: " \
                                 "verbosity level = %d)." % config.verbosity)
        group.add_argument('--set-verbosity', nargs=1, dest='level', \
                            action=self.SetVerbosity, type=int, \
                            help="Set verbosity level. (Default: " \
                                 "verbosity level = %d)." % config.verbosity)
        group.add_argument('--set-log-verbosity', nargs=1, dest='loglevel', \
                            action=self.SetLogVerbosity, type=int, \
                            help="Set verbosity level for logging. (Default: " \
                                 "verbosity level = %d)." % config.log_verbosity)
        group.add_argument('--toggle-colour', action=self.ToggleConfigAction, \
                          dest='colour', nargs=0, \
                          help="Toggle colourised output. " \
                                "(Default: colours are %s)" % \
                                ((config.colour and "on") or "off"))
        group.add_argument('--toggle-exverb', action=self.ToggleConfigAction, \
                          dest='excessive_verbosity', nargs=0, \
                          help="Toggle excessive verbosity. " \
                                "(Default: excessive verbosity is %s)" % \
                                ((config.excessive_verbosity and "on") or "off"))
        group.add_argument('-W', '--warning-mode', dest='warnmode', type=str, \
                            help="Set a filter that applies to all warnings. " \
                                "The behaviour of the filter is determined " \
                                "by the action provided. 'error' turns " \
                                "warnings into errors, 'ignore' causes " \
                                "warnings to be not printed. 'always' " \
                                "ensures all warnings are printed. " \
                                "(Default: print the first occurence of " \
                                "each warning.)")
        self.added_std_group = True

    def add_debug_group(self):
        if self.added_debug_group:
            # Debug group has already been added
            return
        group = self.add_argument_group("Debug Options", \
                    "The following options turn on various debugging " \
                    "statements. Multiple debugging options can be " \
                    "provided.")
        group.add_argument('-d', '--debug', nargs=0, \
                            action=self.SetAllDebugModes, \
                            help="Turn on all debugging modes. (Same as --debug-all).")
        group.add_argument('--debug-all', nargs=0, \
                            action=self.SetAllDebugModes, \
                            help="Turn on all debugging modes. (Same as -d/--debug).")
        group.add_argument('--set-debug-mode', nargs=1, dest='mode', \
                            action=self.SetDebugMode, \
                            help="Turn on specified debugging mode. Use " \
                                "--list-debug-modes to see the list of " \
                                "available modes and descriptions. " \
                                "(Default: all debugging modes are off)")
        group.add_argument('--list-debug-modes', nargs=0, \
                            action=self.ListDebugModes, \
                            help="List available debugging modes and " \
                                "descriptions, then exit")
        group.add_argument('--toggle-helpful-debug', action=self.ToggleConfigAction, \
                          dest='helpful_debugging', \
                          help="Toggle helpful debugging. " \
                                "(Default: helpful debugging is %s)" % \
                                ((config.helpful_debugging and "on") or "off"))
        self.added_debug_group = True

    class TurnUpVerbosity(argparse.Action):
        def __call__(self, parser, namespace, values, option_string):
            config.verbosity += 1

    class TurnDownVerbosity(argparse.Action):
        def __call__(self, parser, namespace, values, option_string):
            config.verbosity -= 1
 
    class SetVerbosity(argparse.Action):
        def __call__(self, parser, namespace, values, option_string):
            config.verbosity = values[0]

    class SetLogVerbosity(argparse.Action):
        def __call__(self, parser, namespace, values, option_string):
            config.log_verbosity = values[0]

    class SetDebugMode(argparse.Action): 
        def __call__(self, parser, namespace, values, option_string):
            config.debug.set_mode_on(values[0])

    class SetAllDebugModes(argparse.Action): 
        def __call__(self, parser, namespace, values, option_string):
            config.debug.set_allmodes_on()

    class ListDebugModes(argparse.Action): 
        def __call__(self, parser, namespace, values, option_string):
            print "Available debugging modes:"
            for name, desc in config.debug.modes:
                if desc is None:
                    continue
                print "    %s: %s" % (name, desc)
            sys.exit(1)

    class ToggleConfigAction(argparse.Action):
        def __call__(self, parser, namespace, values, option_string):
            val = getattr(config, self.dest)
            setattr(config, self.dest, not val)
    
    class OverrideConfigAction(argparse.Action):
        def __call__(self, parser, namespace, values, option_string):
            config.cfg.set_override_config(self.dest, values)

    class SetOverrideConfigAction(argparse.Action):
        def __call__(self, parser, namespace, values, option_string):
            config.cfg.set_override_config(self.dest, True)

    class UnsetOverrideConfigAction(argparse.Action):
        def __call__(self, parser, namespace, values, option_string):
            config.cfg.set_override_config(self.dest, False)

    class GetFilesFromGlobAction(argparse.Action):
        def __call__(self, parser, namespace, values, option_string):
            glob_file_list = getattr(namespace, self.dest)
            glob_file_list.extend(glob.glob(values))

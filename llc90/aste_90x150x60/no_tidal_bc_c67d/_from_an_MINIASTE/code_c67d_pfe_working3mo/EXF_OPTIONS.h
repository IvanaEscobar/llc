C $Header: /u/gcmpack/MITgcm_contrib/atnguyen/llc_270/aste_270x450x180/code_ad/EXF_OPTIONS.h,v 1.1 2014/01/14 07:09:15 atn Exp $
C $Name:  $

#ifndef EXF_OPTIONS_H
#define EXF_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_EXF
#ifdef ECCO_CPPOPTIONS_H

C-- When multi-package option-file ECCO_CPPOPTIONS.h is used (directly included
C    in CPP_OPTIONS.h), this option file is left empty since all options that
C   are specific to this package are assumed to be set in ECCO_CPPOPTIONS.h

#else /* ndef ECCO_CPPOPTIONS_H */

C-- Package-specific Options & Macros go here

C   Do more printout for the protocol file than usual.
cc#undef EXF_VERBOSE

C   Bulk formulae related flags.
#define  ALLOW_ATM_TEMP
#define  ALLOW_ATM_WIND
#define  ALLOW_DOWNWARD_RADIATION
#ifdef ALLOW_ATM_TEMP
C Note: To use ALLOW_BULKFORMULAE or EXF_READ_EVAP, needs #define ALLOW_ATM_TEMP
# define ALLOW_BULKFORMULAE
# define ALLOW_BULK_LARGEYEAGER04
# undef EXF_READ_EVAP
# ifndef ALLOW_BULKFORMULAE
C  Note: To use ALLOW_READ_TURBFLUXES, ALLOW_ATM_TEMP needs to
C        be defined but ALLOW_BULKFORMULAE needs to be undef
#  define ALLOW_READ_TURBFLUXES
# endif
#endif /* ALLOW_ATM_TEMP */

C-  Other forcing fields
#define ALLOW_RUNOFF
#undef  ALLOW_RUNOFTEMP
ccc#define ALLOW_SALTFLX

#if (defined (ALLOW_BULKFORMULAE) && defined (ATMOSPHERIC_LOADING))
C Note: To use EXF_CALC_ATMRHO, both ALLOW_BULKFORMULAE
C       and ATMOSPHERIC_LOADING need to be defined
# undef EXF_CALC_ATMRHO
#endif

C-  Zenith Angle/Albedo related flags.
#ifdef ALLOW_DOWNWARD_RADIATION
# define ALLOW_ZENITHANGLE
#  undef ALLOW_ZENITHANGLE_BOUNDSWDOWN
#endif

C-  Use ocean_emissivity*lwdown in lwFlux. This flag should be defined
C   unless to reproduce old results (obtained with inconsistent old code)
#ifdef ALLOW_DOWNWARD_RADIATION
# define EXF_LWDOWN_WITH_EMISSIVITY
#endif

C-  Relaxation to monthly climatologies.
#define ALLOW_CLIMSST_RELAXATION
#define ALLOW_CLIMSSS_RELAXATION

C- Allows to read-in (2-d) tidal geopotential forcing
#undef EXF_ALLOW_TIDES

C-  Allows to read-in seaice fraction from files (areaMaskFile)
#undef EXF_SEAICE_FRACTION

C-  Use spatial interpolation to interpolate
C   forcing files from input grid to model grid.
#define USE_EXF_INTERPOLATION
C   for interpolated vector fields, rotate towards model-grid axis
C   using old rotation formulae (instead of grid-angles)
#undef EXF_USE_OLD_VEC_ROTATION
C   for interpolation around N & S pole, use the old formulation
C   (no pole symmetry, single vector-comp interp, reset to 0 zonal-comp @ N.pole)
#undef EXF_USE_OLD_INTERP_POLE

#define EXF_INTERP_USE_DYNALLOC
#if ( defined USE_EXF_INTERPOLATION && defined EXF_INTERP_USE_DYNALLOC && defined USING_THREADS )
# define EXF_IREAD_USE_GLOBAL_POINTER
#endif

#endif /* ndef ECCO_CPPOPTIONS_H */
#endif /* ALLOW_EXF */
#endif /* EXF_OPTIONS_H */

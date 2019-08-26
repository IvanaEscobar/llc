C $Header: /u/gcmpack/MITgcm_contrib/llc_hires/llc_2160/code/CPP_OPTIONS.h,v 1.2 2013/10/29 08:14:40 dimitri Exp $
C $Name:  $

#ifndef CPP_OPTIONS_H
#define CPP_OPTIONS_H

#include "PACKAGES_CONFIG.h"

C CPP flags controlling particular source code features

C o Shortwave heating as extra term in external_forcing.F
C Note: this should be a run-time option
#define SHORTWAVE_HEATING

C o Include/exclude phi_hyd calculation code
#define INCLUDE_PHIHYD_CALCULATION_CODE

C o Include/exclude call to S/R CONVECT
#define INCLUDE_CONVECT_CALL

C o Include/exclude call to S/R CALC_DIFFUSIVITY
#define INCLUDE_CALC_DIFFUSIVITY_CALL

C o Allow full 3D specification of vertical diffusivity
#define ALLOW_3D_DIFFKR

C o Allow latitudinally varying BryanLewis79 vertical diffusivity
#undef ALLOW_BL79_LAT_VARY

C o Include/exclude Implicit vertical advection code
#define INCLUDE_IMPLVERTADV_CODE

C o Include/exclude AdamsBashforth-3rd-Order code
#undef ALLOW_ADAMSBASHFORTH_3

C o Include/exclude nonHydrostatic code
#undef ALLOW_NONHYDROSTATIC

C o Allow to account for heating due to friction (and momentum dissipation)
#undef ALLOW_FRICTION_HEATING

C o Allow mass source or sink of Fluid in the interior
C   (3-D generalisation of oceanic real-fresh water flux)
#undef ALLOW_ADDFLUID

C o Include pressure loading code
#define ATMOSPHERIC_LOADING

C o exclude/allow external forcing-fields load
C   this allows to read & do simple linear time interpolation of oceanic
C   forcing fields, if no specific pkg (e.g., EXF) is used to compute them.
#undef EXCLUDE_FFIELDS_LOAD

C o Include/exclude balancing surface forcing fluxes code
#undef ALLOW_BALANCE_FLUXES

C o Include/exclude balancing surface forcing relaxation code
#undef ALLOW_BALANCE_RELAX

C o Include/exclude GM-like eddy stress in momentum code
#undef ALLOW_EDDYPSI

C o Use "Exact Convervation" of fluid in Free-Surface formulation
C   so that d/dt(eta) is exactly equal to - Div.Transport
#define EXACT_CONSERV

C********* RELEVANT CHANGES *********

C o Allow the use of Non-Linear Free-Surface formulation
C   this implies that surface thickness (hFactors) vary with time
#define NONLIN_FRSURF

C o NEW OPTION to disable rStar (z*) code
#undef DISABLE_RSTAR_CODE
#define DISABLE_SIGMA_CODE

C********* RELEVANT CHANGES *********

C o Shortwave heating as extra term in external_forcing.F
C o Include/exclude code for single reduction Conjugate-Gradient solver
#define ALLOW_SRCG

CC o Allow full 3D specification of vertical viscosity
C this is also done in MOM_COMMON_OPTIONS.h
#define ALLOW_3D_VISCA4

C o Use "OLD" UV discretisation near boundaries (*not* recommended)
C   Note - only works with  #undef NO_SLIP_LATERAL  in calc_mom_rhs.F
C          because the old code did not have no-slip BCs
#undef  OLD_ADV_BCS

C o Use LONG.bin, LATG.bin, etc., initialization for ini_curviliear_grid.F
C   Default is to use "new" grid files (OLD_GRID_IO undef) but OLD_GRID_IO
C   is still useful with, e.g., single-domain curvilinear configurations.
#undef OLD_GRID_IO

C o Use old EXTERNAL_FORCING_U,V,T,S subroutines (for backward compatibility)
#undef USE_OLD_EXTERNAL_FORCING

C o Execution environment support options
#include "CPP_EEOPTIONS.h"

#endif /* CPP_OPTIONS_H */


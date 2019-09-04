C CPP options file for OBCS package
C Use this file for selecting options within the OBCS package

#ifndef OBCS_OPTIONS_H
#define OBCS_OPTIONS_H
#include "PACKAGES_CONFIG.h"
#include "CPP_OPTIONS.h"

#ifdef ALLOW_OBCS
C Package-specific Options & Macros go here

C Enable individual open boundaries
#undef ALLOW_OBCS_NORTH
#define ALLOW_OBCS_SOUTH
#define ALLOW_OBCS_EAST
#undef ALLOW_OBCS_WEST

C This include hooks to the Orlanski Open Boundary Radiation code
#undef ALLOW_ORLANSKI

C Enable OB values to be prescribed via external fields that are read
C from a file
#define ALLOW_OBCS_PRESCRIBE

C Enable OB conditions following Stevens (1990)
#undef ALLOW_OBCS_STEVENS

C This includes hooks to sponge layer treatment of uvel, vvel
#undef ALLOW_OBCS_SPONGE

C add tidal contributions to normal and tangential OB flow
#define ALLOW_OBCS_TIDES

C balance barotropic velocity
#define ALLOW_OBCS_BALANCE

CC Use older implementation of obcs in seaice-dynamics
CC note: most of the "experimental" options listed below have not yet
CC       been implementated in new version.
C#define OBCS_UVICE_OLD
C
C#ifdef OBCS_UVICE_OLD
CC     The following five CPP options are experimental and aim to deal
CC     with artifacts due to the low-frequency specification of sea-ice
CC     boundary conditions compared to the model forcing frequency.
CC     Ice convergence at edges can cause model to blow up.  The
CC     following CPP option fixes this problem at the expense of less
CC     accurate boundary conditions.
C#undef OBCS_SEAICE_AVOID_CONVERGENCE
C
CC     Smooth the component of sea-ice velocity perpendicular to the edge.
C#undef OBCS_SEAICE_SMOOTH_UVICE_PERP
C
CC     Smooth the component of sea ice velocity parallel to the edge.
C#undef OBCS_SEAICE_SMOOTH_UVICE_PAR
C
CC     Compute rather than specify seaice velocities at the edges.
C#define OBCS_SEAICE_COMPUTE_UVICE
C#endif /* OBCS_UVICE_OLD */
C
CC     Smooth the tracer sea-ice variables near the edges.
C#undef OBCS_SEAICE_SMOOTH_EDGE

#endif /* ALLOW_OBCS */
#endif /* OBCS_OPTIONS_H */

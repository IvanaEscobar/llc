# NA 4320x2160x1080x90 #

A repository for computing regional North Atlantic domains with the MITgcm.
These setups work with the current version of the [MITgcm](https://github.com/MITgcm/MITgcm).

Running with MITgcm c67c, make sure to submit script from the execution
directory located in the project directory (ie. $na in TACC machines). 

Ex: 
cd MITgcm\_c67c/mysetups/ProjectName/
should see links to directories and submission script
./submit\_scratch 

### Contents ###

The repo is organized by domain:

preprocess/
* contains MATLab codes to set up regional domain, apply open boundary
conditions, and determine tidal forcing. 

root/ 
* UPDATE (29 May 19): not spun up enough, there is a peak in the power spectrum 
density at about 17 hours which doesn't correspond to any of the tidal forcing
constituents applied. Spinning up for 2yrs in SVERDRUP.
* contains code, inputs, and namelists for computing the forward regional model
including tidal forcing and open boundary conditions.
* Spin up includes 13 constituents of tidal forcing along the boundaries for 
28 days.

no\_tides/
* contains code, inputs, and namelists for computing the forward regional model
including open boundary conditions.

spinup\_notides/
* contains code, inputs, and namelists for computing the forward regional model
including tidal forcing and open boundary conditions.
* Spin up has no tidal forcing along the boundaries for 28 days.

### Setup ###

* Follow [these instructions](https://confluence.atlassian.com/bitbucket/clone-a-repository-223217891.html) to get the repo on your machine
* [Here's a nice git cheatsheet](http://rogerdudler.github.io/git-guide/) 

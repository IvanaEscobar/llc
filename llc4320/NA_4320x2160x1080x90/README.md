# NA 4320x2160x1080x90 #

A repository for modeling regional North Atlantic domains with the MITgcm.
These setups work with the a version of the [MITgcm](https://github.com/MITgcm/MITgcm).

Running with MITgcm c67c, can get to this checkpoint by issuing the following 
command in your MITgcm git repository:
`git checkout checkpoitc67c`

Make sure to submit run script from the respective execution directory located 
under the project directory (ie. $na in TACC machines). 

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
* UPDATE (12 Dec 19): Discontinued model developent for this region and
resolution. Will continue to work on analysis with aste1080. 
* UPDATE (29 May 19): not spun up enough, there is a peak in the power spectrum 
density at about 17 hours which doesn't correspond to any of the tidal forcing
constituents applied. Would like to have SPUN UP for more than 2 years instead. 
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

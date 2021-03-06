# NA 4320x2160x1080x90 #

A repository for computing regional North Atlantic domains with the MITgcm. 
These setups work with the current version of the [MITgcm](https://github.com/MITgcm/MITgcm).

Currently running with MITgcm c67c, make sure to submit script from the mysetups
directory located in the correct MITgcm version. 

Ex: 
cd MITgcm\_c67c/mysetups/ProjectName/
should see links to directories and submission script
./submissionScript 

### Contents ###

The repo is organized by domain:

preprocess/
* contains MATLab codes to set up regional domain, apply open boundary
conditions, and determine tidal forcing. 

root/ 
* contains code, inputs, and namelists for computing the forward regional model
including tidal forcing and open boundary conditions.

### Setup ###

* Follow [these instructions](https://confluence.atlassian.com/bitbucket/clone-a-repository-223217891.html) to get the repo on your machine
* [Here's a nice git cheatsheet](http://rogerdudler.github.io/git-guide/) 

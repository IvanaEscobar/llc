#!/bin/bash
#SBATCH -J state2Dwtpt
#SBATCH -e err/state2Dwtpt.%j.err
#SBATCH -o out/state2Dwtpt.%j.out
#SBATCH -t 47:55:00
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p normal
#SBATCH -A Polar-Project 
#SBATCH --mail-user=ivana@oden.utexas.edu
#SBATCH --mail-type=all

module load matlab
matlab -nodesktop -nodisplay -nosplash < get_state2d_wet_rev.m >> job_status/pprogress_stateWtPt_rev.dat 

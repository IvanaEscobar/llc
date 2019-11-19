#!/bin/bash
#SBATCH -J state2Dwtpt
#SBATCH -e state2Dwtpt.%j.err
#SBATCH -o state2Dwtpt.%j.out
#SBATCH -t 47:55:00
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p normal
##SBATCH -p skx-normal
#SBATCH -A Polar-Project 
#SBATCH --mail-user=ivana@oden.utexas.edu
#SBATCH --mail-type=all

module load matlab
matlab -nodesktop -nodisplay -nosplash < get_state2d_wet.m >> progress_stateWtPt.dat 
#matlab -nodesktop -nodisplay -nosplash < get_state2d_wet_rev.m >> progress_stateWtPt_rev.dat 

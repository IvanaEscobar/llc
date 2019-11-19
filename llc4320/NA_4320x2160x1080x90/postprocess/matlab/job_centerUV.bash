#!/bin/bash
#SBATCH -J UVcntr
#SBATCH -e UVcntr.%j.err
#SBATCH -o UVcntr.%j.out
#SBATCH -t 47:55:00
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p normal
##SBATCH -p skx-normal
#SBATCH -A Polar-Project 
#SBATCH --mail-user=ivana@oden.utexas.edu
#SBATCH --mail-type=all

module load matlab
matlab -nodesktop -nodisplay -nosplash < centering_UV.m >> progress_centering_UV.dat 
#matlab -nodesktop -nodisplay -nosplash < centering_UV_rev.m >> progress_centering_UV_rev.dat

#!/bin/bash
#SBATCH -J UVcntr
#SBATCH -e err/UVcntr.%j.err
#SBATCH -o out/UVcntr.%j.out
#SBATCH -t 47:55:00
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p normal
#SBATCH -A Polar-Project 
#SBATCH --mail-user=ivana@oden.utexas.edu
#SBATCH --mail-type=all

module load matlab
matlab -nodesktop -nodisplay -nosplash < centering_UV.m >> job_status/pprogress_centering_UV.dat 

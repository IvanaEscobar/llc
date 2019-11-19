#!/bin/bash
#SBATCH -J saltwtpt
#SBATCH -e saltwtpt.%j.err
#SBATCH -o saltwtpt.%j.out
#SBATCH -t 47:55:00
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p normal
##SBATCH -p skx-normal
#SBATCH -A Polar-Project 
#SBATCH --mail-user=ivana@oden.utexas.edu
#SBATCH --mail-type=all

module load matlab
matlab -nodesktop -nodisplay -nosplash < compress_outputs_wetpoints_salt.m >> progress_comp_salt_wetpt.dat 
#matlab -nodesktop -nodisplay -nosplash < compress_outputs_wetpoints_salt_rev.m >> progress_comp_salt_wetpt_rev.dat 

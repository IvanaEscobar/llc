#!/bin/bash
#SBATCH -J saltwtpt
#SBATCH -e err/saltwtpt.%j.err
#SBATCH -o out/saltwtpt.%j.out
#SBATCH -t 47:55:00
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p normal
#SBATCH -A Polar-Project 
#SBATCH --mail-user=ivana@oden.utexas.edu
#SBATCH --mail-type=all

module load matlab
matlab -nodesktop -nodisplay -nosplash < compress_outputs_wetpoints_salt.m >> job_status/progress_comp_salt_wetpt.dat 

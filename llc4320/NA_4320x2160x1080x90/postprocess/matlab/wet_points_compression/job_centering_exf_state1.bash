#!/bin/bash
#SBATCH -J 2dcntr
#SBATCH -e err/2dcntr.%j.err
#SBATCH -o out/2dcntr.%j.out
#SBATCH -t 47:55:00
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p normal
#SBATCH -A Polar-Project 
#SBATCH --mail-user=ivana@oden.utexas.edu
#SBATCH --mail-type=all

module load matlab
matlab -nodesktop -nodisplay -nosplash < centering_exf_state1.m >> job_status/progress_centering_exf_state1.dat

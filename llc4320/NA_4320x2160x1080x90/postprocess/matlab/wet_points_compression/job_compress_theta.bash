#!/bin/bash
#SBATCH -J thetawtpt
#SBATCH -e thetawtpt.%j.err
#SBATCH -o thetawtpt.%j.out
#SBATCH -t 47:55:00
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p normal
#SBATCH -A Polar-Project 
#SBATCH --mail-user=ivana@oden.utexas.edu
#SBATCH --mail-type=all

module load matlab
matlab -nodesktop -nodisplay -nosplash < compress_outputs_wetpoints_theta.m >> job_status/progress_comp_theta_wetpt.dat 

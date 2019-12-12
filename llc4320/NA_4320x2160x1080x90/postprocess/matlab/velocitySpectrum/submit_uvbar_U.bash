#!/bin/bash
#SBATCH -J ubar_rev 
#SBATCH -e err/ubar_rev.%j.err
#SBATCH -o out/ubar_rev.%j.out
#SBATCH -t 10:55:00
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p skx-normal
#SBATCH -A Polar-Project 
#SBATCH --mail-user=ivana@oden.utexas.edu
#SBATCH --mail-type=all

module load matlab
matlab -nodesktop -nodisplay -nosplash < get_uvwbar_modc2_U_rev.m

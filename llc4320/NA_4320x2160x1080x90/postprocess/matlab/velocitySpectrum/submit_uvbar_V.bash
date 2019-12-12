#!/bin/bash
#SBATCH -J vbar_rev 
#SBATCH -e err/vbar_rev.%j.err
#SBATCH -o out/vbar_rev.%j.out
#SBATCH -t 10:55:00
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -p skx-normal
#SBATCH -A Polar-Project 
#SBATCH --mail-user=ivana@oden.utexas.edu
#SBATCH --mail-type=all

module load matlab
matlab -nodesktop -nodisplay -nosplash < get_uvwbar_modc2_V_rev.m 

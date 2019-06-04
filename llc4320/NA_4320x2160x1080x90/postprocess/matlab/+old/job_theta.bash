#!/bin/bash
####SBATCH -J exEArctic
#SBATCH -J Tcompres
#SBATCH -e Tcompres.%j.err
#SBATCH -o Tcompres.%j.out
##SBATCH -t 48:00:00
#SBATCH -t 24:00:00
#SBATCH -N 1
#SBATCH -n 1
##SBATCH -n 2
##SBATCH -n 10
###SBATCH -p skx-normal
#SBATCH -p normal
#SBATCH -A atn-startup
#SBATCH --mail-user=atnguyen@ices.utexas.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end

module load matlab
matlab -nodesktop -nodisplay -nosplash < get_etan_cor.m
#matlab -nodesktop -nodisplay -nosplash < get_monthly_mean_from_hourly.m
#matlab -nodesktop -nodisplay -nosplash < compress_outputs_wetpoints_theta.m
#matlab -nodesktop -nodisplay -nosplash < extract_EastArctic_4Ruth.m
#matlab -nodesktop -nodisplay -nosplash < get_uvwbar_mod.m
#matlab -nodesktop -nodisplay -nosplash < multidim_sumtide_mod_k33.m
#matlab -nodesktop -nodisplay -nosplash < lookat_tides_spectra_uv.m
#matlab -nodesktop -nodisplay -nosplash < get_amp_pha_from_Mtidek.m
#matlab -nodesktop -nodisplay -nosplash < lookat_amp_pha_from_Mtidek.m

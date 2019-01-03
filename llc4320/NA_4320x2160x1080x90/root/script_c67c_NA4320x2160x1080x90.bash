#!/bin/bash -x
#SBATCH -J NA4230
#SBATCH -o NA4230.%j.out
#SBATCH -e NA4230.%j.err
## A time limit of 0 means no time limit is to be set
#SBATCH -t 0
##SBATCH -t 48:00:00 
##SBATCH -N 25
##SBATCH -n 698
#SBATCH -N 11
#SBATCH -n 257
###SBATCH -A Transfer-of-ECCO-glo
#SBATCH --mail-user=ivana@utexas.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end

#--- 0.load modules ------

#---- 1.set variables ------
#nprocs=698
#snx=72
#sny=72
nprocs=257
snx=120
sny=120

# ---------- (1) 1 day simu ----------
#pickupts0="0000000000"
# ---------- (2) 3 day simu ----------
#pickupts0="0000000000"
#pickupts1="0000001920"
# ---------- (3) 1 week simu ----------
#pickupts0="0000001920"
#pickupts1="0000005760"
# ---------- (4) 4 weeks simu ----------
#pickupts0="0000005760"
#pickupts1="0000010560"
# ---------- (5) 12 weeks simu ----------
#pickupts0="0000010560"
#pickupts1="0000028080"
# ---------- (6) 24 weeks simu ----------
pickupts0="0000028080"
pickupts1="0000059040"

extsmooth=
forwadj= 
whichexp="_c67c"
ext3="_test1"
jobfile=script${whichexp}_NA4320x2160x1080x90.bash

#--- 2.set dir ------------
srcdir=$HOME/MITgcm_c67c/mysetups/NA_4320x2160x1080x90
datadir=/scratch/ivana/llc/llc4320/NA_4320x2160x1080x90/run_template
builddir=$srcdir/build${whichexp}
codedir=$srcdir/code${whichexp}
inputdir=$srcdir/namelists${whichexp}
scratchdir=/scratch/ivana/llc/llc4320/NA_4320x2160x1080x90
exedir=$scratchdir/run${whichexp}${ext3}_pk${pickupts1}

if [ ! -d $exedir ]; then
  mkdir -p $exedir;
  mkdir -p $exedir/diags;
fi
cd $exedir;

cp -rf ${codedir}/ .

#--- 3. link forcing -------------
if [ ! -d ./jra55 ]; then
  ln -s /scratch/ivana/forcing/jra55 ./jra55
  ln -s /scratch/ivana/forcing/jra55xx ./jra55xx
fi

#--- 4. linking binary ---------
ln -s ${datadir}/input_binaries/* .
ln -s ${datadir}/input_pickup/* .
ln -s ${datadir}/input_obcs/*.bin . 

#=================================================================================
#--- 5. linking xx_ fields ------
###ln -s ${datadir}/ADXXfiles${xxext}/xx*${xxiter}* ./
#=================================================================================

#--- 6. NAMELISTS ---------
cp -f ${srcdir}/${jobfile} .
cp -f ${inputdir}/* .
\rm -f data.exch2
cp -f data.exch2_${snx}x${sny}x${nprocs} data.exch2

#--- 7. executable --------
\rm -f mitgcmuv*
cp -f ${builddir}/mitgcmuv${forwadj}_${snx}x${sny}x${nprocs} ./mitgcmuv${forwadj}

#--- 8. pickups -----------
#NOTE: for pickup: copy instead of link to prevent accidental over-write
#\rm -f pickup*
if [[ ${pickupts0} ]]; then
  pickupdir=$scratchdir/run${whichexp}${ext3}_pk${pickupts0}
  cp -f ${pickupdir}/pickup.${pickupts1}.data ./pickup.${pickupts1}.data
  cp -f ${pickupdir}/pickup.${pickupts1}.meta ./pickup.${pickupts1}.meta
fi

#--- 9. make a list of all linked files ------
\rm -f command_ln_binary    
ls -l *.bin > command_ln_binary    
ls -l tile* >> command_ln_binary    

#--- 10. (re)set optimcycle --------------------

#\rm data.optim
#cat > data.optim <<EOF
# &OPTIM
# optimcycle=${iter},
# /
#EOF

#--- 11. run ----------------------------------

set -x
date > run.MITGCM.timing
mpiexec --mca btl ^tcp,openib --mca mtl psm2 ${exedir}/mitgcmuv${forwadj}  
date >> run.MITGCM.timing

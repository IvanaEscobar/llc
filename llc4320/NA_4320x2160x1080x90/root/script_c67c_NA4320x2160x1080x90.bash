#!/bin/bash -x
#SBATCH -J NA43t5
#SBATCH -o bash.out/NA4320.%j.out
#SBATCH -e bash.out/NA4320.%j.err
## A time limit of 0 means no time limit is to be set
#SBATCH -t 0
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
#pickupts1="0000000000"
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
pickupts0="0000010560"
pickupts1="0000028080"
# ---------- (6) 24 weeks simu ----------
#pickupts0="0000028080"
#pickupts1="0000059040"

forwadj= 
vers="_c67c"
ext3="_tidal_bc"
jobfile=script${vers}_NA4320x2160x1080x90.bash

#--- 2.set dir ------------
srcdir=$PWD #$HOME/llc/llc4320/NA_4320x2160x1080x90/root/ ln -s in mysetups/
builddir=$srcdir/build${vers}
codedir=$srcdir/code${vers}
inputdir=$srcdir/namelists${vers}
scratchdir=/scratch/ivana/llc/llc4320/NA_4320x2160x1080x90
datadir=$scratchdir/run_template
exedir=$scratchdir/run${vers}${ext3}_pk${pickupts1}

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

#==============================================================================
#--- 5. linking xx_ fields ------
###ln -s ${datadir}/ADXXfiles${xxext}/xx*${xxiter}* ./
#==============================================================================

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
  pickupdir=$scratchdir/run${vers}${ext3}_pk${pickupts0}
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

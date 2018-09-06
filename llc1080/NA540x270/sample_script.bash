#!/bin/bash
#SBATCH -J astejra55
#SBATCH -o astejra55.%j.out
#SBATCH -e astejra55.%j.err
#SBATCH -p development
#SBATCH -t 1:00:00 
##SBATCH -p normal
##SBATCH -t 18:00:00 
#########SBATCH -N 21 
#########SBATCH -n 336
#SBATCH -N 3 
#SBATCH -n 36 
###SBATCH -N 13 
##SBATCH -N 11 
##SBATCH -n 245 
#SBATCH -A Transfer-of-ECCO-glo
##SBATCH -A Arctic-Subpolar-Gyre
#SBATCH --mail-user=atnguyen@ices.utexas.edu
#SBATCH --mail-type=begin
#SBATCH --mail-type=end

#--- 0.load modules ------
module purge
module load intel/16.0.1
#module load mvapich2-largemem
module load cray_mpich/7.3.0
module load TACC/1.0
module load netcdf/4.3.3.1
module load parallel-netcdf/4.3.3.1
ulimit -s unlimited

#---- 1.set variables ------
#note for bash: can not have any space around =

nprocs=36
snx=90
sny=90
#nprocs=245
#snx=30
#sny=30
#pickupts0="0000000000"
#pickupts1="0000000002"
#pickupts0="0000000002"
#pickupts1="0000000004"
pickupts1=0000000000
#pickupts1=0000263016
extpickup= 
#extpickup="_2yrjra55"
#extpickup="_2yrjra55nomdimSnowvlowAlb"
#extpickup="_1yrjra55mdimSnowvlowAlb"

extsmooth="_9x1000mod"
ext0="00"
ext1="_1ts"
ext4=
#ext3="noRstar_v7imdimSnow${ext4}v3coast08"
ext3=_hFminp2Dr5_test12Oct2016
#ext3=_nomdimSnowvlowAlb
#ext3=_mdimSnowvlowAlb
#iter=13
iter=0
forwadj= 
whichexp="_c65q"
jobfile=script${whichexp}${ext1}${ext4}${forwadj}.bash
#xxiter="0000000013"
#xxext="_mp08latp20"
#xxext="_mp03latp30"
#xxext="_iter0011"

if [ ${iter} -lt 10 ]; then
    ext2=000${iter}
elif [ ${iter} -lt 100 ]; then
    ext2=00${iter}
elif [ ${iter} -lt 1000 ]; then
    ext2=0${iter}
else
    ext2=${iter}
fi

#--- 2.set dir ------------
### basedir   = /nobackupp8/pheimbac/ecco/ASTE-Production/version_20140617/MITgcm_c64x+
basedir=/work/03901/atnguyen/MITgcm_c65q/mysetups/aste_270x450x180
scratchdir=/scratch/03901/atnguyen/aste_270x450x180/
srcdir=$basedir
builddir=$srcdir/build${whichexp}_bp
codedir=$basedir/code${whichexp}_bp
inputdir=$basedir/input${whichexp}${ext1}${ext4}
#workdir=$scratchdir/run${whichexp}${ext1}${ext3}_it${ext2}_pk${pickupts1}
workdir=$scratchdir/run${whichexp}${ext1}${ext3}_pk${pickupts1}

if [ ! -d $workdir ]; then
  mkdir -p $workdir;
  mkdir -p $workdir/tapes;
  mkdir -p $workdir/profiles;
  mkdir -p $workdir/diags;
fi
cd $workdir;

rm -f tapes/*
rm -f profiles/*

cp -rf ${codedir}/ .

#--- 3. link forcing -------------
#if [ ! -h EIG ]; then
#  ln -s /scratch/03901/atnguyen/era-interim ./EIG
#fi
if [ ! -h jra55 ]; then
  ln -s /scratch/03901/atnguyen/jra55 ./jra55
fi
#ln -s /nobackupp8/hzhang1/forcing/jra25 ./jra25

#--- 4. linking binary ---------
ln -s ${basedir}/input/input_binaries/*.bin .
ln -s ${basedir}/input/input_binaries/tile*.mitgrid .
ln -s ${basedir}/input/input_obcs/OB*.bin .
ln -s ${basedir}/input/input* .
ln -s ${basedir}/input/input_insitu/*.nc .
ln -s ${basedir}/input/input_weight/* .
ln -s ${basedir}/input/my_input .
###
ln -s ${basedir}/input/input_smooth/smooth2Dscales001${extsmooth} ./smooth2Dscales001
ln -s ${basedir}/input/input_smooth/smooth3DscalesH001${extsmooth} ./smooth3DscalesH001
ln -s ${basedir}/input/input_smooth/smooth3DscalesZ001 ./
ln -s ${basedir}/input/input_smooth/smooth2Dnorm001${extsmooth}.data ./smooth2Dnorm001.data
ln -s ${basedir}/input/input_smooth/smooth3Dnorm001${extsmooth}.data ./smooth3Dnorm001.data
ln -s ${basedir}/input/input_smooth/smooth2Dnorm001.meta ./
ln -s ${basedir}/input/input_smooth/smooth3Dnorm001.meta ./

#=================================================================================
#--- 5. linking xx_ fields ------
#dirADXX=${basedir}/run${whichexp}${ext1}${ext3}_it0013_pk${pickupts1}
#cp -f ${dirADXX}/ADXXfiles/xx*${xxiter}* ./
#rm -f xx_diffkr.${xxiter}.data
#cp -f ${dirADXX}/ADXXfiles_capped/xx_diffkr${xxext}.${xxiter}.data ./xx_diffkr.${xxiter}.data
##=================================================================================

#--- 6. NAMELISTS ---------
cp -f ${inputdir}/* .
cp -f ${basedir}/${jobfile} .

#--- 7. executable --------
\rm -f mitgcmuv*
#cp -f ${builddir}/mitgcmuv${forwadj}_${nprocs} ./mitgcmuv${forwadj}
cp -f ${builddir}/mitgcmuv${forwadj} ./mitgcmuv${forwadj}

#--- 8. pickups -----------
#NOTE: for pickup: copy instead of link to prevent accidental over-write
#\rm -f pickup*
pickupdir=${basedir}/input/input_PICKUP/
#if [ -z ${pickupts0+x} ]; then
if [[ ${pickupts0} ]]; then
  #pickupdir=$scratchdir/run${whichexp}_20022013${ext1}_mdimSnowhiAlb_it${ext2}_pk${pickupts0}
  cp -f ${pickupdir}/pickup${extpickup}.${pickupts1}.data ./pickup.${pickupts1}.data
  cp -f ${pickupdir}/pickup${extpickup}.${pickupts1}.meta ./pickup.${pickupts1}.meta
  cp -f ${pickupdir}/pickup_seaice${extpickup}.${pickupts1}.data ./pickup_seaice.${pickupts1}.data
  cp -f ${pickupdir}/pickup_seaice${extpickup}.${pickupts1}.meta ./pickup_seaice.${pickupts1}.meta
fi

#--- 9. make a list of all linked files ------

\rm -f command_ln_input
ls -l input*/input_* > command_ln_input

\rm -f command_ln_binary
ls -l *.nc > command_ln_binary
ls -l *.bin >> command_ln_binary
ls -l tile* >> command_ln_binary
ls -l smooth* >> command_ln_binary
ls -l xx* >> command_ln_binary

#--- 10. (re)set optimcycle --------------------

\rm data.optim
cat > data.optim <<EOF
 &OPTIM
 optimcycle=${iter},
 /
EOF

#--- 11. run ----------------------------------

set -x
date > run.MITGCM.timing
#ibrun tacc_affinity -np $nprocs ./mitgcmuv${forwadj}
ibrun tacc_affinity ./mitgcmuv${forwadj}
date >> run.MITGCM.timing

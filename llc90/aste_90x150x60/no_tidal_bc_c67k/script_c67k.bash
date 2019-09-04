#!/bin/bash
#SBATCH -J MINIaste
#SBATCH -o aste90.%j.out
#SBATCH -e aste90.%j.err
#SBATCH -p skx-dev
#SBATCH -t 00:40:00 
#SBATCH -N 1 
#SBATCH -n 36 
#SBATCH -A Polar-Project 
#SBATCH --mail-user=ivana@oden.utexas.edu
#SBATCH --mail-type=all

#--- 0.load modules ------
ulimit -s unlimited

#---- 1.set variables ------
nprocs=36
snx=30
sny=30
pickupts0="0000000000"
pickupts1="0000000001"
iter=0
forwadj=""
whichexp="_c67k"
jobfile=script${whichexp}${forwadj}.bash

read_xx=0

iloop=1
while [ ${iloop} -le 1 ]; do

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
#
  basedir=/work/05427/iescobar/stampede2/llc/llc90/aste_90x150x60/no_tidal_bc${whichexp} 
  scratchdir=/scratch/05427/iescobar/llc/llc90/aste_90x150x60
  builddir=$basedir/build${whichexp}
  codedir=$basedir/code${whichexp}
  inputdir=$basedir/namelists${whichexp}
  workdir=$scratchdir/run${whichexp}_it${ext2}_pk${pickupts1}

  if [ ! -d $workdir ]; then
    mkdir -p $workdir
  fi
  cd $workdir
  if [ ! -d tapes ]; then
    mkdir -p tapes
  fi
  if [ ! -d profiles ]; then
    mkdir -p profiles
  fi
  if [ ! -d diags ]; then
    mkdir -p diags
  fi

  rm -f tapes/*
  rm -f profiles/*
  
  cp -rf ${codedir}/ .

#--- 3. link forcing -------------
  rm -f jra55
  if [ ! -h jra55 ]; then
    ln -s /work/03901/atnguyen/jra55 ./jra55
    ln -s /work/03901/atnguyen/jra55_xxi12 ./jra55xx
  fi

#--- 4. linking binary ---------
  ln -s ${basedir}/run_template/input_binaries/*.bin .
  ln -s ${basedir}/run_template/input_binaries/tile*.mitgrid .
  ln -s ${basedir}/run_template/input_weight/* .
  rm -f OB*
  ln -s ${basedir}/run_template/input_obcs/*.bin .
###
  ln -s ${basedir}/run_template/input_smooth/smooth*Dscales* ./
  ln -s ${basedir}/run_template/input_smooth/smooth*Dnorm001.* ./
#
#=================================================================================
##--- 5. linking xx_ fields ------
##=================================================================================
# this is messy, i am copying from my_input atm
# cp -f ${basedir}/run_template/input_xx/xx_atemp.0000000001.data${ext3} ./xx_atemp.0000000001.data 
#=================================================================================
  if [ ${read_xx} -gt 0 ]; then
    xxiter1=0055
    dirADXX1=${basedir}/run_BE2_dthetadr_it${xxiter1}_pk0000000005/ADXXfiles/
  #
    declare -a arr1=("atemp")
  #
  #copy pre-estimated control vectors
      for i in "${arr1[@]}"
      do
        cp ${dirADXX1}/xx_$i.000000${xxiter1}.data    ./xx_$i.000000${ext2}.data
        echo ${dirADXX1}/xx_$i.000000${xxiter1}.data
      done
        sed -i -e 's/'"doInitXX = .TRUE."'/'"doInitXX = .FALSE."'/g' data.ctrl
        sed -i -e 's/'"doinitxx = .TRUE."'/'"doinitxx = .FALSE."'/g' data.ctrl
        sed -i -e 's/'"doMainUnpack = .TRUE."'/'"doMainUnpack = .FALSE."'/g' data.ctrl
        sed -i -e 's/'"doMainPack = .TRUE"'/'"doMainPack = .FALSE"'/g' data.ctrl
  fi

#--- 6. NAMELISTS ---------
  cp -f ${inputdir}/* .
  cp -f ${basedir}/${jobfile} .
  cp -f data_exch2_${snx}x${sny}x${nprocs} data.exch2

#--- 7. executable --------
  rm -f mitgcmuv*
  cp -f ${builddir}/mitgcmuv${forwadj}_${snx}x${sny}x${nprocs} ./mitgcmuv${forwadj}
  cp -f ${builddir}/Makefile ./

#--- 8. pickups -----------
#NOTE: for pickup: copy instead of link to prevent accidental over-write
  if [[ ${pickupts0} ]]; then
    pickupdir=/work/03901/atnguyen/MITgcm_c65q/mysetups/aste_90x150x60/run_BE2_dthetadr_bp_it0000_pk0000000000
    cp -f ${pickupdir}/pickup.${pickupts1}.* ./
    cp -f ${pickupdir}/pickup_seaice.${pickupts1}.* ./
  fi

#--- 9. make a list of all linked files ------
  rm -f command_ln_input
  ls -l namelists_*/* > command_ln_input
  ls -l *.bin >> command_ln_binary
  ls -l tile* >> command_ln_binary
  ls -l smooth* >> command_ln_binary

#--- 11. run ----------------------------------
  #module load remora
  set -x
  date > run.MITGCM.timing
  ibrun tacc_affinity ./mitgcmuv${forwadj}
  date >> run.MITGCM.timing

  let iloop=iloop+1
done

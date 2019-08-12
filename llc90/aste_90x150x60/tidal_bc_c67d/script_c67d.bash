#!/bin/bash
#SBATCH -J MINIaste
#SBATCH -o aste90.%j.out
#SBATCH -e aste90.%j.err
#SBATCH -p skx-dev
#SBATCH -t 00:40:00 
#SBATCH -N 1 
#SBATCH -n 36 
#SBATCH -A Transfer-of-ECCO-glo
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
extpickup= 
extsmooth=""
iter=0
forwadj=""
whichexp="_c67d_tides"
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
  basedir=/work/05427/iescobar/stampede2/llc/llc90/aste_90x150x60/tidal_bc_c67d 
  basedir=/work/03901/atnguyen/MITgcm_c67d/mysetups/aste_90x150x60
  basedir0=/work/03901/atnguyen/MITgcm_c65q/mysetups/aste_90x150x60
  scratchdir=/scratch/03901/atnguyen/aste_90x150x60
  builddir=$basedir/build${whichexp}
  codedir=$basedir/code${whichexp}
  inputdir=$basedir/input${whichexp}
#  codedir=$basedir/code${whichexp}_pfe_working3mo
#  inputdir=$basedir/input${whichexp}_pfe_working3mo
  workdir=$scratchdir/run${whichexp}_it${ext2}_pk${pickupts1}

  if [ ! -d $workdir ]; then
    mkdir -p $workdir;
  fi
  cd $workdir;
  if [ ! -d tapes ]; then
    mkdir -p tapes;
  fi
  if [ ! -d profiles ]; then
    mkdir -p $workdir/profiles;
  fi
  if [ ! -d diags ]; then
    mkdir -p $workdir/diags;
  fi

  rm -f tapes/*
  rm -f profiles/*
  
  cp -rf ${codedir}/ .

#--- 3. link forcing -------------
  \rm -f jra55
  if [ ! -h jra55 ]; then
    ln -s /work/03901/atnguyen/jra55 ./jra55
    ln -s /work/03901/atnguyen/jra55_xxi12 ./jra55xx
  fi

#--- 4. linking binary ---------
  ln -s ${basedir}/run_template/input_binaries/*.bin .
  \rm -f OB*
  #ln -s ${basedir}/run_template/input_insitu/*.nc .
  #ln -s ${basedir}/run_template/input* .
  ln -s ${basedir}/run_template/input_weight/* .
  ln -s ${basedir}/run_template/input_binaries/tile*.mitgrid .
  #ln -s ${basedir}/run_template/my_input/* .
  ln -s ${basedir}/run_template/input_obcs/*.bin .
###
  ln -s ${basedir}/run_template/input_smooth/smooth2Dscales001${extsmooth} ./smooth2Dscales001
  ln -s ${basedir}/run_template/input_smooth/smooth3DscalesH001${extsmooth} ./smooth3DscalesH001
  ln -s ${basedir}/run_template/input_smooth/smooth3DscalesZ001 ./
  ln -s ${basedir}/run_template/input_smooth/smooth2Dnorm001${extsmooth}.data ./smooth2Dnorm001.data
  ln -s ${basedir}/run_template/input_smooth/smooth3Dnorm001${extsmooth}.data ./smooth3Dnorm001.data
  ln -s ${basedir}/run_template/input_smooth/smooth2Dnorm001.meta ./
  ln -s ${basedir}/run_template/input_smooth/smooth3Dnorm001.meta ./
#
#=================================================================================
##--- 5. linking xx_ fields ------
##=================================================================================

# this is messy, i am copying from my_input atm
# cp -f ${basedir}/run_template/input_xx/xx_atemp.0000000001.data${ext3} ./xx_atemp.0000000001.data 
#--- 6. NAMELISTS ---------
  cp -f ${inputdir}/* .
  cp -f ${basedir}/${jobfile} .
  #cp -f data_pkg${ext3} data.pkg
  #cp -f data_diagnostics${ext3} data.diagnostics
  #cp -f data_salt_plume${ext3} data.salt_plume
  cp -f data_exch2_${snx}x${sny}x${nprocs} data.exch2

#=================================================================================
if [ ${read_xx} -gt 0 ]; then
  xxiter1=0055
  #xxiter0=0000
  #dirADXX0=${scratchdir}/run_c65q_jra55_it${xxiter0}_pk0000000002/ADXXfiles/
  dirADXX1=${basedir}/run_BE2_dthetadr_it${xxiter1}_pk0000000005/ADXXfiles/
#
  #declare -a arr0=("kapgm" "kapredi" "theta" "salt" "logdiffkr")
  #declare -a arr1=("aqh" "atemp" "uwind" "vwind" "precip" "lwdown" "swdown")
  declare -a arr1=("atemp")
#
  #if [ ${use_optim} -gt 0 ]; then
  #  cp -f ${optimdir}/ecco_ctrl_MIT_CE_000.opt${ext2} ./
  #  sed -i -e 's/'"doinitxx = .TRUE."'/'"doinitxx = .FALSE."'/g' data.ctrl
  #  sed -i -e 's/'"doMainUnpack = .FALSE."'/'"doMainUnpack = .TRUE."'/g' data.ctrl
  #  sed -i -e 's/'"doMainPack = .FALSE."'/'"doMainPack = .TRUE."'/g' data.ctrl
  #else
#copy pre-estimated control vectors
    for i in "${arr1[@]}"
    do
      cp ${dirADXX1}/xx_$i.000000${xxiter1}.data    ./xx_$i.000000${ext2}.data
      echo ${dirADXX1}/xx_$i.000000${xxiter1}.data
    done
    #for i in "${arr0[@]}"
    #do
    #  cp ${dirADXX0}/xx_$i.000000${xxiter0}.data ./xx_$i.000000${ext2}.data
    #  echo ${dirADXX0}/xx_$i.000000${xxiter0}.data
    #done
      sed -i -e 's/'"doInitXX = .TRUE."'/'"doInitXX = .FALSE."'/g' data.ctrl
      sed -i -e 's/'"doinitxx = .TRUE."'/'"doinitxx = .FALSE."'/g' data.ctrl
      sed -i -e 's/'"doMainUnpack = .TRUE."'/'"doMainUnpack = .FALSE."'/g' data.ctrl
      sed -i -e 's/'"doMainPack = .TRUE"'/'"doMainPack = .FALSE"'/g' data.ctrl
  #fi
fi

#--- 7. executable --------
  \rm -f mitgcmuv*
  cp -f ${builddir}/mitgcmuv${forwadj}_${snx}x${sny}x${nprocs}_ol8 ./
  cp -f mitgcmuv${forwadj}_${snx}x${sny}x${nprocs}_ol8 ./mitgcmuv${forwadj}
  cp -f ${builddir}/Makefile ./

#--- 8. pickups -----------
#NOTE: for pickup: copy instead of link to prevent accidental over-write
  \rm -f pickup*
  #pickupdir=${scratchdir}/run_template/input_PICKUP/
  #if [ -z ${pickupts0+x} ]; then
  if [[ ${pickupts0} ]]; then
    pickupdir=${basedir0}/run_BE2_dthetadr_bp_it0000_pk0000000000
    cp -f ${pickupdir}/pickup${extpickup}.${pickupts1}.data ./pickup.${pickupts1}.data
    cp -f ${pickupdir}/pickup${extpickup}.${pickupts1}.meta ./pickup.${pickupts1}.meta
    cp -f ${pickupdir}/pickup_seaice${extpickup}.${pickupts1}.data ./pickup_seaice.${pickupts1}.data
    cp -f ${pickupdir}/pickup_seaice${extpickup}.${pickupts1}.meta ./pickup_seaice.${pickupts1}.meta
  fi

#--- 9. make a list of all linked files ------

  \rm -f command_ln_input
  ls -l input_*/* > command_ln_input
  
  \rm -f command_ln_binary
  ls -l *.bin >> command_ln_binary
  ls -l tile* >> command_ln_binary
  ls -l smooth* >> command_ln_binary

#--- 11. run ----------------------------------

  #module load remora
  set -x
  date > run.MITGCM.timing
  ###mpiexec --mca btl ^tcp,openib --mca mtl psm2 ${workdir}/mitgcmuv${forwadj}
#### stampede2
  #remora ibrun -n $nprocs ./mitgcmuv${forwadj}
  ibrun -n $nprocs ./mitgcmuv${forwadj}
  date >> run.MITGCM.timing
  
  #gael_cleanup
  #rm w2* *.bin smooth* tile* jra55 jra55xx 
  #tar_command_grid
  #tar_outputdump
  #tar_pickup
  #ls -l pickup* > list_pickup
  #rm pickup* data* eedata
  #rm_outputdump
  #rm_command_grid
  #mkdir diags/LAYERS
  #mv diags/layers* diags/LAYERS
  #rm -rf tapes
  #rmdir ADJfiles ADXXfiles profiles barfiles

  let iloop=iloop+1
done

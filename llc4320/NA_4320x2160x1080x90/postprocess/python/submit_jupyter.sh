#!/bin/bash

#SBATCH -p "skx-dev"
#SBATCH -J "ipynb"
#SBATCH -o "%j.txt"
#SBATCH -N 1
#SBATCH -n 48
#SBATCH -t "2:00:00"
#SBATCH -A "Polar-Project"

ml TACC
ml python3
ml tacc-singularity

SESSION_FILE="$PWD/delete_me_to_end_session"

# create password
export PASSWORD=`date | md5sum | cut -c-32`

# run notebook in background
LOCAL_IPY_PORT=8888

export SINGULARITYENV_XDG_RUNTIME_DIR="$PWD/jupyter"

nohup singularity run '/work/01837/jstubbs/public/ecco/jupyter.simg' & 

# use ssh for port forwarding
# echo Using ssh for port forwarding
IPY_PORT_PREFIX=2
NODE_HOSTNAME_PREFIX=`hostname -s`
NODE_HOSTNAME_DOMAIN=`hostname -d`
NODE_HOSTNAME_LONG=`hostname -f`
LOGIN_IPY_PORT="$((49+$IPY_PORT_PREFIX))`echo $NODE_HOSTNAME_PREFIX | perl -ne 'print $1.$2.$3 if /c\d\d\d-(\d)(\d)(\d)/;'`"

echo Port is $LOGIN_IPY_PORT

for i in `seq 5`; do
    ssh -f -g -N -R $LOGIN_IPY_PORT:$NODE_HOSTNAME_LONG:$LOCAL_IPY_PORT login$i
done

# send email notification
echo Your notebook is now running at http://$NODE_HOSTNAME_DOMAIN:$LOGIN_IPY_PORT with password $PASSWORD
# | mailx -s "Jupyter notebook now running" $EMAIL_ADDRESS

# use file to kill job
echo $NODE_HOSTNAME_LONG $IPYTHON_PID > $SESSION_FILE
while [ -f $SESSION_FILE ] ; do
    sleep 10
done

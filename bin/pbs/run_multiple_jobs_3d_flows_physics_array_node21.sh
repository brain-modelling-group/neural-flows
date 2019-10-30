#/usr/bin/bash
#PBS -N flows
#PBS -t 1-15
### specify the queue: 
#PBS -q physics
#PBS -j oe
#PBS -l nodes=node21:ppn=24
#PBS -l walltime=08:00:00
#PBS -l mem=24gb
#PBS -m abe
#PBS -M pmsl.academic@gmail.com

### cd to directory where the job was submitted:
cd $PBS_O_WORKDIR
date
echo "----------------"
echo "PBS job running on: `hostname`"
echo "in directory:       `pwd`"
echo "####################################################"

source ~/.bashrc

### 
MATLAB_CMD="addpath(genpath('/headnode2/paula123/Code/neural-flows'));idx_chunk=$PBS_ARRAYID;cluster_yossarian_multiple_jobs_calculate_3d_flows(idx_chunk); exit"
matlab2018a -nodesktop -nosplash -nodisplay -singleCompThread -r  "$MATLAB_CMD"

##### Execute Program #####
date

##### Exit successfully $PBS_ARRAYID
exit 0

##!/usr/bin/env bash
#Author: Paula Sanz-Leon / QIMR 

### Started Executing Program
echo "This job has started on:"
date
echo "----------------"
echo "Job running on: `hostname`"
echo "in directory:   `pwd`"
echo "####################################################"

CHUNKS=({18..19} {21..23} {25..25} {27..27} {29..29})
# The variable chunk will be used to index the time slice in the dataset 
for IDX_CHUNK in "${CHUNKS[@]}"
do
    export IDX_CHUNK
    NAME=job_${IDX_CHUNK}
    echo "Submitting chunk: ${NAME}"

    MATLAB_CMD="addpath(genpath('/home/paulasl/Code/neural-flows'));idx_chunk=$IDX_CHUNK;cluster_neurosrv_multiple_jobs_calculate_3d_flows(idx_chunk); exit"
    matlab2019a -nodesktop -nosplash -nodisplay -r  "$MATLAB_CMD"
    echo "done."
done

##### Finished Executing Program #####
echo "This job has finished on:"
date

##### Exit successfully 
exit 0

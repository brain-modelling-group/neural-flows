#!/bin/bash
# Author: Paula Sanz-Leon, QIMR / Sydney Uni

CHUNKS=$(seq 1 196) # This variable will be used to index the chunk
for IDX_CHUNK in ${CHUNKS}
do
    export IDX_CHUNK
    NAME=job_${IDX_CHUNK}
    echo "Submitting chunk: ${NAME}"
    qsub -v IDX_CHUNK run_multiple_jobs_3d_flows.pbs
    echo "done."
done

#!/bin/bash
# Author: Paula Sanz-Leon, QIMR / Sydney Uni

CHUNKS=(1 {5..11} {13..28} {180..191}) # This variable will be used to index the chunk
for IDX_CHUNK in ${CHUNKS[@]}
do
    export IDX_CHUNK
    NAME=job_${IDX_CHUNK}
    echo "Submitting chunk: ${NAME}"
    qsub -v IDX_CHUNK run_conversion_3d_flows.pbs
    echo "done."
done

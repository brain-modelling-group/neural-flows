#!/bin/bash
# Author: Paula Sanz-Leon, QIMR / Sydney Uni
# Call pbs script using defaultQ

CHUNKS=({3..3} {5..5} {8..8} {11..12}) # This variable will be used to index the chunk
for IDX_CHUNK in ${CHUNKS[@]}
do
    export IDX_CHUNK
    NAME=job_${IDX_CHUNK}
    echo "Submitting chunk: ${NAME}"
    qsub -v IDX_CHUNK run_multiple_jobs_3d_flows_defaultQ.pbs
    echo "done."
done

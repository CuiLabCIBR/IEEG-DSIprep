#!/bin/bash
for subj in 0007 0029 0030 0032 0034 0037 0038 0039 0040 0046 0048 0049 0052 0054 0055 0058 0062 \
0063 0064 0065 0066 0070 0073 0077
do
echo ""
echo "Running freesurfer on participant: sub-$subj"
echo ""
sbatch step_2st_mriprep_step1_freesurfer.sh $subj
done
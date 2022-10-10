#!/bin/bash
for subj in 0072
do
echo ""
echo "Running freesurfer on participant: sub-$subj"
echo ""
sbatch step_2st_mriprep_step1_freesurfer.sh $subj
done
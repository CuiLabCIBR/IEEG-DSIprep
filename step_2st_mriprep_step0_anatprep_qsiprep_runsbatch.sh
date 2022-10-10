#!/bin/bash
for subj in {0002..0112}
do
echo ""
echo "Running anatprep using qsiprep on participant: sub-$subj"
echo ""
sbatch step_2st_mriprep_step0_anatprep_qsiprep.sh $subj
done

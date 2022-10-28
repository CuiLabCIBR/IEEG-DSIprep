#!/bin/bash
for subj in {0002..0112}
do
echo ""
echo "Running dsiprep using qsiprep on participant: sub-$subj"
echo ""
sbatch step_2st_mriprep_step3_dsiprep_qsiprep.sh $subj
done

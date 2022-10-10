#!/bin/bash
# step 3 fiber tracking https://dsi-studio.labsolver.org/doc/cli_t3.html
for subj in {0001..0112} 
do
echo ""
echo "Running dsistudio fiber track on participant: sub-$subj"
echo ""
# subj info
subj_ID=sub-$subj
stepsize=0.1
track_alg=0
angle=90
mini_l=0
max_l=400
#fib file
fib_file=step_6_dsistudio_gqi/${subj_ID}/${subj_ID}_*odf.gqi.1.25.fib.gz
#output
output_folder=step_6_dsistudio_gqi/$subj_ID/stepsize-${stepsize}_track-${track_alg}_angle-${angle}_miniL-${mini_l}_maxL-${max_l}
mkdir $output_folder
#roi file
roi_fd=step_5_dsirecon/qsirecon/$subj_ID/ses-001/dwi
roi=$roi_fd/${subj_ID}_ses-001_run-001_space-T1w_desc-preproc_desc-schaefer400_atlas.nii.gz
#Run dsistudio reconstruction
dsi_studio --action=trk --source=$fib_file \
--fiber_count=10000000 \
--fa_threshold=0 \
--turning_angle=$angle \
--step_size=$stepsize \
--min_length=$mini_l \
--max_length=$max_l \
--method=$track_alg \
--otsu_threshold=0.6 \
--connectivity=${roi} \
--connectivity_threshold=0 \
--connectivity_type=pass \
--connectivity_value=count,ncount,mean_length,qa \
--output=$output_folder
done

for subj in 0111
do
#Running
echo " "
echo "Running mri_convert using freesurfer on participant: sub-$subj"
echo " "
cd /mnt/e/IEEG_DSI_connectome/MRIprep/DATA_T1acpc/fieldtrip/sub-${subj}
export SUBJECTS_DIR=/mnt/e/IEEG_DSI_connectome/MRIprep/DATA_T1acpc/fieldtrip/sub-${subj}
mri_convert -c -oc 0 0 0 sub-${subj}_acpc_T1w.nii sub-${subj}_tmp_T1w.nii
recon-all -i sub-${subj}_tmp_T1w.nii -s freesurfer -all
done
#!/bin/bash
#SBATCH --job-name=freesurfer
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu 4G
#SBATCH -p q_cn
module pruge
module load freesurfer
subj=$1
proj=/GPFS/cuizaixu_lab_permanent/xulongzhou/IEEG_DSI_connectome/MRIprep
#Running
echo " "
echo "Running freesurfer preprocessing on participant: sub-$subj"
echo " "
if [ ! -d $proj/DATA_freesurfer ]; then
    mkdir $proj/DATA_freesurfer
fi
export SUBJECTS_DIR=$proj/DATA_freesurfer
T1w_path=$proj/DATA_anatprep_qsiprep_w/qsiprep/sub-${subj}/anat/sub-${subj}_desc-preproc_T1w.nii.gz
recon-all -s sub-${subj} -i $T1w_path -all -qcache
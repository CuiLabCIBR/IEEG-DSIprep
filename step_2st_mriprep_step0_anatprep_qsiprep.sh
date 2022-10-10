#!/bin/bash
#SBATCH --job-name=anatprep
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=16G
#SBATCH -p q_fat_c
#SBATCH --qos=high_c
module pruge
module load singularity/3.7.0
#User inputs:
subj=$1
bids=/GPFS/cuizaixu_lab_permanent/xulongzhou/IEEG_DSI_connectome/MRIprep/DATA_BIDS
fs_license=/GPFS/cuizaixu_lab_permanent/xulongzhou/IEEG_DSI_connectome/code/freesurfer
workpath=/GPFS/cuizaixu_lab_permanent/xulongzhou/IEEG_DSI_connectome/MRIprep/DATA_anatprep_qsiprep
output=/GPFS/cuizaixu_lab_permanent/xulongzhou/IEEG_DSI_connectome/MRIprep/DATA_anatprep_qsiprep_w
#Run anatprep using qsiprep
echo " "
echo "Running anatprep on participant: sub-$subj"
echo " "
#Make participant directory
if [ ! -d $output ]; then
    mkdir $output
fi
if [ ! -d $workpath ]; then
    mkdir $workpath
fi
#Run
export SINGULARITYENV_TEMPLATEFLOW_HOME=/home/cuizaixu_lab/xulongzhou/.cache/templateflow
unset PYTHONPATH;
singularity run --cleanenv \
    -B $bids:/bids_dir \
    -B $fs_license:/freesurfer_license \
    -B $output:/output_dir \
    -B $workpath:/work \
    /home/cuizaixu_lab/xulongzhou/.singularity/qsiprep-0.15.4.sif \
    /bids_dir \
    /output_dir \
    -w /work \
    participant \
    --participant_label sub-${subj} \
    --nthreads 1 \
    --mem-mb 16000 \
    --fs-license-file /freesurfer_license/license.txt \
    --skip_bids_validation \
    --notrack \
    --anat-only \
    --output_resolution 1

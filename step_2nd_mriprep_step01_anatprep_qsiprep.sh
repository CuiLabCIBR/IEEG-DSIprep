#!/bin/bash
#SBATCH --job-name=anatprep
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G
#SBATCH -p q_cn
module pruge
module load singularity/3.7.0
#User inputs:
subj=$1
bids=/GPFS/cuizaixu_lab_permanent/xulongzhou/IEEG_DSI_connectome/MRIprep/step_1_BIDS
fs_license=/GPFS/cuizaixu_lab_permanent/xulongzhou/IEEG_DSI_connectome/code/freesurfer
workpath=/GPFS/cuizaixu_lab_permanent/xulongzhou/IEEG_DSI_connectome/MRIprep/DATA_anatprep_qsiprep_w
output=/GPFS/cuizaixu_lab_permanent/xulongzhou/IEEG_DSI_connectome/MRIprep/step_2_anatprep
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
    /home/cuizaixu_lab/xulongzhou/.singularity/qsiprep-0.16.0RC3.sif \
    /bids_dir \
    /output_dir \
    -w /work \
    participant \
    --participant_label sub-${subj} \
    --nthreads 1 \
    --mem-mb 20000 \
    --fs-license-file /freesurfer_license/license.txt \
    --skip_bids_validation \
    --notrack \
    --anat-only \
    --output_resolution 1

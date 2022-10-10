#!/bin/bash
for subj in 0080
do
echo $subj;
wp=/mnt/e/IEEG_DSI_connectome
cat $wp/MRIprep/BIDS_CODE/heuristic_$subj.py;
docker run --rm -it \
	-v /mnt/e/IEEG_DSI_connectome/MRIprep:/base \
	nipy/heudiconv:latest \
	-d /base/DATA_Dicom/sub-{subject}/ses-{session}/SCANS/*/DICOM/* \
	-o /base/DATA_BIDS/ \
	-f /base/BIDS_CODE/heuristic_$subj.py \
	-s $subj \
	-ss 001 \
	-c dcm2niix \
	-b --overwrite
done

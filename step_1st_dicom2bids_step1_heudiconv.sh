#!/bin/bash
for subj in {0085..120}; 
do
echo $subj;
wp=/mnt/e/IEEG_DSI_connectome
echo $wp/MRIprep/DATA_Dicom/sub-$subj/ses-001/SCANS
ls $wp/MRIprep/DATA_Dicom/sub-$subj/ses-001/SCANS
docker run --rm -it \
	-v /mnt/e/IEEG_DSI_connectome/MRIprep:/base \
	nipy/heudiconv:latest \
	-d /base/DATA_Dicom/sub-{subject}/ses-{session}/SCANS/*/DICOM/* \
	-o /base/DATA_BIDS/ \
	-f convertall \
	-s $subj \
	-ss 001 \
	-c none --overwrite;
done


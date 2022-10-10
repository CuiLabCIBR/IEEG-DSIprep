#!/bin/bash
# remove all the origin bval and bvec file, and used the corrected bval and bvec file as the replacement
for i in {0001..0120}
do
echo subj-${i}

rm -f /mnt/e/IEEG_DSI_connectome/MRIprep/DATA_BIDS/sub-${i}/ses-001/dwi/sub-${i}_ses-001_run-001_dwi.bval
rm -f /mnt/e/IEEG_DSI_connectome/MRIprep/DATA_BIDS/sub-${i}/ses-001/dwi/sub-${i}_ses-001_run-001_dwi.bvec

cp /mnt/e/IEEG_DSI_connectome/MRIprep/btable_denger/dwi.corrected.bval \
/mnt/e/IEEG_DSI_connectome/MRIprep/DATA_BIDS/sub-${i}/ses-001/dwi/sub-${i}_ses-001_run-001_dwi.bval

cp /mnt/e/IEEG_DSI_connectome/MRIprep/btable_denger/dwi.corrected.bvec \
/mnt/e/IEEG_DSI_connectome/MRIprep/DATA_BIDS/sub-${i}/ses-001/dwi/sub-${i}_ses-001_run-001_dwi.bvec

done
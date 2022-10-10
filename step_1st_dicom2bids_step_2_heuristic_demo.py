import os
def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes
def infotodict(seqinfo):
    """Heuristic evaluator for determining which runs belong where
    allowed template fields - follow python string module:
    item: index within category
    subject: participant id
    seqitem: run number during scanning
    subindex: sub index within group
    """
    t1w = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_run-001_T1w')
    t2w = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_run-001_T2w')
    taskrest = create_key('sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_run-001_bold')
    dsi = create_key('sub-{subject}/{session}/dwi/sub-{subject}_{session}_run-001_dwi')
    
    info = {t1w: [], t2w: [], taskrest: [], dsi: []}

    for idx, s in enumerate(seqinfo):
        if (s.dim1 == 256) and ('Sag T1 MPRAGE' in s.series_description):
            info[t1w] = [s.series_id]
        if (s.dim1 == 256) and ('Sag fs CUBE T2FLAIR' in s.series_description):
            info[t2w] = [s.series_id]
        if (s.dim1 == 64) and ('Ax BOLD' in s.series_description):
            info[taskrest] = [s.series_id]
        if (s.dim1 == 112) and ('Ax DSI 258 maxb=7000' in s.series_description):
            info[dsi] = [s.series_id]
    return info

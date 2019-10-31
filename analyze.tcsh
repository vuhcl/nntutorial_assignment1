#!/bin/tcsh
# Run this code from the command line for each subject
# Literature provides evidence of over-activation of
# the amygdala in bipolar patients so it would be our ROI
set path  = ${subj}/${subj}.results
set subj       = $argv[1]
cd $path
# Get ROI from atlas and resample it to match the dataset
whereami -prefix amymask.nii -mask_atlas_region DD_Desai_MPM::amygdala
3dresample -dxyz 2.5 2.5 2.5 -input amymask.nii -prefix amymask_resampled.nii
# Computes average time series of all voxels in the dataset that is in the amygdala
3dmaskave -mask amymask_resampled.nii -q errts.${subj}.fanaticor+tlrc > ${subj}_Amyg.1D
# Calculate Pearson correlation between the time course and all voxels
3dTcorr1D -pearson -prefix ${subj}_Amyg.Tcorr1D.nii errts.${subj}.fanaticor+tlrc ${subj}_Amyg.1D
# Calculate z-score to threshold activation and find clusters of voxels
3dcalc -a ${subj}_Amyg.Tcorr1D.nii -expr 'atanh(a)' -prefix ${subj}_Amyg.z.nii

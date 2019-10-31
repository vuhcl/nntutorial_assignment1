#!/usr/bin/env tcsh

#
# To run for a single subject, for example:
#
#   tcsh preprocessing.tcsh "01"
#
#########################################################################
#
# Raise error if command line argument is undefined or empty
if (! $?argv) then
  echo "** ERROR:  command line argument is undefined"
else
  if ("$argv" == "") then
    echo "** ERROR: no command line argument"
  endif
endif

# Set subject ID from input
set ss         = $argv[1]
set subj       = sub-${ss}
set run        = 01

# Inputs
set path_func  = ${subj}/func
set path_anat  = ${subj}/anat

# Pre-preprocessing:
# Skull-strip and warp the anatomical data to the TT_N27 template
@SSwarper -input ${path_anat}/${subj}_T1w.nii.gz \
          -base TT_N27_SSW.nii.gz                   \
          -subid ${subj}                                          \
          -deoblique                                              \
          -giant_move

# The afni_proc.py commands itself, which makes a single
# subject processing script
# run afni_proc.py to create a single subject processing script

# Perform pre-processing steps in order:
# Despiking
# Slice-timing correction
# Structural-functional coregistration
# Volume registration
# Noise regressors
# Blurring
afni_proc.py -subj_id ${subj} \
        -scr_overwrite \
        -dsets ${path_func}/${subj}_task-rest_bold.nii.gz   \
        -blocks despike tshift align tlrc volreg blur mask         \
                 scale regress                                     \
        -copy_anat ${path_anat}/anatSS.${subj}.nii\
            -anat_has_skull no                                    \
        -tcat_remove_first_trs 2                                  \
        -align_opts_aea -cost lpc+ZZ -giant_move                  \
        -tlrc_base TT_N27+tlrc                 \
        -tlrc_NL_warp                                              \
        -tlrc_NL_warped_dsets                                      \
             ${path_anat}/anatQQ.${subj}.nii                       \
             ${path_anat}/anatQQ.${subj}.aff12.1D                  \
             ${path_anat}/anatQQ.${subj}_WARP.nii                  \
        -volreg_align_to MIN_OUTLIER                               \
        -volreg_align_e2a                                          \
        -volreg_tlrc_warp                                          \
        -volreg_warp_dxyz 2.5                                      \
        -mask_segment_anat yes                                     \
        -mask_segment_erode yes                                    \
        -mask_import Tvent template_ventricle_2.5mm                \
        -mask_intersect Svent CSFe Tvent                           \
        -mask_epi_anat yes                                         \
        -regress_motion_per_run                                    \
        -regress_ROI_PC Svent 3                                    \
        -regress_ROI_PC_per_run Svent                              \
        -regress_make_corr_vols WMe Svent                          \
        -regress_anaticor_fast                                     \
        -regress_censor_motion 0.2                                 \
        -regress_censor_outliers 0.05                              \
        -regress_apply_mot_types demean deriv                      \
        -regress_est_blur_epits                                    \
        -regress_est_blur_errts                                    \
        -regress_run_clustsim yes                                   \
        -execute

#!/usr/bin/env tcsh
# Run this script to start preprocessing all subjects

# Create a ventricle template with the same voxel size
# as the end dataset
3dcalc -a ~/abin/TT_desai_dd_mpm+tlrc                       \
              -expr 'amongst(a,152,170)' -prefix template_ventricle
3dresample -dxyz 2.5 2.5 2.5 -inset template_ventricle+tlrc \
      -prefix template_ventricle_2.5mm

# Preprocess each subject's data and move the result to
# corresponding folders
foreach i (`cat subjList.txt`)
  echo $i
  tcsh preprocessing.tcsh $i
  mv sub-${i}.results sub-$i
end

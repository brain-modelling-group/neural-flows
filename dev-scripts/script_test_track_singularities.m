% This script track singularities over time. It is a test to have an idea
% of how similar.

% Load surfaces
mfile_surf = matfile('temp_isosurf_2019-03-21_16-45-07_qvGv');

% Get a decimated version of a surface
fraction_to_keep = 0.2;
decimated_surf_obj = decimate_surfaces(mfile_surf, fraction_to_keep);

% 
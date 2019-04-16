% This script track singularities over time. It is a test to have an idea
% of how similar.

% Load surfaces
mfile_surf = matfile('temp_isosurf_2019-03-21_16-45-07_qvGv');
mfile_vel = matfile('temp_velocity_2019-02-06_17-53-58_SkaC.mat');


% Get a decimated version of a surface
% This part takes about: 2.5 minutes for 10% or 20% vertices of original
tic;
fraction_to_keep = 0.1;
decimated_surf_obj = decimate_surfaces(mfile_surf, fraction_to_keep);
toc;
% Locate singularities
data_mode = 'surf';
tic;
[xyz_idx] = par_locate_critical_points(decimated_surf_obj, mfile_vel, data_mode);
toc;

[singularity_classification] =   classify_singularities(xyz_idx, mfile_vel);
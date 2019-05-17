% This script tracks singularities over time. 
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
% This takes about 50 minutes with a surf decimated to 10% of original
[xyz_idx] = par_locate_critical_points(decimated_surf_obj, mfile_vel, data_mode);
toc;

X = mfile_vel.X;
index_mode = 'subscript';

for tt=1:size(xyz_idx, 2)
    xyz_idx(tt).xyz_sub = xyz_idx(tt).xyz_idx; 
end

for tt=1:size(mfile_surf, 'isosurfs', 2)
    xyz_sidx(tt).xyz_sub = switch_index_mode(xyz_idx(tt).xyz_sub, index_mode, X);
end

% Do some dodgy stuff
xyz_idx = xyz_sidx;
for ii=1:200
xyz_idx(ii).xyz_idx = xyz_sidx(ii).xyz_sub;
end
xyz_idx = rmfield(xyz_idx, 'xyz_sub');


% Singularity classification works with subindices rather than linear
% indices
[singularity_classification] =   classify_singularities(xyz_idx, mfile_vel);


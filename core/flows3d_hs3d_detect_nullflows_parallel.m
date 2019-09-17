function null_points_3d = flows3d_hs3d_detect_nullflows_parallel(mfile_obj, X, Y, Z, in_bdy_mask, data_mode)
% Locatees null regions of velocity fields. These are good 'singularity' candidates. 
% Returns the location of the singularities either as: 
% linear indices xyz_lidx, or as subscripts [x_idx, y_idx, z_idx]. 
% TODO: clean up, break down into standlaone functions, return actual
% points in space, not only indices; 
% ARGUMENTS:
%          mfile_obj -- a MatFile handle with the critical isosurfaces or
%                       the velocity/flow fields. In the cases of using
%                       isosurfaces, mfile_obj could also be a struct
%          data_mode      -- a string to determine whther to use surfaces or
%                            velocity fields to detect the critical points. 
%                            Using velocity fields is fast but very innacurate.
%                            Using surfaces is accurate but painfully slow.
%                            Values: {'surf' | 'vel'}. Default: 'surf'.
%         X, Y, Z      -- 3D arrays of size [Nx, Ny, Nz] with the grids of the space 
%                         to be explroed.
%         in_bdy_mask -- a 3D array of size [Nx, Ny, Nz] with 1s in
%                        locations of space that are inside the boundary of 
%                        the brain and 0s for points that are outside.
%    
% OUTPUT:
%         null_points_3d  --  a struct of size [1 x no. timepoints]
%                         -- .xyz_idx linear indices of subscripts of all
%                                     null-flow points at k-th timepoint.
%                         -- .x  x-coordinates 
%                         -- .y  y-coordinates
%                         -- .z  z-coordinates
%       
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer February 2019
% USAGE:
%{
    
%}

if nargin < 4
    index_mode = 'linear';
end

switch data_mode
    case 'surf'
        % Slow with full resolution surfaces (50k faces each) but seems to give precise-ish locations
        null_points_3d = use_isosurfaces(mfile_obj, X, Y, Z, index_mode, in_bdy_mask);
    case 'vel'
        % Super fast, but gives lots of points that do not seem to be
        % intersecting
        null_points_3d = use_velocity_fields(mfile_obj, index_mode);   
end
        
end % function flows3d_hs3d_detect_nullflows_parallel()

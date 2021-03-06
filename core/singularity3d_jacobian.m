function [J3D] = singularity3d_jacobian(critical_xyz_idx, ux, uy, uz, hx, hy, hz)
% Estimates the 3 x 3 Jacobian of ux, uy, uz around the estimated critical points
% critical_xyz_idx are the subscripts of the guesstimated critical points
% XXXX: Document
% ARGUMENTS:
%           critical
% The Jacobian matrix of a 3D vector field is
%      | dVx/dx   dVx/dy   dVx/dz|
%      |                         |
%J =   | dVy/dx   dVy/dy   dVy/dz|
%      |                         |
%      | dVz/dx   dVz/dy   dVz/dz|

% labels along the y,x, z dimension for integer indices
ii = 1;
jj = 2;
kk = 3;

% Jacobian - 3D array of size 3 x 3 x num_critical_points
J3D(3, 3, size(critical_xyz_idx, 1)) = 0;   

% Approximate Jacobian matrix elements -- may have to find a better way to
% do this                  
num_critical_points = size(critical_xyz_idx, 1);

% linear index of the centre point in a moore neighbourhood in 3D
centre_point_lidx = 14;

% Iterate over critical points and calculate their jacobian
for this_point = 1:num_critical_points

    iy = critical_xyz_idx(this_point, ii);
    ix = critical_xyz_idx(this_point, jj);
    iz = critical_xyz_idx(this_point, kk);
    
    [Mx, My, Mz] = moore_neighbourhood_3d(iy, ix, iz);
    
    % preallocate memory in the right shape
    ux_cube = zeros(3, 3, 3);
    uy_cube = ux_cube;
    uz_cube = ux_cube;
    
    for this_elem = 1:numel(Mx)
        ux_cube(this_elem) = ux(My(this_elem), Mx(this_elem), Mz(this_elem));
        uy_cube(this_elem) = uy(My(this_elem), Mx(this_elem), Mz(this_elem));
        uz_cube(this_elem) = uz(My(this_elem), Mx(this_elem), Mz(this_elem));
    end

    [duxdx, duxdy, duxdz] = gradientxyz(ux_cube, hy, hx, hz);
    [duydx, duydy, duydz] = gradientxyz(uy_cube, hy, hx, hz);
    [duzdx, duzdy, duzdz] = gradientxyz(uz_cube, hy, hx, hz);
    J3D(:, :, this_point) = [duxdx(centre_point_lidx) duxdy(centre_point_lidx)  duxdz(centre_point_lidx);
                             duydx(centre_point_lidx) duydy(centre_point_lidx)  duydz(centre_point_lidx);
                             duzdx(centre_point_lidx) duzdy(centre_point_lidx)  duzdz(centre_point_lidx)];
    
    

   
end
    
end % function singularity3d_calculate_jacobian()

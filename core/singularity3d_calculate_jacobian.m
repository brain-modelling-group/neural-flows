function [J3D] = singularity3d_calculate_jacobian(critical_xyz_idx, ux, uy, uz, hx, hy, hz)
% Estimates the 3 x 3 Jacobian of ux, uy, uz around the estimated critical points
% critical_xyz_idx are the indices of the estimated points

% The Jacobian matrix of a 3D vector field is
%      | dVx/dx   dVx/dy   dVx/dz|
%      |                         |
%J =   | dVy/dx   dVy/dy   dVy/dz|
%      |                         |
%      | dVz/dx   dVz/dy   dVz/dz|

% labels along the x, y, z dimension for integer indices
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
    

    ix = critical_xyz_idx(this_point, ii);
    iy = critical_xyz_idx(this_point, jj);
    iz = critical_xyz_idx(this_point, kk);
    
    [Mx, My, Mz] = moore_neighbourhood_3d(ix, iy, iz);
    
    % preallocate memory in the right shape
    ux_cube = zeros(3, 3, 3);
    uy_cube = ux_cube;
    uz_cube = ux_cube;
    
    for this_elem = 1:numel(Mx)
        ux_cube(this_elem) = ux(Mx(this_elem), My(this_elem), Mz(this_elem));
        uy_cube(this_elem) = uy(Mx(this_elem), My(this_elem), Mz(this_elem));
        uz_cube(this_elem) = uz(Mx(this_elem), My(this_elem), Mz(this_elem));
    end

    [dvxdx, dvxdy, dvxdz] = gradient(ux_cube, hx, hy, hz);
    [dvydx, dvydy, dvydz] = gradient(uy_cube, hx, hy, hz);
    [dvzdx, dvzdy, dvzdz] = gradient(uz_cube, hx, hy, hz);
    J3D(:, :, this_point) = [dvxdx(centre_point_lidx) dvxdy(centre_point_lidx)  dvxdz(centre_point_lidx);
                             dvydx(centre_point_lidx) dvydy(centre_point_lidx)  dvydz(centre_point_lidx);
                             dvzdx(centre_point_lidx) dvzdy(centre_point_lidx)  dvzdz(centre_point_lidx)];
    
    

   
end
    
end % function jacobian3d()

function [] = jacobian3d(critical_xyz_idx, vx, vy, vz, hx, hy, hz)
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

% Jacobian - 3D array of size 3 x 3 x num_crtical_points
J3D(3, 3, size(critical_xyz_idx, 1)) = 0;

% Approximate Jacobian matrix elements -- may have to find a better way to
% do this




                  
num_critical_points = size(critical_xyz_idx, 1);


% linear index of the centre point in a moore neighbourhood in 3D
centre_point_lidx = 14;

for this_point = 1:num_critical_points
    

    ix = critical_xyz_idx(this_point, ii);
    iy = critical_xyz_idx(this_point, jj);
    iz = critical_xyz_idx(this_point, kk);
    
    [Mx, My, Mz] = moore_neighbourhood_3d(ix, iy, iz);
    
    % preallocate memory in the right shape
    vx_cube = zeros(3, 3, 3);
    vy_cube = vx_cube;
    vz_cube = vx_cube;
    
    for this_elem = 1:numel(Mx)
        vx_cube(this_elem) = vx(Mx(this_elem), My(this_elem), Mz(this_elem));
        vy_cube(this_elem) = vy(Mx(this_elem), My(this_elem), Mz(this_elem));
        vz_cube(this_elem) = vz(Mx(this_elem), My(this_elem), Mz(this_elem));
    end


    
    [dvxdx, dvxdy, dvxdz] = gradient(vx_cube, hx, hy, hz);
    [dvydx, dvydy, dvydz] = gradient(vy_cube, hx, hy, hz);
    [dvzdx, dvzdy, dvzdz] = gradient(vz_cube, hx, hy, hz);
    J3D(:, :, this_point) = [dvxdx(centre_point_lidx) dvxdy(centre_point_lidx)  dvxdz(centre_point_lidx);
                             dvydx(centre_point_lidx) dvydy(centre_point_lidx)  dvydz(centre_point_lidx);
                             dvzdx(centre_point_lidx) dvzdy(centre_point_lidx)  dvzdz(centre_point_lidx)];
    


   
end
    
end



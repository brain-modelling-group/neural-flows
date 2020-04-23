function [outter_bdy_mask, diff_mask] = data3d_boundary_mask_outter_between(inner_bdy_mask, shift_steps)
%% This function calculates the alpha shape of scattered points in 3D, defined in locs.
%  It also returns the in/out status of the query points xq, yq, zq with respect 
%  to the 3D alpha shape; and, the list of triangles of the boundary/convex
%  hull that encloses all the scattered points defined in locs.
%
% ARGUMENTS:
%        in_bdy_mask -- 
%        shift_steps -- 
%
% OUTPUT: 
%        in_bdy_mask -- a logical vector of size [number_query_points x 1] 
%                       with the status of the query points.
%        bdy         -- a [number_of_triangles x 3] array with the indices
%                       of the points in locs that make up the triangles of
%                       the boundary.
%
% REQUIRES: 
%        Matlab's polyfun toolbox
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
%
% AUTHOR: 
%        Paula Sanz-Leon, QIMR Berghofer 2019-02

if nargin < 2
    shift_steps = 1;
end

ydim = 1;
xdim = 2;
zdim = 3;

outter_bdy_mask = inner_bdy_mask;
outter_bdy_mask = outter_bdy_mask + circshift(outter_bdy_mask, shift_steps, xdim) + circshift(outter_bdy_mask, -shift_steps, xdim);
outter_bdy_mask = outter_bdy_mask + circshift(outter_bdy_mask, shift_steps, ydim) + circshift(outter_bdy_mask, -shift_steps, ydim);
outter_bdy_mask = outter_bdy_mask + circshift(outter_bdy_mask, shift_steps, zdim) + circshift(outter_bdy_mask, -shift_steps, zdim);
outter_bdy_mask(outter_bdy_mask > 0) = 1;

diff_mask = logical(outter_bdy_mask - inner_bdy_mask);
outter_bdy_mask = logical(outter_bdy_mask);


end % function data3d_calculate_interpolation_mask()

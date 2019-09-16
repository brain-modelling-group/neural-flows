function [in_bdy_mask, bdy] = data3d_calculate_boundary(locs, xq, yq, zq, alpha_radius)
%% This function calculats the alpha shape of scattered points in 3D.
%  It returns the in/out status of the query points xq, yq, zq with respect 
%  to the 3D alpha shape; and, the list of triangles of the boundary/convex
%  hull that encloses all the scattred points defined in locs.
%
% ARGUMENTS:
%        locs -- a number_of_points x 3 array with the locations of scattered points
%        xq   -- a vector with the x-coordinate of query points
%                of size [number_query_points x 1] 
%        yq   -- a vector with the y-coorindate of query points 
%                of size [number_query_points x 1] 
%        zq   -- a vector with the z-coordinate of query points
%                of size [number_query_points x 1] 
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
% 


if nargin < 5
    alpha_radius = 30;
end
    shp = alphaShape(locs, alpha_radius);

    % The boundary of the centroids is an approximation of the cortex
    bdy = shp.boundaryFacets;
    
    % Detect which points are inside the resulting alpha shape boundary.
    in_bdy_mask = inShape(shp, xq, yq, zq);
    
end % function get_boundary_info()

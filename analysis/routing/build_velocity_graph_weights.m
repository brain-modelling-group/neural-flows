function [A, W] = build_velocity_graph_weights(X, Y, Z, locs_idx_grid, locs_idx_mask, in_bdy_mask, speeds)
% Description of what this function does
%
% ARGUMENTS:
%          xxx -- description here
%
% OUTPUT: 
%          xxx -- description here
%
% REQUIRES: 
%           some_function()
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon -- QIMR October 2019
% weights is a vector of size(elements in in_bdy_mask, 1);
% 
% Paula Sanz-Leon QIMR October 2019
point_cloud = pointCloud([X(in_bdy_mask) Y(in_bdy_mask) Z(in_bdy_mask)]);

num_points = size(locs_idx_grid, 1);
num_nneighbours =  216;

% Allocate memory
nneighbours_indices(num_points, num_nneighbours) = 0;
cols_indices(num_points, num_nneighbours) = 0;

% Number of valid points
% nn = sum(in_bdy_mask(:));

locs = [X(locs_idx_grid) Y(locs_idx_grid) Z(locs_idx_grid)];
weights = 1./speeds;

for kk=1:num_points
    this_point = locs(kk, :);
    [nneighbours_indices(kk, :), ~] = findNearestNeighbors(point_cloud, this_point, num_nneighbours);
    loc_idx = locs_idx_mask(kk);
    cols_indices(kk, :) = loc_idx(ones(num_nneighbours, 1));
end

% Build adjacency matrix
A = sparse(nneighbours_indices(:), cols_indices(:), 1);
A = A+A'; % Build symmetric matrix; 

% Build weighted matrix
W = sparse(nneighbours_indices(:), cols_indices(:), weights(nneighbours_indices(:)));
W = W+W';
% NOTE-to-self: be careful with the indidces of the diferent masks

end
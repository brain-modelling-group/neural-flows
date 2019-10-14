function [A, W] = build_velocity_graph(X, Y, Z, locs_idx_grid, locs_idx_mask, in_bdy_mask, speeds)
% Description of what this function does
%
% ARGUMENTS:
%          xxx -- description here
%
% OUTPUT: 
%          xxx -- description here
%
% REQUIRES: 
%           pointCloud() -- Matlab's built-in function
%           findNearestNeighbors() -- Matlab's built-in function
%           
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

num_rois = size(locs_idx_grid, 1); % This number corresponds to number of nodes in a parcellation
num_nneighbours =  216;

% Allocate memory
nneighbours_indices(num_rois, num_nneighbours) = 0;
weights(num_rois, num_nneighbours) = 0;
cols_indices(num_rois, num_nneighbours) = 0;

% Number of valid points
% nn = sum(in_bdy_mask(:));

locs = [X(locs_idx_grid) Y(locs_idx_grid) Z(locs_idx_grid)];

for kk=1:num_rois
    this_point = locs(kk, :);
    [nneighbours_indices(kk, :), ~] = findNearestNeighbors(point_cloud, this_point, num_nneighbours);
    loc_idx = locs_idx_mask(kk);
    % Calculate an average speed between origin and neighbours 
    weights(kk, :) = (speeds(loc_idx) + speeds(nneighbours_indices(kk, :)))/2;
    cols_indices(kk, :) = loc_idx(ones(num_nneighbours, 1));
end

% Inverse of speeds -- if speed is almost zero, then we get infinity
weights = 1./weights;

% Build adjacency matrix
A = sparse(nneighbours_indices(:), cols_indices(:), 1);
A = A+A'; % Build symmetric matrix; 

% Build weighted matrix
W = sparse(nneighbours_indices(:), cols_indices(:), weights(:));
W = W+W';
% NOTE-to-self: be careful with the indidces of the diferent masks

end
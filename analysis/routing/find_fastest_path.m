function [spaths, path_weights] = find_fastest_path(W, locs_idx_mask, nnodes)
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
% W -- indices of the points inside the boundary
% locs_idx_mask -- indices of the points inside the grid, only regions in
% the dti matrix
% nnodes, nodes of the parcellation


% spaths are the nodes -- in indices of the in_bdy_mask/not_nan_maks - that
% form the fastest path.
% Calculate the average

% AUTHOR: Paula Sanz-Leon, QIMR 2019

G = graph(W, 'upper', 'omitselfloops');

%nnodes = 90;
path_weights = zeros(nnodes);

% All to all
spaths = cell(nnodes, nnodes);

% Get unique combinations of node pairs -- at the moment we are not doing
% directionality stuff.
C = nchoosek(1:nnodes, 2);
npaths = size(C, 1);

for this_path = 1:npaths
    sn = C(this_path, 1); % Source node 
    tn = C(this_path, 2); % Target node
    [spaths{tn, sn}, path_weights(tn, sn)] = shortestpath(G, locs_idx_mask(sn), locs_idx_mask(tn));
end

% Invert the path weight, as the original weights (W) used to build G were the reciprocal 
% of the speed.
path_weights = 1./path_weights;


end % function find_fastest_paths()

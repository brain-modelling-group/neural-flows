function [locs_idx_grid, locs_idx_mask] = find_locs_grid_idx(X, Y, Z, locs, in_bdy_mask)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find the linear index of the centre's of gravity defined in locs, with
% respect to the grid defined in X, Y, Z
% Returns indices with respect to the full grid and with respect to the
% mask

% REQUIRES  neural-flows/dis()
% is_nan_mask is a mask based on the velcoity compnentns. locsations of
% cogs seem to fall outside the in_bdy_mask

% Paula QIMR October 2019

num_points = size(locs, 1);
in_bdy_idx = find(in_bdy_mask);

S = [X(in_bdy_idx) Y(in_bdy_idx) Z(in_bdy_idx)].';
locs_idx_grid(num_points, 1) = 0;
locs_idx_mask(num_points, 1) = 0;

for kk = 1:num_points
    this_point = round(locs(kk, :).');
   d = dis(this_point, S);
   [~, idx] = min(d);
   locs_idx_grid(kk) = in_bdy_idx(idx); 
   locs_idx_mask(kk) = idx;
end

end % find_locs_grid_idx()


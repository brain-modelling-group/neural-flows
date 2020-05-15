function [neighbour_matrix] = build_neighbour_matrix(locs, nth_ring_matrix)
%% Returns a local patch of surface of the neighbourhood around a vertex.
%
% ARGUMENTS: nth_ring_matrix -- a sparse matrix with nonzero entries if the
%                               vertices are part of the nth ring neighbourhood. Weight is 1 divided by number of neighbours. 
%
% OUTPUT: 
%            neighbour_matrix --   
%         
% REQUIRES: 
%         
% USAGE:
%{
     
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find vertices/locs that do not have neighbouring triangles, that is they are not part of the triangulation 
temp = sum(full(nth_ring_matrix), 2);
neighbour_matrix = nth_ring_matrix;

% indices of zero entries
zero_idx = find(temp == 0);
neighbours = 6;
neighbour_idx(length(zero_idx), neighbours) = 0;

for kk=1:length(zero_idx)
    this_point = locs(zero_idx(kk), :);
    distance_vec = dis(this_point.', locs.');
    [~, idx] = sort(distance_vec);
    neighbour_idx(kk, :) = idx(2:neighbours+1); 
    nth_ring_matrix(zero_idx(kk), idx(2:neighbours+1)) = 1/neighbours;
end


end % function get_nth_ring_matrix()

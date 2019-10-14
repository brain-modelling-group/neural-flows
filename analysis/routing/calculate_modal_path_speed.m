function modal_path_speed = calculate_modal_path_speed(spaths, in_bdy_mask, uu, measure)
% Description of what this function does
%
% ARGUMENTS:
%          xxx -- description here
%          measure -- string
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
% uu -- the speed (velocity magnitude) at one timepoint, of the same size
% as X.

% NOTE: Wondering if I should save this vector instead of calculating it every
% time. TRadeoff between more input arguments or computing time.

if nargin < 4
    average_fun = @mode;
else
    switch measure
        case 'mode'
            average_fun = @mode;
        case {'mean', 'average'}
            average_fun = @mean;
        case 'median'
            average_fun = @median;
    end
end

% Find the indices of the mask with respect to the full grid
in_bdy_idx = find(in_bdy_mask);


[ntargets, nsources] = size(spaths);

% Get length of paths -- in number of hops
path_lengths = tril(cellfun(@length, spaths)-1, -1);

[path_row, path_col] = ind2sub([ntargets, nsources], find(path_lengths));
% Allocation
modal_path_speed(ntargets, nsources) = 0;

    for this_path=1:length(path_row)
        % The line below does the following:
        % 1) Get nodes/points in space that form the fastest path
        % 2) Get position of those points in the full grid
        % 3) Get the values of the speed
        % 4) Calculate the mode/average/median speed
        path_nodes = spaths{path_row(this_path), path_col(this_path)};
        modal_path_speed(path_row(this_path), path_col(this_path)) = average_fun(uu(in_bdy_idx(path_nodes)));

    end
    % Build symmetric matrix
    modal_path_speed = modal_path_speed + modal_path_speed';
end
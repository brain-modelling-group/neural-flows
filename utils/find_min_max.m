function [min_d, max_d] = find_min_max(data, minmax_mode)
% Finds minimum and maximum across all elements of data

if nargin < 2
    minmax_mode = 'none';
end

if strcmp(minmax_mode, 'symmetric')
    % Useful for diverging data around zero
    max_d =   max(abs(data(:)));
    min_d =  -max_d;
else
    min_d = min(data(:));
    max_d = max(data(:));
end


end
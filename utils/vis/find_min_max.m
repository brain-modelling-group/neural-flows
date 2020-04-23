function [min_d, max_d] = find_min_max(data, minmax_mode)
%% Finds minimum and maximum across all elements of input array data
%
% ARGUMENTS:
%        data        -- an nD array with numeical values (int, float, etc)
%        minmax_mode -- an string specifying what type of min max values the 
%                       function returns. The mode 'symmetric' is the only vailable
%                       alternative now. This mode is useful for diverging data around zero.
%                       The min max values returned are useful for setting
%                       caxis in image-based figures.
%
% OUTPUT: 
%        min_d -- scalar. Minimum value of data.
%        max_d -- scalar. Maximum value of data.
%
% REQUIRES: 
%        none
%
% USAGE:
%{
    
%}
%
% AUTHOR: 
%        Paula Sanz-Leon, QIMR Berghofer, 2019
% TODO: use switch case block once there are more minma_mode options
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


end % function fin_min_max()
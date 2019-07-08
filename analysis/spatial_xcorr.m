%% This function can be used to calculate the spatial dependence of 
%  temporal cross-correlation. It wraps Matlab's xcorr, with an additional
%  argument that passes a subset of neighbour points. Strictly speaking, 
%  this function IS NOT spatial correlation, although the name suggests that. 
%  What this function does: 
%                          Wraps Matlab's xcorr function to get auto and
%                          cross-correlation between two sets of (spatial) 
%                          points (specified in 'seed' and 'neighbours').
%                          If max_lag = 0, then returns the
%                          autocorrelation. If it is longer, it also
%                          returns an array of size [num_neighbours+1 x 2*max_lag+1].
% 
%                                                    
% ARGUMENTS:
%        data        -- array of size [tpts x num_nodes/channels];
%        seed_region -- integer with the index of region that will be taken 
%                       as the reference point.
%        max_lag     -- Integer. Maximum lag [in samples] used to calculate
%                       tmporal cross-correlation.
% 
%        neighbours  -- vector with the neighbouring node indices. This
%                       vector is used to calculate xcorr between seed_region 
%                       and a subset of
%                       regions/nodes/channels

% OUTPUT: 
%        
%        sp_acorr -- array of size [num_nodes x 1]. Autocorrelation at
%                    lag=0.
%        sp_xcorr -- array of size [num_neighbours+1 x 2*max_lag+1].
%                    Cross-correlation up to lag +/- max_lag.
%
% REQUIRES: 
%        None
%
% AUTHOR: 
%        Paula Sanz-Leon, QIMR 2019 
%
% USAGE: 
%{
    <example-commands-to-make-this-function-run>

%}
%

function [sp_acorr, varargout] = spatial_xcorr(data, seed_region, max_lag, neighbours)

if nargin < 3 
   max_lag = 0; % compute only autocorrelation by default
end

if nargin < 4
    neighbours = 1:size(data, 2);
end
 
num_neighbours = length(neighbours);
sp_acorr(num_neighbours+1, 1) = 0;

% Prepend the reference region
neighbours = [seed neighbours];

if max_lag > 0
    sp_xcorr(num_neighbours, 2*max_lag+1) = 0;

    for nn=1:num_neighbours
        [temp, ~] = xcorr(data(:, seed_region), data(:, neighbours(nn)), max_lag);
        idx = floor(max_lag/2)+1;
        sp_acorr(nn) = temp(idx);
        sp_xcorr(nn, :) = temp;
    end
        varargout{1} = sp_xcorr;
else
    for nn=1:num_neighbours
        [temp, ~] = xcorr(data(:, seed_region), data(:, neighbours(nn)), max_lag);
        idx = floor(max_lag/2)+1;
        sp_acorr(nn) = temp(idx);
    end 
end  
end %function spatial_xcorr()

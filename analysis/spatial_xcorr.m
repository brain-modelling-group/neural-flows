%% <ShortDescription>
%
%
% ARGUMENTS:
%        data        -- array of size [tpts x num_nodes/channels];
%        seed_region -- integer with the index of region that will be taken 
%                       as the refrence.
%        max_lag     -- integer maximum lag [in samples] used to calculate
%                       cross-correlation.
% 
%        neighbours  -- vector with the neighbouring node indices. This
%                       vector is used to calculate xcorr between seed_region 
%                       and a subset of
%                       regions/nodes/channels

% OUTPUT: 
%        
%        sp_acorr -- array of size [num_nodes x 1]. Autocorrelation at
%                    lag=0.
%        sp_xcorr -- 
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
 
num_nodes = length(neighbours);
sp_acorr(num_nodes, 1) = 0;

if max_lag > 0
    sp_xcorr(num_nodes, 2*max_lag+1) = 0;

    for nn=1:num_nodes
        [temp, ~] = xcorr(data(:, seed_region), data(:, neighbours(nn)), max_lag);
        idx = floor(max_lag/2)+1;
        sp_acorr(nn) = temp(idx);
        sp_xcorr(nn, :) = temp;
    end
        varargout{1} = sp_xcorr;
else
    for nn=1:num_nodes
        [temp, ~] = xcorr(data(:, seed_region), data(:, neighbours(nn)), max_lag);
        idx = floor(max_lag/2)+1;
        sp_acorr(nn) = temp(idx);
    end 
end  
end %function spatial_xcorr()

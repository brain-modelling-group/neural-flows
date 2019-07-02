%% <ShortDescription>
%
%
% ARGUMENTS:
%        data        -- array of size [tpts x num_nodes/channels];
%        seed_region -- integer with the index of region that will be taken 
%                       as the refrence.
%
% OUTPUT: 
%        
%        <output2> -- <description>
%
% REQUIRES: 
%        <other-functions-required-by-this-one-if-none-type-none>
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
%

function [sp_xcorr, varargout] = spatial_xcorr(data, seed_region, max_lag, neighbours)

if nargin < 3 
   max_lag = 0; % autocorrelation
end

if nargin < 4
    neighbours = 1:size(data, 2);
end
 
num_nodes = length(neighbours);
sp_acorr(num_nodes, 1) = 0;

if max_lag > 1
    sp_xcorr(num_nodes, 2*max_lag-1) = 0;

    for nn=1:num_nodes
        [temp, ~] = xcorr(data(:, seed_region), data(:, neighbours(nn)), max_lag);
        idx = floor(max_lag/2)+1;
        sp_acorr(nn) = temp(idx);
        sp_xcorr(nn, :) = temp;
    end
else
    for nn=1:num_nodes
        [temp, ~] = xcorr(data(:, seed_region), data(:, neighbours(nn)), max_lag);
        idx = floor(max_lag/2)+1;
        sp_acorr(nn) = temp(idx);
    end 
    varargout(1) = sp_acorr;
end  
end %function spatial_xcorr()

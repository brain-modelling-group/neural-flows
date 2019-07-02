%% <ShortDescription>
%
%
% ARGUMENTS:
%        data        -- array of size [tpts, num_nodes];
%        seed_region -- integer with the region that will be taken as the
%                       refrence.
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

function [sp_corr] = spatial_xcorr(data, seed_region, max_lag)

if nargin < 3 
   max_lag = 0; % autocorrelation
end

num_nodes = size(data, 2);
sp_corr(num_nodes, 1) = 0;

for nn=1:num_nodes
    [temp, ~] = xcorr(data(:, seed_region), data(:, nn), max_lag);
    idx = floor(max_lag/2)+1;
    sp_corr(nn) = temp(idx);    
end
  
end %function spatial_xcorr()

function [dwell_times, jump_times] = extract_energy_dwelltimes(data, opts)
% Estimate dwelltimes of data -- based on compute_cohcorrgram_dwelltimes.m
% ARGUMENTS:
%        data   -- a 2D array of size [time x nodes/locs/vertices]; 
%        opts -- a struct with fields:
%                .threshtype -- a string with the type of threshold to apply.
%                .dt         -- timestep/sampling period
%
% OUTPUT: 
%        dwell_times -- a vector with dwell times. 
%        jump_times  -- a vector with the jump/transition times.
%
% REQUIRES: 
%        extractbursts()
%
% USAGE:
%{

%}
%

if nargin < 2
    opts.threshtype = 'mean';
    opts.metrictype = 'inverse_var';
end

% which metric -- this is something like the fano factor.
switch opts.metrictype
    case 'inverse_var'
        metric = 1./var(data, 0, 1);
    case 'none'
        metric = data;
    otherwise
        if  ischar(opts.metrictype) % check that metric is a string
            error(['neural-flows:: ', mfilename, '::Unknown metric option.'])
        else
            % pass the metric to be used as bursty data
            metric = opts.metric;
        end
end 
    
% which threshold
switch opts.threshtype
    case 'mean'
        transitionthr = nanmean(metric);
    case 'median'
        transitionthr = nanmedian(metric);
    case 'mean+1sd'
        transitionthr = nanmean(metric) + nanstd(metric);
    case 'mean+2sd'
        transitionthr = nanmean(metric) + 2*nanstd(metric);
    case 'mean+3sd'
        transitionthr = nanmean(metric) + 3*nanstd(metric);
end

% Detect upward zero-crossings
upcrossings = find(diff(metric-transitionthr>=0)==1);
% Pull out the suprathreshold segments
avs = extractbursts(metric, transitionthr); 
% Use the peak as the representative transition time
jump_times = cellfun(@(x) find(x==max(x)), avs).' + upcrossings(1:length(avs))-1; 
% Estimate dwell times
dwell_times = diff(jump_times)*(opts.dt); % dwell times


end % function extract_energy_dwelltimes()

function [dwell_times, jump_times] = compute_cohcorrgram_dwelltimes(CC, opts)
% Estimate metastable states dwelltimes, based on cohcorrgram.m
% ARGUMENTS:
%        CC   -- a struct obtained with crosscorrgram, with fields:
%                .cc -- correlation coefficient.
%                .ct -- correlation time vector.
%
%        opts -- a struct woth fields:
%                .threshtype -- a string with the type of threshold to apply.
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
    opts.threshtype='mean';
    opts.metric = 'inverse_var';
end

% which metric -- this is something like the fano factor.
switch opts.metric
    case 'inverse_var'
        metric = 1./var(CC.cc, 0, 1);
    otherwise
        if  ischar(opts.metric) % check that metric is not string
            error(['neural-flows:: ', mfilename, '::Unknown metric option.'])
        else
            % pass the metric to be used as a vector
            metric = opts.metric;
        end
end 
    
% which threshold
switch opts.threshtype
    case 'mean'
        transitionthr = nanmean(metric);
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
jumpsi = cellfun(@(x) find(x==max(x)),avs) + upcrossings(1:length(avs))-1; 
% Estimate dwell times
dwell_times = diff(jumpsi)*(CC.ct(2)-CC.ct(1)); % dwell times

if nargout > 1
    jump_times = CC.ct(jumpsi);
end
end % function compute_cohcorrgram_dwelltimes()

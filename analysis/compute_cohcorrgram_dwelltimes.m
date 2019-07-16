function [dwellts,jumpts] = compute_cohcorrgram_dwelltimes(CC,opts)
% dwellts = cohcorrgram_dwelltime(CC,opts)

if nargin<2
    opts.threshtype='mean';
end

% which metric
metric=1./var(CC.cc,0,1);
% which threshold
switch opts.threshtype
    case 'mean'
        transitionthr=nanmean(metric);
    case 'mean+1sd'
        transitionthr=nanmean(metric)+nanstd(metric);
end

upcrossings=find(diff(metric-transitionthr>=0)==1);
avs=extractbursts(metric,transitionthr); % pull out the suprathreshold segments
jumpsi=cellfun(@(x) find(x==max(x)),avs)+upcrossings(1:length(avs))-1; % use the peak as the representative transition time
dwellts=diff(jumpsi)*(CC.ct(2)-CC.ct(1)); % dwell times

if nargout>1
    jumpts=CC.ct(jumpsi);
end
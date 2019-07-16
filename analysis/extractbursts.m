function out = extractbursts(y,thr,nburstsflag)
% EXTRACTBURSTS extracts bursts from a given time series of data from
% the first positive value increasing before 'thr'to the last value after 
% decreasing at the value specified at input 'thr'
% 
%   Inputs:
%   y = timeseries data
%   thr = threshold value
%   nburstsflag (optional) = 1 to not output the bursts, just nbursts
% 
% modified by JR 25/09/12 - no longer outputting a cell within a cell, not
%     omitting first fluctuation, renamed power_flucts to y, added 1 to end
%     of range of each fluct (to get from <=0 to next <=0)
% modified by JR on 15/01/13 - renamed ithr to thr, changed to work on
%     x=y-thr (prev was incorrect for nonzero thr)
% renamed by JR on 13/02/13 to extractbursts.m (was fluctuations.m)
% modified by JR on 13/05/13 - optional argument nburstsflag returns only
%     number of bursts not the bursts themselves ==> quicker for nthrstest

if nargin<3
    nburstsflag=0;
end

% Shift y to have zero threshold
x=y-thr;

% Find crossings first and last
crossings=diff(x>=0);
upcrossings=find(crossings==1);
downcrossings=find(crossings==-1);

% if x(1)==0 and x(2)>0, 1st fluct not caught by the above so add it now
if x(1)==0 && x(2)>0
    upcrossings=[1 upcrossings];
end

% Check whether there is at least one suprathreshold fluctuation
if isempty(downcrossings)||isempty(upcrossings)
    out=emptyout();
    return
end

if downcrossings(1)<upcrossings(1) % if first down comes before first up
    if length(downcrossings)>1
        downcrossings=downcrossings(2:end);
    else
        out=emptyout(); % there was only 1 down, time series is U shaped
        return
    end
end
if downcrossings(end)<upcrossings(end)
    upcrossings=upcrossings(1:end-1);
end

nflucts=length(upcrossings);

if nburstsflag % if only want nbursts, end now
    out=nflucts;
    return
end

store_flucts=cell(1,nflucts);

for j=1:nflucts
    store_flucts{j}=x(upcrossings(j):downcrossings(j)+1);
end

out=store_flucts;

    function o=emptyout
        if nburstsflag
            o=0;
        else
            o={};
        end
    end

end


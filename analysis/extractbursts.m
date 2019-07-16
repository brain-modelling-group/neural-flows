function out = extractbursts(data, thr, nburstsflag)
% Extracts bursts of activity from a given time series of data from the 
% first positive value increasing before 'thr' to the last value after 
% decreasing at the value specified at input 'thr'
% 
% ARGUMENTS:
%          data    --  a 1D array of size [time x 1] with the bursty data.
%          thr     --  a float with the threshold to detect bursts
%          nburstflag -- an boolean flag to determine if the output are the
%                        bursts (out is a cell) or the number of bursts (out is a number). 
%                        Default 0. 
%
% OUTPUT: 
%          bursts     --  a cell (nburstflag=0) with the suprathreshold bursts,
%                         or a number (nburstflag=1) with the number of
%                         bursts detected.
%
% REQUIRES: 
%          None.
%
% USAGE:
%{     
    x   = abs(randn(1024, 1));
    thr = mean(x);
    out = extractbursts(x, thr, 0); 
    fig_handle = figure('Name', 'nflows_bursts')
    ax = axes('Parent', fig_handle);
    hold(ax, 'on')
    cellfun(@(x) plot(x), out)
    xlabel('burst length [samples]')

%}
% MODIFICATION HISTORY:
%     JA Roberts, QIMR Berghofer, 2012-2019
%     JR 25/09/12 -- no longer outputting a cell within a cell, not
%                    omitting first fluctuation, renamed power_flucts to y, 
%                    added 1 to end of range of each fluct (to get from <=0 to next <=0)
%
%     JR 15/01/13 -- renamed ithr to thr, changed to work on
%                       x=y-thr (prev was incorrect for nonzero thr)
%     JR 13/02/13 -- renamed to extractbursts.m (was fluctuations.m)
%     JR 13/05/13 -- optional argument nburstsflag returns only
%                    number of bursts not the bursts themselves ==> 
%                    quicker for nthrstest
%     PSL 2019/07 -- document + additional history on github

if nargin < 3
    nburstsflag = 0;
end

% Shift y to have zero threshold
x = data - thr;

% Find crossings first and last
crossings    = diff(x>=0);
upcrossings  = find(crossings == 1);
downcrossings= find(crossings ==-1);

% if x(1)==0 and x(2)>0, 1st fluct not caught by the above so add it now
if x(1)==0 && x(2)>0
    upcrossings = [1 upcrossings];
end

% Check whether there is at least one suprathreshold fluctuation
if isempty(downcrossings) || isempty(upcrossings)
    out=emptyout();
    return
end

if downcrossings(1) < upcrossings(1) % if first down comes before first up
    if length(downcrossings) > 1
        downcrossings=downcrossings(2:end); % remove first downcrossing
    else
        out = emptyout(); % there was only 1 downcrossing, timeseries is U shaped
        return
    end
end
if downcrossings(end)<upcrossings(end)
    upcrossings=upcrossings(1:end-1);
end

nflucts = length(upcrossings);

if nburstsflag % if only want number of bursts bursts, end now
    out = nflucts;
    return
end

store_flucts = cell(1, nflucts);

for jj=1:nflucts
    store_flucts{jj} = x(upcrossings(jj):downcrossings(jj)+1);
end

out = store_flucts;

function o=emptyout
    if nburstsflag
        o = 0;
    else
        o={};
    end
end

end % function extractbursts()

function [stable, transient, stablePoints, transientPoints] = classify_energy_states(energy, time_vec, sampling_period, min_duration, extrema_detection, display_flag)
% compute_energy_states  Computation of low and high energy states based on optical flow estimates 
% INPUT ARGUMENTS:
%   energy              -- a vector with the kinetic energy estimates
%   time_vec            -- a vector with the time of the flow field (time_flow) vector 
%                          between which the energy states will be calculated and classified
%
%   sampling_period     -- time (ms) between two samples, used to defined the minimu span of a microstates 
%
%   min_duration        -- scalar, time (ms) expressing the minimal
%                          duration of a state. Default: 10ms
%
%   extrema_detection   -- string with the method used to detect local
%                          extrema. {'peaks' | 'valleys'}.
%
%   display_flag        -- flag to plot displacement energy vs time and timepoints 
%                          labeled as non-transition or transition state
% OUTPUT ARGUMENTS:
%   stable              -- array of size [rows, 2] where each row contains 
%                          the start and stop index of a stable state
%
%   transient           -- array of size [rows, 2] where each row contians 
%                          the start and stop of a fast state
%   stablePoints        -- All times during which flow has "low kinetic energy"
%
%   transientPoints     -- All times during which flow is "high kinetic energy"
%
%   energy               -- displacement energy in the flow field,
%                           summed over space, 
% REQUIRES: 
%         None
%
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     Modified, PSL, QIMR Berghofer 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if display_flag
    figure_handle = figure;
    ax_handles(1) = subplot(2,1,1, 'Parent', figure_handle);
    ax_handles(2) = subplot(2,1,2, 'Parent', figure_handle);
end

% Setup: get displacement energy, this is a kinectic energy-like expression: 1/2 m v^2
% The mass is m=1. This step calculates the averagsamplingIntervale kinetic energy per edge
% adds them all and multiply it by the area of the triangle.

% NOTE: use extractbursts to do this, seems to be more efficient.


% Find local extrema
start_idx = 1;
end_idx   = length(energy);

if strcmp(extrema_detection, 'peaks')
    find_local_extrema = @find_local_extrema_peaks;
else
    find_local_extrema = @find_local_extrema_valleys;
end

% Minima
find_max = false;
minima = find_local_extrema(energy, find_max, start_idx, end_idx);
minima = sortrows([energy(minima); minima]').'; 
minima = minima(2,:);

% Maxima
find_max = true;
maxima = find_local_extrema(energy, find_max, start_idx, end_idx);
maxima = sortrows([-energy(maxima); maxima]').'; 
maxima = maxima(2,:);

% Display displacement energy and locations of maxima/minima
if display_flag
  hold(ax_handles(1), 'on')
  plot(ax_handles(1), time_vec, energy, 'color', [0.8 0.8 0.8])
  xlabel('Time [ms]')
  ylabel('\partial Energy')
  ax_handles(1).XLim = [time_vec(1) time_vec(end)];
  ax_handles(1).YLim = [0.95*min(energy) 1.05*max(energy)];
  plot(ax_handles(1), time_vec(minima), energy(minima), 'linestyle', 'none', ...
      'marker', 'v', 'markerfacecolor', [111,203,159]/255, 'markeredgecolor', 'none') 
  plot(ax_handles(1), time_vec(maxima), energy(maxima), 'linestyle', 'none', ...
      'marker', '^', 'markerfacecolor', [255,111,105]/255, 'markeredgecolor', 'none');
  
  ax_handles(1).XLabel.String = 'time [ms]';
  ax_handles(1).YLabel.String ='\partial Energy';
  ax_handles(1).Box = 'on';
end


% Find transient states
transient = find_transient_states(energy, maxima, minima);
transient = sortrows(transient);

% Find nontransient states
stable = find_nontransient_states(energy, maxima, minima, transient);
stable = sortrows(stable);

% Get list of transient and stable state intervals
% Non-transient states -> 0 
% Transient states -> 1

extrema = clean_flow_states(transient, stable, sampling_period, min_duration);

transient = extrema(extrema(:,3) > 1-eps, 1:2); transientPoints = [];
for m = 1:length(transient)
  transientPoints = [transientPoints transient(m,1):transient(m,2)];
end
stable = extrema(extrema(:,3) < eps, 1:2); stablePoints = [];
for m = 1:length(stable)
  stablePoints = [stablePoints stable(m,1):stable(m,2)];
end

% Display microstate interval on displaced energy curve
if display_flag
  hold(ax_handles(2), 'on')
  plot(ax_handles(2), time_vec, energy, 'color', 'k', 'linewidth', 0.5) 
  for m = 1:size(extrema,1)
    if abs(extrema(m,3)) < eps % Stable states
      color = [111,203,159]/255;
    elseif extrema(m,3) > 1-eps % Transient states
      color = [255,111,105]/255;
    end
    area(ax_handles(2), time_vec(extrema(m,1):extrema(m,2)), energy(extrema(m,1):extrema(m,2)), 'FaceColor', color, 'EdgeColor', 'None');
  end
    ax_handles(2).XLim = [time_vec(1) time_vec(end)];
    ax_handles(2).YLim = [0.95*min(energy) 1.05*max(energy)];
    ax_handles(2).XLabel.String ='time [ms]';
    ax_handles(2).YLabel.String ='\partial Energy';
    ax_handles(2).Box = 'on';
end

end % function compute_neuralflow_states()

%% ================== CLEAN SMALL INTERVALS ================================
function extrema = clean_flow_states(transient, stable, sampling_period, min_duration)
% minimal duration of a state in samples
if isempty(min_duration)
    min_duration = 2; % in [ms]
end

min_duration_samples = floor(min_duration/sampling_period);

if min_duration_samples < 1
  min_duration_samples = 1;
end

% Swallow intervals that are of shorter than min_duration_samples into intervals of longer length
% Extrema contains the indices for the time vector with start and end time
% of stable and unstable of transient states
extrema = sortrows([transient ones(size(transient,1), 1); stable zeros(size(stable,1), 1)]);

for m = 2:size(extrema,1)
  if extrema(m,2) < extrema(m,1) + min_duration_samples % Check that start and end times are at least minInterval apart
    if extrema(m-1,2) > extrema(m,1) - min_duration_samples % Check that end time of previous extrema and start time of new extrema are at least min Interval apart
      if extrema(m,2)-extrema(m,1) > extrema(m-1,2)-extrema(m-1,1) % Chec current extrema interval is larger then previous extrema interval 
        tag = extrema(m,3);
      else
        tag = extrema(m-1,3);
      end
      extrema(m-1,2) = extrema(m,2);   % 2nd interval's beginning is 1st interval
      extrema(m,1)   = extrema(m-1,1); % 1st interval's end is 2nd inte%     Original, Julien Lefevre -- brainstorm
      extrema(m-1,3) = tag; % Both get same label ...
      extrema(m,3)   = tag; % ... of the bigger interval
    elseif m < size(extrema,1) && extrema(m,2) > extrema(m+1,1) - min_duration_samples
      if extrema(m,2)-extrema(m,1) > extrema(m+1,2)-extrema(m+1,1)
        tag = extrema(m,3);
      else
        tag = extrema(m+1,3);
      end
      extrema(m,2) = extrema(m+1,2); % 2nd interval's beginning is 1st interval
      extrema(m+1,1) = extrema(m,1); % 1st interval's end is 2nd interval
      extrema(m,3) = tag;   % Both get same label ...
      extrema(m+1,3) = tag; % ... of the bigger interval
    else
      extrema(m,1) = max(extrema(m,1) - min_duration_samples, 1); % 2nd interval's beginning is 1st interval
      extrema(m,2) = min(extrema(m,2) + min_duration_samples, 1); % 1st interval's end is 2nd interval
    end
  end
end

% Merge consecutive states of the same type
for m = 2:size(extrema,1)
  if abs(extrema(m,3)-extrema(m-1,3)) < eps
    n = m+1;
    while n <= size(extrema,1) && abs(extrema(n,3)-extrema(n-1,3)) < eps
      n = n+1;
    end      
    extrema((m-1):(n-2),2) = extrema(n-1,2); % 2nd interval's beginning is 1st interval
    extrema(m:(n-1),1) = extrema(m-1,1); % 1st interval's end is 2nd interval
  end
end

% Prune list down to unique states
extrema([false; diff(extrema(:,1)) < eps], :) = [];

end % function clean_flow_states()

% ======================= INTERVALS OF TRANSIENT STATES ===================
function transient = find_transient_states(energy, maxima, minima)
% TRANSIENT_STATES    Determine intervals of transient/high-energy activity, starting
%                     from peak of displacement energy to **sufficiently close to valleys** 
%                     of displacement activity
% INPUTS:
%   energy       - displacement energy in flow
%   maxima       - indices of time points of maximal flow
%   minima       - indices of time points of minimal flow
%
% OUTPUTS:
%   transient     - List where each row is a 2-element pair of an interval
%                   where flow is transient/high-energy

transient = []; 
minima = sort(minima);

for m = 1:length(maxima)
    loc   = maxima(m); 
    value = energy(loc);
  
    % Threshold between states is halfway between max and min of displacement
    prev_min = minima(find(minima < loc, 1, 'last')); % Last minima point before the current maximum
    if isempty(prev_min)
        prev_min = 0;
        b = 0; % If no min point before max, set value of 0 as energy at prev_min
    else
        b = energy(prev_min); % Otherwise, set value of energy at prev_min
    end
  
  next_min = minima(find(minima > loc, 1, 'first')); % First minima after current maximum
  if isempty(next_min)
    next_min = length(energy)+1;
    a = 0; % If no stable point after max, set value of energy as 0 at next_min
  else
    a = energy(next_min); % Otherwise, set value of energy at next_min
  end
  
  % NOTE: the threshold value is arbitrary
  threshold = value - (value - max(b, a)) * (1/sqrt(2)); % Threshold of transient activity
  
  % Find beginning and end of interval of displacement above threshold
  start_idx = find(energy(1:(loc-1)) <= threshold, 1, 'last'); % Last time before
  stop_idx  = find(energy((loc+1):end) <= threshold, 1, 'first') + loc; % First time after

  % Current interval cannot include minima locations
  if isempty(start_idx) || start_idx <= prev_min
    start_idx = prev_min+1; % shift by one location at least
  end
  if isempty(stop_idx) || stop_idx >= next_min
    stop_idx = prev_min-1;
  end
  
  % Save start:stop of transient/high-energy microstate
  transient = [transient; start_idx stop_idx];
end

end

% =================== INTERVALS OF NONTRANSIENT STATES ==========================
function stable = find_nontransient_states(energy, maxima, minima, transient)
% STABLE_STATES    Determine intervals of slow activity, starting
%                  from valleys of displacement energy to sufficiently
%                  close to peaks of displacement activity. This is run
%                  after TRANSIENT_STATES, so as to ensure a stable state
%                  is disjoint from all transient states
% INPUTS:
%   energy       - displacement energy in flow
%   maxima        - time points of max
%   minima        - time points of minimal flow
%   transient     - List where each row is a 2-element pair of an interval
%                   where flow is "fast", used to ensure disjoint intervals
%                   between all states (transient or stable)
% OUTPUTS:
%   stable              - List where each row is a 2-element pair
%                         containing the start and stop of a stable state

energy = -energy; 
stable = []; 
maxima = sort(maxima);

for mm = 1:length(minima)
    
    loc = minima(mm); 
    value = energy(loc);
  
    % Threshold between states is halfway between min and max of displacement
    prev_max = maxima(find(maxima < loc, 1, 'last')); % Last transient/maximum 
    if isempty(prev_max)
        prev_max = 0;
        b = 0; % If no transient point prev_max, use 0 as last transient energy
    else
        b = energy(prev_max); % Otherwise, get last transient energy
    end
  
    next_max = maxima(find(maxima > loc, 1, 'first')); % First maximum after 
    if isempty(next_max)
        next_max = length(energy) + 1;
        a = 0; % If no transient point after max, use 0 as next transient energy
    else
        a = energy(next_max); % Otherwise, get next transient energy
    end
  
      % Sorta adaptive threshold based on local value of energy
      threshold = value - (value - max(b, a)) * (1/sqrt(2));
  
      % Find beginning and end of interval of displacement above threshold
      start_idx = find(energy(1:(loc-1))  <= threshold, 1, 'last');  % Last time prev_max
      stop_idx  = find(energy((loc+1):end)<= threshold, 1, 'first') + loc; % First time next_max

  % Current interval cannot start earlier than end of last interval
  if isempty(start_idx) || start_idx <= prev_max 
    start_idx = prev_max+1;
  end
  if isempty(stop_idx) || stop_idx >= next_max
    stop_idx = next_max-1;
  end
  
  % Trim interval if it encroaches on a transient state
  for m = 1:size(transient,1)
    if transient(m,1) < start_idx && start_idx < transient(m,2)
      start_idx = transient(m,2);
    elseif transient(m,1) < stop_idx && stop_idx < transient(m,2)
      stop_idx = transient(m,1);
    end
  end
  
  % Label microstate
  if stop_idx-start_idx >= 1
    stable = [stable; start_idx stop_idx];
  end
end

end

%=============== LOCAL EXTREMA OF A CURVE =================================
function extrema = find_local_extrema_peaks(signal, find_max, tStart, tEnd)
% Find locations of local extrema in signal using matlab's fidndpeaks
% INPUTS:
%   signal            - curve for which we find maxima OR minima
%   find_max          - flag: find local maxima (true) or local minima (false)
%   tStart            - start of search
%   tEnd              - end of search
%
% OUTPUTS:
%   extrema           - Locations of local extrema

% Preprocessing: smoothing of signal for initial extrema
if ~find_max % Local maxima == local minima of negative signal
    signal = -1.*signal;
end

smoothingFilter = [0.5 1 0.5]/3;
s = signal;

% Five consecutive convolutions of the signal, except for the endpoints
s = conv(s, smoothingFilter, 'same');
s(tStart) = signal(tStart); 
s(tEnd)   = signal(tEnd);

s = conv(s, smoothingFilter, 'same');
s(tStart) = signal(tStart); 
s(tEnd) = signal(tEnd);

s = conv(s, smoothingFilter, 'same');
s(tStart) = signal(tStart); 
s(tEnd) = signal(tEnd);

s = conv(s, smoothingFilter, 'same');
s(tStart) = signal(tStart); 
s(tEnd) = signal(tEnd);

s = conv(s, smoothingFilter, 'same');
s(tStart) = signal(tStart); 
s(tEnd) = signal(tEnd);

[~, peak_locs] = findpeaks(s);

% Don't use first or last time point as extremum
extrema = peak_locs;
extrema(extrema <= tStart | extrema >= tEnd) = [];
extrema = unique(extrema);

end % function find_local_extrema_peaks()

%=============== LOCAL EXTREMA OF A CURVE =================================
function extrema = find_local_extrema_valleys(signal, find_max, tStart, tEnd)
% Find locations of local extrema in signal detecting valleys
% INPUTS:
%   signal            - curve for which we find maxima OR minima
%   find_max          - flag: find local maxima (true) or local minima (false)
%   tStart            - start of search
%   tEnd              - end of search
%
% OUTPUTS:
%   extrema           - Locations of local extrema

% Preprocessing: smoothing of signal for initial extrema
if find_max % Local maxima == local minima of negative
  signal = -1*signal;
end
valleys = []; 
smoothingFilter = [0.5 1 0.5]/3; 
s = signal;

% Five consecutive convolutions of the signal, except for the endpoints
s = conv(s, smoothingFilter, 'same');
s(tStart) = signal(tStart); 
s(tEnd)   = signal(tEnd);

s = conv(s, smoothingFilter, 'same');
s(tStart) = signal(tStart); 
s(tEnd) = signal(tEnd);

s = conv(s, smoothingFilter, 'same');
s(tStart) = signal(tStart); 
s(tEnd) = signal(tEnd);

s = conv(s, smoothingFilter, 'same');
s(tStart) = signal(tStart); 
s(tEnd) = signal(tEnd);

s = conv(s, smoothingFilter, 'same');
s(tStart) = signal(tStart); 
s(tEnd) = signal(tEnd);

% Find local minima (of flipped signal if maxima desired)
for t = (tStart+2):(tEnd-1)
  if s(t) < s(t-1) 
    if s(t) < s(t+1) % Definite dip
      valleys(end+1) = t;
    elseif s(t) < s(t-1) && s(t) < s(t+1) + 1e-8*abs(s(t)) % Plateau
      tEnd = t+1;
      while abs(s(tEnd)-s(tEnd+1)) < 1e-8*abs(s(tEnd)) && tEnd < (length(s)-1) % Ride plateau to end
        tEnd = tEnd+1;
      end
      valleys(end+1) = floor((t+tEnd)/2);
      t = tEnd;
    end
  end
end

% Ensure minimum over small range (5 samples)
extrema = [];
for m = 1:length(valleys)
  jitter = valleys(m) + (-2:2);
  jitter = jitter(1 <= jitter & jitter <= length(signal));
  [~, idx] = min(signal(jitter));
  extrema(m) = idx + jitter(1) - 1;
end

% Don't use first or last time point as extremum
extrema(extrema <= tStart | extrema >= tEnd) = [];
extrema = unique(extrema);

end % function find_local_extrema_valleys()

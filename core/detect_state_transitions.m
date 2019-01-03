function [out]= detect_state_transitions(dEnergy)
% Detect state transitions as peaks of energy in the flow
% This is a basic functionusing Matlab's findpeaks
% INPUT ARGUMENTS:
%   dEnergy             -- timeseries of displacement energy
%   threshold           -- some sort of threshold
%   embedding_dimension -- dimension of the embedding space 
%                          3: for mesh surfaces  (eg, sphere)
%                          2: for projections on 2D (eg, disk)
%
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
%   energy_mode         -- string with the mode we should use to
%                          calculate energy. {'vertex', 'triangle'}
%   display_flag        -- flag to plot displacement energy vs time and timepoints 
%                          labeled as non-transition or transition state
% OUTPUT ARGUMENTS:
%   peak_locs           -- array of size [rows, 2] where each row contains 
%                          the start and stop index of a stable state
%
%   transient           -- array of size [rows, 2] where each row contians 
%                          the start and stop of a fast state
%   stablePoints        -- All times during which flow has "low kinetic energy"
%
%   transientPoints     -- All times during which flow is "high kinetic energy"
%
%   dEnergy             -- sqrt of displacement energy in the flow field,
%                          summed over space, depends if 
%   dEnergyF            -- displacement energy in the flow field,
%                          returns energy for every face area of the mesh
%                          array of size [num_faces, interval(2)-interval(1)]
% 
%   dEnergyV            -- displacement energy  in the flow field,
%                          returns energy for every vertex area in the domain
% REQUIRES: 
%         None
%
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     Original, Julien Lefevre -- brainstorm


%% Test dbscan function for classification

av_e  = mean(dEnergy);
std_e = std(dEnergy);

[C, ptsC, centres] = dbscan(dEnergy, std_e, 1);

%% Try additional filtering to detect transitions times
sampling_period = time_flow(2)-time_flow(1);
filt_length_t = 10; % ms
filt_length = round(filt_length_t / sampling_period);
filt_fn =  ones(1,filt_length)/filt_length;
s = conv(dEnergy, filter_fn, 'same');
av_s = mean(s);
std_s = std(s);
[~, locs] = findpeaks(s, 'MinPeakHeight', av_s+1.5*std_s);



end % function detect_state_transitions()
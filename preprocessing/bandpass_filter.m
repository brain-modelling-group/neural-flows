%% Basic functionality to bandapass-filter data, a wrapper of butteworth filters
%
% ARGUMENTS:
%          data    --  a 2D array of size [time x nodes/locs/channels/vertices] with activity.
%          flo     --  a float with the low-frequency cutoff in Hz.
%          fhi     --  a float with the high-frequency cutoff in Hz.
%          filter_order -- an integere with the filter order. 
%          fs      -- a float with the sampling frequency of data, in Hz.
%
% OUTPUT: 
%          datafiltered  --  a 2D array of size [time x nodes/locs/channels/vertices] 
%                            with the frequencies in the range [flow fhi].
%
% REQUIRES: 
%
% USAGE:
%{     

%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon, QIMR Berghofer 2019 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [datafiltered] = bandpass_filter(data, flo, fhi, filter_order, fs)

% Build Butterworth filter
cutoff_freqs = [flo fhi];
% Normalised frequency 
wn = cutoff_freqs / (fs/2);
[b, a] = butter(filter_order, wn); 
% Filter data
datafiltered = filtfilt(b, a, data);
end % function bandpass_filter()

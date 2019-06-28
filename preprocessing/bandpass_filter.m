function [datafiltered] = bandpass_filter(data, flo, fhi, filter_order, fs)
% Basic functionality to bandapass-filter data, wrapper of butteworth filter 
%
%
% x - data  2d array of size (timepoints, channels/sensing locations/etc)
% flow - low-frequency cutoff
% fhi  - high-frequency cutoff
% filter_order - filter order 
% fs - sampling frequency
%
% OUTPUT
% Paula Sanz-Leon, QIMR 2019 

% Build Butterworth filter
cutoff_freqs = [flo fhi];
% Normalised frequency 
wn = cutoff_freqs / (fs/2);
[b, a] = butter(filter_order, wn); 

% Filter data
datafiltered = filtfilt(b, a, data);
end % function bandpass_filter()

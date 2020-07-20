function fmri_waves(case_label)
% This script runs the whole neural-flows workflow on a small epoch of 
% fmri data. Relevant links below. 
%
% Original dataset:
% (a) fmri developmental dataset from nilearn
% (b) Parcellated timeseries using Schaefer 2018 atlas with 400 ROIs
% (c) Parcellation done with nilearn
% Bilbiographic reference:
% https://www.nature.com/articles/s41467-018-03399-2

% Experimental protocol: 
% We use the reference group of 33 adults, watched a short, animated 
% movie that included events evoking the mental states and physical sensations of 
% the characters, while undergoing fMRI. This movie has been validated as 
% activating Theory of Mind brain regions and the pain matrix in adults. 

% Data:
% The data analysed in this script was made as follows:
% 1)  parcellated 3D+t data, averaged over 33 adult subjects;
% 2)  linear interpolation making the sampling period 0.5 seconds, instead
%     of original TR=2s;
% NOTE: Assumes this function is run from the top level directory neural-flows/


if nargin < 1
    case_label = 'uah';
end

switch case_label
    case 'uah'
        input_params_filename = 'fmri_waves_uah_in.json';
    case 'uac'
        input_params_filename = 'fmri_waves_in_uac.json';
    case 'upc'
        input_params_filename = 'fmri_waves_in_uap.json';
end

input_params_dir  = 'examples';
json_mode = 'read';

% Load options
input_params = read_write_json(input_params_filename, input_params_dir, json_mode);
%% Run core functions: interpolation, estimation and classification, streamlines, this function writes to a new json file
output_params = main_core(input_params); 

%% Run basic analysis
main_analysis(output_params);

%% Visualisation
main_visualisation(output_params);

end %function fmri_waves()
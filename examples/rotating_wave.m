% This script runs the whole neural-flows workflow on a small epoch of
% simulated data, that mostly corresponds to rotating wave.

% Performance: This takes about 5 minutes to run with 11 workers for parallel
% functions. Memory usage is approximately 6GB.

input_params_filename = 'rotating_wave_in.json';
input_params_dir  = '/home/paula/Work/Code/matlab-neuro/neural-flows/examples';
json_mode = 'read';

% Load options
input_params = read_write_json(input_params_filename, input_params_dir, json_mode);
%%
% Run interpolation, estimation and classification, this function writes to a new json file
output_params = main(input_params); 

% Analyse and visualise
%perform_mode_decomposition_svd(output_params);

%analyse_singularities(output_params)

%plot1d_speed_distribution(output_params)

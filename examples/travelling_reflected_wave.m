function travelling_reflected_wave(case_label)
% This script runs the whole neural-flows workflow on a small epoch of simulated 
% data, that corresponds to a travelling wave moving along the y-axis (front to back)
% and back.  
% NOTE: Assumes this function is run from the top level directory neural-flows/

% PERFORMANCE:
% |    Host   | Data Domain    | Data Mode   | Flow Method     | # workers  |  Runtime |  Memory |
% |-----------|----------------|-------------|-----------------|------------|----------|---------|
% | tesseract | (u)nstructured | (a)mplitude | (h)orn-schunk3d |      6     |  3.73 min| XX  GB  |  
% TODO: test performance

if nargin < 1
    case_label = 'u-a-hs-mb';
end

switch case_label
    case 'u-a-hs-mb'
        input_params_filename = 'travelling-reflected-wave_unstructured-amplitude-hs-meshbased_input.json';
    case 'u-a-hs-ml'
        input_params_filename = 'travelling-reflected-wave_unstructured-amplitude-hs-meshless_input.json';
end


input_params_dir  = 'examples/configs';
json_mode = 'read';

%% Load configuration file with options
input_params = read_write_json(input_params_filename, input_params_dir, json_mode);

%% Check that the input tmp folder and output folder exist and are consistent with OS,
% if they aren't, it will try to fix the problem, or error
input_params = check_storage_dirs(input_params, 'temp');
input_params = check_storage_dirs(input_params, 'output');

%% Run core functions: interpolation, estimation and classification, streamlines, this function writes to a new json file
output_params = main_core(input_params); 

%% Run basic analysis
main_analysis(output_params);

%% Visualisation
switch case_label
    case 'u-a-hs-mb'
        output_params_filename = 'travelling-reflected-wave_unstructured-amplitude-hs-meshbased_output.json';
    case 'u-a-hs-ml'
        output_params_filename = 'travelling-reflected-wave_unstructured-amplitude-hs-meshless_output.json';
end


% This is the json file that fmri_waves() generated. 
params_filename  = output_params_filename;
params_dir = 'examples/configs';
json_mode = 'read';

% Load options
ouparams = read_write_json(params_filename, params_dir, json_mode);
plot2d_svd_modes(ouparams);
plotmov_streamparticles(ouparams, 'particles',  2);
plotmov_flows(ouparams);

end %function travelling_reflected_wave()
function sink_source_wave(case_label)
% This function runs the whole neural-flows workflow on a small epoch of simulated 
% data, that corresponds to a brain wave pattern which has sinks and sources.
% NOTE: Assumes this function is run from the top level directory neural-flows/

% CASE_LABEL MEANING: 
% |  Input Dataset Type    | Input Data Modality   | Flow Estimation Method | Flow Estimation Type   |  
% |-----------------------|-----------------------|------------------------|-------------------------| 
% |  (u)nstructured       | (a)mplitude           |   (h)orn-(s)chunk3d    |     (m)esh-(b)ased
% |  (s)tructured         | (p)hase               |   (p)hase-(g)radient   |     (m)esh(l)ess

% Available case_label combinations:
% Case A: u-a-hs-mb
% Case B: u-a-hs-ml
% Case C: u-p-pg-ml

% PERFORMANCE:
% |    Host   |  # workers  |  Runtime |  Memory |
% |-----------|-------------|----------|---------|
% | tesseract |     6       |  3.73 min| XX  GB  |  

if nargin < 1
    case_label = 'u-a-hs-mb'; 
end

switch case_label
    case 'u-a-hs-mb'
        input_params_filename = 'sink-source-wave_unstructured-amplitude-hs-meshbased_input.json';
    case 'u-a-hs-ml'
        input_params_filename = 'sink-source-wave_unstructured-amplitude-hs-meshless_input.json';
    case 'u-p-pg-ml'
        input_params_filename = 'sink-source-wave_unstructured-phase-pg-meshless_input.json';
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
main_visualisation(output_params);

end %function sink_source_wave()
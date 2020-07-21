function rotating_wave(case_label)
% This script runs the whole neural-flows workflow on a small epoch of simulated 
% data, that mostly corresponds to rotating wave.
% 
% NOTE: Assumes this function is run from the top level directory neural-flows/

% PERFORMANCE:
% |    Host   | Data Domain    | Data Mode   | Flow Method     | # workers  |  Runtime |  Memory |
% |-----------|----------------|-------------|-----------------|------------|----------|---------|
% | dracarys  | (u)nstructured | (a)mplitude | (h)orn-schunk3d |      11    |  5  min  |   6 GB  |
% | dracarys  | (u)nstructured | (a)mplitude | (c)nem          |      8     |  X       |    X    | 
% | tesseract | (u)nstructured | (a)mplitude | (h)orn-schunk3d |      6     |  3.73 min| 2.5 GB  |  
% | tesseract | (u)nstructured | (a)mplitude | (c)nem          |      8     |  0.75 min| 500 MB  |
% | tesseract | (u)nstructured | (p)hase     | (c)nem          |      8     |  0.75 min| 500 MB  |

if nargin < 1
    case_label = 'uah';
end

switch case_label
    case 'uah'
        input_params_filename = 'rotating_wave_uah_in.json';
    case 'uac'
        input_params_filename = 'rotating_wave_uac_in.json';
    case 'upc'
        input_params_filename = 'rotating_wave_upc_in.json';
end


input_params_dir  = 'examples';
json_mode = 'read';

%% Load configuration file with options
input_params = read_write_json(input_params_filename, input_params_dir, json_mode);

%% Check that the input tmp folder and output folder exist and are consistent with OS,
% if they aren't, it will try to fix the problem, or error
input_params = check_storage_dirs(read_write_json(input_params_filename, input_params_dir, json_mode));

%% Run core functions: interpolation, estimation and classification, streamlines, this function writes to a new json file
output_params = main_core(input_params); 

%% Run basic analysis
main_analysis(output_params);

%% Visualisation
main_visualisation(output_params);

end %function example_rotating_wave()
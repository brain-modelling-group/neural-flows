function rotating_wave(case_label)
% This script runs the whole neural-flows workflow on a small epoch of simulated 
% data, that mostly corresponds to rotating wave.
% 
% NOTE: Assumes this function is run from the top level directory neural-flows/

% PERFORMANCE:
% |    Host   | Data Domain    | Data Mode   | Flow Method     | # workers  |  Runtime |  Memory |
% |-----------|----------------|-------------|-----------------|------------|----------|---------|
% | dracarys  | (u)nstructured | (a)mplitude | (h)orn-schunk3d |      11    |  5  min  |   6 GB  |
% | dracarys  | (u)nstructured | (a)mplitude | (c)nem|         |      8     |  X       |    X    | 
% | tesseract | (u)nstructured | (a)mplitude | (h)orn-schunk3d |      6     |  3.73 min|    X    |  
% | tesseract | (u)nstructured | (a)mplitude | (c)nem|         |      8     |  0.75 min|    X    |
% | tesseract | (u)nstructured | (p)hase     | (c)nem|         |      8     |  0.75 min|    X    |

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

% Load options
input_params = read_write_json(input_params_filename, input_params_dir, json_mode);
%% Run core functions: interpolation, estimation and classification, this function writes to a new json file
output_params = main(input_params); 

%% Run svd analysis
perform_svd_mode_decomposition(output_params);

%% 
if strcmp(case_label, 'uah')
   plot1d_singularity_traces(output_params)
end
plot1d_speed_distribution(output_params)


end %function example_rotating_wave()
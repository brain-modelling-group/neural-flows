function run_times = test_performance_rotating_wave(num_iterations)
% This script runs the core stages on a small epoch of simulated data 

if nargin < 1
    num_iterations = 8;
end

input_params_filename = 'rotating_wave_uah_in.json';
input_params_dir  = 'examples/configs';
json_mode = 'read';

%% Load configuration file with options
input_params = read_write_json(input_params_filename, input_params_dir, json_mode);

%% Check that the input tmp folder and output folder exist and are consistent with OS,
% if they aren't, it will try to fix the problem, or error
input_params = check_storage_dirs(input_params, 'temp');
input_params = check_storage_dirs(input_params, 'output');

%% Run core functions: interpolation, estimation and classification, streamlines, this function writes to a new json file
run_times = zeros(num_iterations, 1);
for this_iteration = 1:num_iterations
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: START RUN.'))              
    tstart = tik();
    main_core(input_params);
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: END RUN.'))              
    run_times(this_iteration) = tok(tstart, 'minutes');
end
end %test_performance_rotating_wave()
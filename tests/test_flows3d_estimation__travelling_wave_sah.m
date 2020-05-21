function test_flows3d_estimation__travelling_wave_sah()
% Estimate amplitude-based flows of a travelling wave using Horn-Schunk 3D algorithm.
% The wave is defined on an structured domain (ie, regular grid).
% This is a wave moving at 4 m/s in the y-direction, and then travelling
% back in the same direction but opposite orientation (- 4 m/s)
% NOTE: Assumes this function is called from tests/ directory 

input_params = read_write_json('test-flows3d-estimation_travelling-wave_sah_in.json', 'json/', 'read');

output_params = main(input_params); 

[obj_flows] = load_iomat_flows(output_params);

% Plot stuff
fig_hist = figure('Name', mfilename);

plot_debug_flow_histogram(fig_hist, obj_flows, output_params)
 
end % function test_flows3d_estimation__travelling_wave_sah()

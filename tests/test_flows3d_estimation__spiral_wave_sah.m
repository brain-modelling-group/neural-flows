function test_flows3d_estimation__spiral_wave_sah()
% Estimate amplitude-based flows of a spiral wave using Horn-Schunk 3D algorithm.

% NOTE: Assumes this function is called from tests/ directory 

input_params = read_write_json('test-flows3d-estimation_spiral-wave_sah_in.json', 'json/', 'read');

output_params = main(input_params); 

[obj_flows] = load_iomat_flows(output_params);

% Plot stuff
fig_hist = figure('Name', mfilename);

plot_debug_flow_histogram(fig_hist, obj_flows, output_params)
 
end % function test_flows3d_estimation__spiral_wave_sah

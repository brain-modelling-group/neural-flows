function test_flows3d_estimation__plane_wave_uac()
% Estimate amplitude-based flows of a plane wave using CNEM library.
% The wave is defined on an unstructured domain (ie, scattered points).
% This is a plane wave moving at 2 m/s in the y-direction
% NOTE: Assumes this function is called from tests/ directory 

input_params = read_write_json('test-flows3d-estimation_plane-wave_uac_in.json', 'json/', 'read');

output_params = main(input_params); 

[obj_flows] = load_iomat_flows(output_params);

% Plot stuff
fig_hist = figure('Name', mfilename);

plot_debug_flow_histogram(fig_hist, obj_flows, output_params)
   
end % test_flows3d_estimation__plane_wave_uac()

function test_flows3d_estimation__travelling_wave_upc()
%% Estimate phase-based flows of a travelling wave using CNEM library, 
% and Roberts et al. 2019 method. 
% The wave is defined on an unstructured domain (ie, scattered points).
% This is a wave moving at 4 m/s in the y-direction, and then travelling
% back in the same direction but opposite orientation (- 4 m/s)
% NOTE: Assumes this function is called from tests/ directory 

% |     | Data Domain    | Data Mode   | Flow Method     |
% |-----|----------------|-------------|-----------------|
% | upc | (u)nstructured | (p)hase     | (c)nem          |

input_params = read_write_json('test-flows3d-estimation_travelling-wave_upc_in.json', 'json/', 'read');

output_params = main(input_params); 

[obj_flows] = load_iomat_flows(output_params);

% Plot stuff
fig_hist = figure('Name', mfilename);

plot_debug_flow_histogram(fig_hist, obj_flows, output_params)
 
end % function test_flows3d_estimation__travelling_wave_upc()
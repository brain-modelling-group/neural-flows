function test_flows3d_estimation__travelling_biharmonic_wave_sah()
% This is a travelling biharmonic wave (ie, composed of two sine waves 
% at slightly different frequencies). The group velocity and phase velocity have opposite 
% orientation.

% NOTE: Assumes this function is called from tests/ directory 

% |     | Data Domain    | Data Mode   | Flow Method     |
% |-----|----------------|-------------|-----------------|
% | sah | (s)tructured   | (a)mplitude | (h)orn-schunk3d |

input_params = read_write_json('test-flows3d-estimation_biharmonic-wave_sah_in.json', 'json/', 'read');

output_params = main(input_params); 

[obj_flows] = load_iomat_flows(output_params);

% Plot stuff
fig_hist = figure('Name', mfilename);

plot_debug_flow_histogram(fig_hist, obj_flows, output_params)

end % function test_flows3d_estimation__travelling_biharmonic_wave_sah()

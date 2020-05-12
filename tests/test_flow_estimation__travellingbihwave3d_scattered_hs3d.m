function test_flow_estimation__travellingbihwave3d_scattered_hs3d()
% NOTE: Takes about 110 seconds @ dracarys
% Generate data with these step sizes
 options.hx = 0.004;
 options.hy = 0.004;
 options.hz = 0.004;
 options.grid.lim_type = 'none'; % do not use ceil to calculate the grid.
 options.ht = 0.025;

 % With these parameters the wave is moving at 4 m/s along the y-axis 
 load('513COG.mat', 'COG')
 locs = COG(1:256, :)/1000;
 
 [data, ~] = generate_wave3d_travelling_biharmonic_scattered(locs, 'hxyz', options.hx, ...
                                                                   'ht',   options.ht, ...
                                                                   'lim_type', options.grid.lim_type);

 full_path_to_file = mfilename('fullpath');
 save([full_path_to_file '.mat'], 'data', 'locs');
 
 input_params_filename = 'test-flow-travellingbiwave3d-scattered-in.json';
 input_params_dir  = '/home/paula/Work/Code/matlab-neuro/neural-flows/tests';
 json_mode = 'read';

 input_params = read_write_json(input_params_filename, input_params_dir, json_mode);
 output_params = main(input_params);

 [obj_flows] = load_iomat_flows(output_params);

 fig_hist = figure('Name', 'nflows-test-planewave3d-scatter-hs3d');
 
 subplot(1, 4, 1, 'Parent', fig_hist)
 histogram(squeeze(obj_flows.uxyz(:, 1, :)))
 xlabel('ux [m/s]')
 
 subplot(1, 4 ,2, 'Parent', fig_hist)
 histogram(squeeze(obj_flows.uxyz(:, 2, :)))
 xlabel('uy [m/s]')
 
 subplot(1, 4, 3, 'Parent', fig_hist)
 histogram(squeeze(obj_flows.uxyz(:, 3, :)))
 xlabel('uz [m/s]')
 
 subplot(1, 4, 4, 'Parent', fig_hist)
 histogram(squeeze(sqrt(obj_flows.uxyz(:, 1, :).^2 + obj_flows.uxyz(:, 2, :).^2 + obj_flows.uxyz(:, 3, :).^2)))
 xlabel('u_{norm} [m/s]')
 

end % function test_flow_estimation__travellingbihwave3d_scattered_hs3d()

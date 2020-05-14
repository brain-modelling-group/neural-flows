function test_flows3d_estimation__travelling_wave_uah()
% NOTE: Takes about 110 seconds @dracarys
%       Takes about 129 seconds @tesseract

% Generate data with these step sizes
 options.hx = 2;
 options.hy = 2;
 options.hz = 2;
 options.ht = 0.5;

 % With these parameters the wave is moving at 4 m/s along the y-axis 
 load('513COG.mat', 'COG')
 locs = COG(1:256, :);
 
 [data, ~] = generate_data3d_travelling_wave('locs', locs, 'hxyz',  options.hx, ...
                                             'ht', options.ht, 'direction', 'y', ...
                                             'grid_type', 'unstructured');
 
 %Option to generate a travelling wave moving back and forth along the
 %chose axis
 data = [data(end:-1:1, :); data];
 full_path_to_file = mfilename('fullpath');
 save([full_path_to_file '.mat'], 'data', 'locs');
 
 input_params_filename = 'test-flow-travellingwave3d-scattered-in.json';
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
end % function test_flow_estimation__travellingwave3d_scattered_hs3d()

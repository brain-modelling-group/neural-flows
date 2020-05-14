function test_flows3d_estimation__plane_wave_uah()
% NOTE: Takes about XXX seconds @tesseract 

 % Generate data
 hxyz = 2;
 ht = 1;
 
 load('513COG.mat', 'COG')
 locs = COG(1:256, :);
 
 tstart = tik();
 [data, ~] = generate_data3d_plane_wave('hxyz', hxyz, 'ht', ht, ...
                                        'direction', 'x', ...
                                        'locs', locs, ...
                                        'grid_type', 'unstructured');
                                               
 tok(tstart);
 
 full_path_to_file = mfilename('fullpath');
 save([full_path_to_file '.mat'], 'data', 'locs');
 
 input_params_filename = 'test-flow-planewave3d-scattered-in.json';
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
   
end % test_flow_estimation__planewave3d_scattered_hs3d()

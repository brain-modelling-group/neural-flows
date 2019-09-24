function test_flow_estimation__spiralwave3d_scattered_hs3d()
% NOTE: Takes about 300 seconds @dracarys -- includes interpolation of
% data.
% Generate data
 options.hx = 1;
 options.hy = 1;
 options.hz = 1;
 options.ht = 1;
 
 % With these parameters the wave is moving at 4 m/s along the y-axis
 
 load('513COG.mat', 'COG')
 locs = COG(1:256, :);
 
 
 [wave3d, ~] = generate_spiralwave3d_scattered(locs, 'hxyz',  options.hx, 'ht', options.ht);
 
 % Options
 options.data_interpolation.file_exists = false;
 options.flow_calculation.init_conditions = 'random';
 options.flow_calculation.seed_init_vel = 42;
 options.flow_calculation.alpha_smooth   = 0.1;
 options.flow_calculation.max_iterations = 128;
 options.sing_detection = false;

 mfile_flows = main_neural_flows_hs3d_scatter(wave3d, locs, options);

 fig_hist = figure('Name', 'nflows-test-spiralwave3d-scatter-hs3d');

 subplot(1, 3, 1, 'Parent', fig_hist)
 histogram(mfile_flows.ux(2:end-1, 2:end-1, 2:end-1, :))
 xlabel('ux')
 
 subplot(1, 3 ,2, 'Parent', fig_hist)
 histogram(mfile_flows.uy(2:end-1, 2:end-1, 2:end-1, :))
 xlabel('uy')
 
 subplot(1, 3, 3, 'Parent', fig_hist)
 histogram(mfile_flows.uz(2:end-1, 2:end-1, 2:end-1, :))
 xlabel('uz')

 
end % function test_flow_estimation__spiralwave3d_grid_hs3d()

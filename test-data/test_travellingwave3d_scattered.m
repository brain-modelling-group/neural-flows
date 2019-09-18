function test_travellingwave3d_scattered()

% Generate data
 options.hx = 2;
 options.hy = 2;
 options.hz = 2;
 options.ht = 0.5;
 % With these parameters the wave is moving at 4 m/s along the x-axis
 
 load('513COG.mat', 'COG')
 locs = COG(1:256, :);
 
 options.data_interpolation.file_exists = false;
 
 [wave3d, time] = generate_travellingwave3d_scattered(locs, 'hxyz',  options.hx, 'ht', options.ht);
 
 
 options.flow_calculation.init_conditions = 'random';
 options.flow_calculation.seed_init_vel = 42;
 options.flow_calculation.alpha_smooth   = 0.1;
 options.flow_calculation.max_iterations = 128;
 
 
 mfile_flows = main_neural_flows_hs3d_scatter(wave3d, locs, options);

 fig_hist = figure('Name', 'nflows-test-histograms-random-ic');

 subplot(1, 3, 1, 'Parent', fig_hist)
 histogram(mfile_flows.ux(:))
 
 subplot(1, 3 ,2, 'Parent', fig_hist)
 histogram(mfile_flows.uy(:))
 
 subplot(1, 3, 3, 'Parent', fig_hist)
 histogram(mfile_flows.uz(:))
 
 
end % function test_travellingwave3d_scattered()
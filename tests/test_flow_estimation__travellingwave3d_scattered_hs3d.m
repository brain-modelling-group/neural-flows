function test_flow_estimation__travellingwave3d_scattered_hs3d()
% NOTE: Takes about 110 seconds @ dracarys
% Generate data with these step sizes
 options.hx = 2;
 options.hy = 2;
 options.hz = 2;
 options.ht = 0.5;
 % With these parameters the wave is moving at 4 m/s along the y-axis
 
 load('513COG.mat', 'COG')
 locs = COG(1:256, :);
 
 
 [wave3d, ~] = generate_wave3d_travelling_scattered(locs, 'hxyz',  options.hx, 'ht', options.ht, 'direction', 'y');
 
 %Option to generate a travelling wave moving back and forth along the
 %chose axis
 %wave3d = [wave3d(end:-1:1, :); wave3d];
 
 options.data_interpolation.file_exists = false;
 options.flow_calculation.init_conditions = 'preset';
 options.flow_calculation.seed_init_vel = 42;
 options.flow_calculation.alpha_smooth   = 0.1;
 options.flow_calculation.max_iterations = 128;
 options.sing_analysis.detection = false;
 
 options.flow_calculation.uxo = zeros([87, 34, 62]);
 options.flow_calculation.uyo = -4.*ones([87, 34, 62]);
 options.flow_calculation.uzo = zeros([87, 34, 62]);

 % Do the stuff
 [~, mfile_flows] = main_neural_flows_hs3d_scatter(wave3d, locs, options);

 % Plot the velocity estimates
 fig_hist = figure('Name', 'nflows-test-travellingwave3d-scattered-hs3d');

 subplot(1, 4, 1, 'Parent', fig_hist)
 histogram(mfile_flows.ux)
 xlabel('ux [m/s]')
 
 subplot(1, 4 ,2, 'Parent', fig_hist)
 histogram(mfile_flows.uy)
 xlabel('uy [m/s]')

 subplot(1, 4, 3, 'Parent', fig_hist)
 histogram(mfile_flows.uz)
 xlabel('uz [m/s]')
 
 subplot(1, 4, 4, 'Parent', fig_hist)
 histogram(sqrt(mfile_flows.ux(2:end-1, 2:end-1, 2:end-1, :).^2 + ...
                mfile_flows.uy(2:end-1, 2:end-1, 2:end-1, :).^2 + ...
                mfile_flows.uz(2:end-1, 2:end-1, 2:end-1, :).^2))
 xlabel('u_{norm} [m/s]')
 
end % function test_flow_estimation__travellingwave3d_scattered_hs3d()

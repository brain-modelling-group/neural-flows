function test_flow_estimation__spiralwave3d_scattered_cnem()
% NOTE: Takes about 152 seconds @dracarys -- cnem is a c++ multithreaded
% library.

% Generate data
 options.hx = 1;
 options.hy = 1;
 options.hz = 1;
 options.ht = 1;
 options.alpha_radius = 30;
 options.is_phase = false;
 
 % With these parameters the wave is moving at 4 m/s along the y-axis
 
 load('513COG.mat', 'COG')
 locs = COG(1:256, :);
 
 
 [wave3d, ~] = generate_wave3dspiral_scattered(locs, 'hxyz',  options.hx, 'ht', options.ht);
 
 if options.is_phase
     % Transform data into phase via hilber transform
     wave3d = calculate_insta_phase(wave3d);
     fig_name = 'nflows-test-spiralwave3d-scattered-cnem-phase';
 else
     fig_name = 'nflows-test-spiralwave3d-scattered-cnem-activity';
 end
 
 v = flows3d_estimate_cnem_flow(wave3d, locs, options.ht, options);
 
 fig_hist = figure('Name', fig_name);

 subplot(1, 3, 1, 'Parent', fig_hist)
 histogram(v.vxp(:))
 xlabel('ux')
 
 subplot(1, 3 ,2, 'Parent', fig_hist)
 histogram(v.vyp(:))
 xlabel('uy')

 subplot(1, 3, 3, 'Parent', fig_hist)
 histogram(v.vzp(:))
 xlabel('uz')

 
end % function test_flow_estimation__spiralwave3d_grid_hs3d()

function test_flow_estimation__travellingwave3d_scattered_cnem()

 %Generate data
 options.hx = 2;
 options.hy = 2;
 options.hz = 2;
 options.ht = 0.5;
 % With these parameters the wave is moving at 2 m/s along the x-axis
 
 % Load centres of gravity
 load('513COG.mat', 'COG')
 locs = COG(1:256, :);
 locs = [locs; COG(513, :)]; % amygdala on that side.

 % Generate fake data
 [wave3d, ~] = generate_travellingwave3d_scattered(locs, 'hxyz',  options.hx, 'ht', options.ht);
 
 % Transform data into phase via hilber transform
 wave3d_phi = calculate_insta_phase(wave3d);
 
 v = flows3d_estimate_cnem_flow(wave3d_phi, locs, options.ht);
 
 
 fig_hist = figure('Name', 'nflows-test-travellingwave3d-scattered-cnem');

 subplot(1, 3, 1, 'Parent', fig_hist)
 histogram(v.vxp(:, 1:50))
 xlabel('ux')
 
 subplot(1, 3 ,2, 'Parent', fig_hist)
 histogram(v.vyp(:, 1:50))
 xlabel('uy')

 subplot(1, 3, 3, 'Parent', fig_hist)
 histogram(v.vzp(:, 1:50))
 xlabel('uz')
 
end % function test_travellingwave3d_scattered()
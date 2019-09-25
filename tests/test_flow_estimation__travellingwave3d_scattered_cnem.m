function test_flow_estimation__travellingwave3d_scattered_cnem()
%NOTE: takes about 51 seconds @dracarys
 %Generate data
 options.hx = 2;
 options.hy = 2;
 options.hz = 2;
 options.ht = 0.5;
 options.alpha_radius = 30;
 options.is_phase = true;
 % With these parameters the wave is moving at 2 m/s along the x-axis
 
 % Load centres of gravity
 load('513COG.mat', 'COG')
 locs = COG(1:256, :);
 locs = [locs; COG(513, :)]; % amygdala on that side.

 % Generate fake data
 [wave3d, ~] = generate_wave3dtravelling_scattered(locs, 'hxyz',  options.hx, 'ht', options.ht, 'direction', 'y');
 
 if options.is_phase
     % Transform data into phase via hilber transform
     wave3d = calculate_insta_phase(wave3d);
     fig_name = 'nflows-test-travellingwave3d-scattered-cnem-phase';
 else
     fig_name = 'nflows-test-travellingwave3d-scattered-cnem-activity';
 end
 
 v = flows3d_estimate_cnem_flow(wave3d, locs, options.ht);
 
 fig_hist = figure('Name', fig_name);

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
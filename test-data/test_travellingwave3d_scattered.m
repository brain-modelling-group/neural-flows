function test_travellingwave3d_scattered()

% Generate data
 options.hx = 1;
 options.hy = 1;
 options.hz = 1;
 options.ht = 1;
 
 load('513COG.mat', 'COG')
 locs = COG(1:256, :);
 [wave3d, time] = generate_travellingwave3d_scattered(locs, 'hxyz',  options.hx, 'ht', options.ht);
 
 plot_sphereanim(wave3d, locs, time);
 
 %options.flow_calculation.init_conditions = 'random';
 %options.flow_calculation.seed_init_vel = 42;
 %options.flow_calculation.alpha_smooth   = 0.1;
 %options.flow_calculation.max_iterations = 128;


 
 
 
end % function test_travellingwave3d_scattered()
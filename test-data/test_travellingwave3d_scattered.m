function test_travellingwave3d_scattered()

% Generate data
 options.hx = 2;
 options.hy = 2;
 options.hz = 2;
 options.ht = 0.5;
 % With these parameters the wave is moving at 4 m/s along the x-axis
 
 load('513COG.mat', 'COG')
 locs = COG(1:256, :);
 [wave3d, time] = generate_travellingwave3d_scattered(locs, 'hxyz',  options.hx, 'ht', options.ht);
 
 plot_sphereanim(wave3d, locs, time);
 
 %options.flow_calculation.init_conditions = 'random';
 %options.flow_calculation.seed_init_vel = 42;
 %options.flow_calculation.alpha_smooth   = 0.1;
 %options.flow_calculation.max_iterations = 128;


 
 
 
end % function test_travellingwave3d_scattered()
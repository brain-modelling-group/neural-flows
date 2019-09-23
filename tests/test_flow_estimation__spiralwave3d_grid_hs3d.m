function test_flow_estimation__spiralwave3d_grid_hs3d()

% Generate data
 options.hx = 1;
 options.hy = 1;
 options.hz = 1;
 options.ht = 1;
 [wave3d, X, Y, Z, ~] = generate_spiralwave3d_grid('visual_debugging', true, ...
                                                   'hxyz', options.hx, 'ht', options.ht, ...
                                                   'velocity', [0 0], 'filament', 'helix');
 
 options.flow_calculation.init_conditions = 'random';
 options.flow_calculation.seed_init_vel = 42;
 options.flow_calculation.alpha_smooth   = 0.1;
 options.flow_calculation.max_iterations = 128;

 mfile_flows = main_neural_flows_hs3d_grid(wave3d, X, Y, Z, options);

 fig_hist = figure('Name', 'nflows-test-travellingwave3d-grid-hs3d');

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

function test_flow_estimation__planewave3d_grid_hs3d()

% Generate data
 options.hx = 1;
 options.hy = 1;
 options.hz = 1;
 options.ht = 1;
 [wave3d, X, Y, Z, ~] = generate_wave3d_plane_grid('visual_debugging', false, 'hxyz', options.hx, 'ht', options.ht, 'direction', 'x');
 
 options.flow_calculation.init_conditions = 'random';
 options.flow_calculation.seed_init_vel = 42;
 options.flow_calculation.alpha_smooth   = 0.1;
 options.flow_calculation.max_iterations = 128;

 mfile_flows = main_neural_flows_hs3d_grid(wave3d, X, Y, Z, options);

 fig_hist = figure('Name', 'nflows-test-planewave3d-grid-hs3d');

 subplot(1, 4, 1, 'Parent', fig_hist)
 histogram(mfile_flows.ux(2:end-1, 2:end-1, 2:end-1, :))
 xlabel('ux [m/s]')
 
 subplot(1, 4, 2, 'Parent', fig_hist)
 histogram(mfile_flows.uy(2:end-1, 2:end-1, 2:end-1, :))
 xlabel('uy [m/s]')
 
 subplot(1, 4, 3, 'Parent', fig_hist)
 histogram(mfile_flows.uz(2:end-1, 2:end-1, 2:end-1, :))
 xlabel('uz [m/s]')
 
  
 subplot(1, 4, 4, 'Parent', fig_hist)
 histogram(sqrt(v.vxp(:).^2+v.vyp(:).^2+v.vzp(:).^2))
 xlabel('u_{norm} [m/s]')


 
end % function test_flow_estimation__planewave3d_grid_hs3d()
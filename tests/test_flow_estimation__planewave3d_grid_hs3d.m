function test_flow_estimation__planewave3d_grid_hs3d()

% Generate data
 options.interpolation.hx = 1;
 options.interpolation.hy = 1;
 options.interpolation.hz = 1;
 options.data.ht = 1;
 [wave3d, X, Y, Z, ~] = generate_wave3d_plane_grid('visual_debugging', false, ...
                                                   'hxyz', options.interpolation.hx, 'ht', options.data.ht, ...
                                                   'direction', 'x');
 
 options.flows.init_conditions.mode = 'random';
 options.flows.init_conditions.seed = 42;
 options.flows.method.alpha_smooth   = 0.1;
 options.flows.method.max_iterations = 128;

 mfile_flows = main_neural_flows_hs3d_grid(wave3d, Y, X, Z, options);

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
 
 %subplot(1, 4, 4, 'Parent', fig_hist)
 %histogram(sqrt(v.vxp(:).^2+v.vyp(:).^2+v.vzp(:).^2))
 %xlabel('u_{norm} [m/s]')
 
end % function test_flow_estimation__planewave3d_grid_hs3d()

function test_flows3d_estimation__plane_wave_upc()
% NOTE: Takes about XX seconds @dracarys -- cnem is a c++ multithreaded
% library.

% Generate data
 options.hx = 4;
 options.hy = 4;
 options.hz = 4;
 options.ht = 4;
 options.alpha_radius = 30;
 options.is_phase = true;
 
 
 load('513COG.mat', 'COG')
 locs = COG(1:256, :);
 
 
 [data, ~] = generate_data3d_plane_wave(locs, 'hxyz',  options.hx, 'ht', options.ht, ...
                                              'direction', 'z', ...
                                              'grid_type', 'unstructured');
 
 if options.is_phase
     % Transform data into instantanous phase via hilbert transform
     data = calculate_insta_phase(data);
     fig_name = 'nflows-test-planewave3d-unstructured-phase-cnem-upc';
 else
     fig_name = 'nflows-test-planewave3d-unstructured-activity-cnem-uac';
 end
 
 u = flows3d_estimate_cnem_flow(data, locs, options.ht, options);
 
 fig_hist = figure('Name', fig_name);

 subplot(1, 4, 1, 'Parent', fig_hist)
 histogram(u.vxp(:))
 xlabel('ux [mm/ms]')   
 
 subplot(1, 4 ,2, 'Parent', fig_hist)
 histogram(u.vyp(:))
 xlabel('uy [mm/ms]')

 subplot(1, 4, 3, 'Parent', fig_hist)
 histogram(u.vzp(:))
 xlabel('uz [mm/ms]')
 
 
 subplot(1, 4, 4, 'Parent', fig_hist)
 histogram(sqrt(u.vxp(:).^2+u.vyp(:).^2+u.vzp(:).^2))
 xlabel('u_{norm} [mm/ms]')

end % function test_flow_estimation__planewave3d_scattered_cnem()

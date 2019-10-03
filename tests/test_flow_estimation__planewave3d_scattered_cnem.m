function test_flow_estimation__planewave3d_scattered_cnem()
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
 
 
 [wave3d, ~] = generate_wave3d_plane_scattered(locs, 'hxyz',  options.hx, 'ht', options.ht, 'direction', 'z');
 
 if options.is_phase
     % Transform data into phase via hilbert transform
     wave3d = calculate_insta_phase(wave3d);
     fig_name = 'nflows-test-planewave3d-scattered-cnem-phase';
 else
     fig_name = 'nflows-test-planewave3d-scattered-cnem-activity';
 end
 
 v = flows3d_estimate_cnem_flow(wave3d, locs, options.ht, options);
 
 fig_hist = figure('Name', fig_name);

 subplot(1, 4, 1, 'Parent', fig_hist)
 histogram(v.vxp(:))
 xlabel('ux [mm/ms]')   
 
 subplot(1, 4 ,2, 'Parent', fig_hist)
 histogram(v.vyp(:))
 xlabel('uy [mm/ms]')

 subplot(1, 4, 3, 'Parent', fig_hist)
 histogram(v.vzp(:))
 xlabel('uz [mm/ms]')
 
 
 subplot(1, 4, 4, 'Parent', fig_hist)
 histogram(sqrt(v.vxp(:).^2+v.vyp(:).^2+v.vzp(:).^2))
 xlabel('u_{norm} [mm/ms]')

end % function test_flow_estimation__planewave3d_scattered_cnem()

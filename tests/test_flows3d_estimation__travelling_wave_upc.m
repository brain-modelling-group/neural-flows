function test_flows3d_estimation__travelling_wave_upc()
% grid-input-method
% u: unstructured
% p: phase-based
% c: cnem
% s: structured (grid)
% a: activity-based (input data)
% h: hornschunk (method)

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
 [data, ~] = generate_data3d_travelling_wave('locs', locs, 'hxyz',  options.hx, 'ht', options.ht, 'direction', 'y');
 
 % Transform data into phase via hilber transform
 data = calculate_insta_phase(data);
 fig_name = 'nflows-test-travellingwave3d-unstructured-phase-cnem';
  
 u = flows3d_estimate_cnem_flow(data, locs, options.ht);
 
 fig_hist = figure('Name', fig_name);

 subplot(1, 4, 1, 'Parent', fig_hist)
 histogram(u.vxp(:, 1:50))
 xlabel('ux [m/s]')
 
 subplot(1, 4 ,2, 'Parent', fig_hist)
 histogram(u.vyp(:, 1:50))
 xlabel('uy [m/s]')

 subplot(1, 4, 3, 'Parent', fig_hist)
 histogram(u.vzp(:, 1:50))
 xlabel('uz [m/s]')
 
 subplot(1, 4, 4, 'Parent', fig_hist)
 histogram(sqrt(u.vxp(:).^2+u.vyp(:).^2+u.vzp(:).^2))
 xlabel('u_{norm} [mm/ms]')
 
end % function test_flow_estimation__travellingwave3d_scattered_cnem()
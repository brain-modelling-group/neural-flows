function test_flow_estimation__travellingbihwave3d_scattered_hs3d()
% NOTE: Takes about 110 seconds @ dracarys
% Generate data with these step sizes
 options.interpolation.hx = 0.004;
 options.interpolation.hy = 0.004;
 options.interpolation.hz = 0.004;
 options.interpolation.grid.lim_type = 'none'; % do not use ceil to calculate the grid.
 options.data.ht = 0.025;
 options.data.slice.id = 0;

 % With these parameters the wave is moving at 4 m/s along the y-axis 
 load('513COG.mat', 'COG')
 locs = COG(1:256, :)/1000;
 
 [wave3d, ~] = generate_wave3d_travelling_biharmonic_scattered(locs, 'hxyz',  options.interpolation.hx, ...
                                                                     'ht', options.data.ht, ...
                                                                     'lim_type', options.interpolation.grid.lim_type);

 options.interpolation.file.exists = false;
 options.interpolation.file.keep = true;
 options.interpolation.boundary.alpha_radius = 30;
 options.interpolation.boundary.thickness = 2;
 
 % Flow calculation
 options.flows.file.keep = true;
 options.flows.init_conditions.mode = 'random';
 options.flows.init_conditions.seed = 42;
 options.flows.method.name = 'hs3d';
 options.flows.method.alpha_smooth   = 1;
 options.flows.method.max_iterations = 128;
 
  % Singularity detection and classification
 options.singularity.file.keep = false;
 options.singularity.detection.enabled = false;    
 
 
 wave3d_env = abs(hilbert(wave3d));

 
 % Do the stuff
 [~, mfile_flows] = main_neural_flows_hs3d_scatter(wave3d, locs, options);
 [~, mfile_flows_env] = main_neural_flows_hs3d_scatter(wave3d_env, locs, options);


 % Plot the velocity estimates
 fig_hist = figure('Name', 'nflows-test-travellingwave3d-scattered-hs3d');

 subplot(1, 4, 1, 'Parent', fig_hist)
 histogram(mfile_flows.ux)
 xlabel('ux [m/s]')
 
 subplot(1, 4 ,2, 'Parent', fig_hist)
 histogram(mfile_flows.uy)
 xlabel('uy [m/s]')

 subplot(1, 4, 3, 'Parent', fig_hist)
 histogram(mfile_flows.uz)
 xlabel('uz [m/s]')
 
 subplot(1, 4, 4, 'Parent', fig_hist)
 histogram(sqrt(mfile_flows.uxyz_sc(:, 1, : ).^2 + ...
                mfile_flows.uxyz_sc(:, 2, : ).^2 + ...
                mfile_flows.uxyz_sc(:, 3, : ).^2))
 xlabel('u_{norm} [m/s]')
 
 % SVD decompostion
data_type = 'grid';
perform_mode_decomposition_svd(mfile_flows, data_type);

perform_mode_decomposition_svd(mfile_flows_env, data_type);

end % function test_flow_estimation__travellingbihwave3d_scattered_hs3d()

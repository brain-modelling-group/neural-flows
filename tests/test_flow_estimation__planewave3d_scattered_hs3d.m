function test_flow_estimation__planewave3d_scattered_hs3d()
% NOTE: Takes about XXX seconds @dracarys -- includes interpolation of
% data.

% Generate data
 options.interpolation.hx = 2;
 options.interpolation.hy = 2;
 options.interpolation.hz = 2;
 options.data.ht = 2;
 
 
 load('513COG.mat', 'COG')
 locs = COG(1:256, :);
 
 
 [wave3d, ~] = generate_wave3d_plane_scattered(locs, 'hxyz', ...
                                               options.interpolation.hx, 'ht', options.data.ht, ...
                                               'direction', 'x');
 
 % Options
 options.interpolation.file.exists = false;
 options.interpolation.file.keep = false;
 options.interpolation.boundary.thickness = 3;
 options.data.slice.id = 0;
 options.interpolation.boundary.alpha_radius = 30;
 options.flows.file.keep = true;
 options.flows.init_conditions.mode = 'random';
 options.flows.init_conditions.seed = 42;
 options.flows.method.alpha_smooth   = 0.1;
 options.flows.method.max_iterations = 128;
 options.singularity.detection.enabled = false;

 mfile_flows = main_neural_flows_hs3d_scatter(wave3d, locs, options);

 fig_hist = figure('Name', 'nflows-test-planewave3d-scatter-hs3d');

 subplot(1, 4, 1, 'Parent', fig_hist)
 histogram(mfile_flows.ux(2:end-1, 2:end-1, 2:end-1, :))
 xlabel('ux [m/s]')
 
 subplot(1, 4 ,2, 'Parent', fig_hist)
 histogram(mfile_flows.uy(2:end-1, 2:end-1, 2:end-1, :))
 xlabel('uy [m/s]')
 
 subplot(1, 4, 3, 'Parent', fig_hist)
 histogram(mfile_flows.uz(2:end-1, 2:end-1, 2:end-1, :))
 xlabel('uz [m/s]')
 
 subplot(1, 4, 4, 'Parent', fig_hist)
 histogram(sqrt(mfile_flows.ux(2:end-1, 2:end-1, 2:end-1, :).^2 + ...
                mfile_flows.uy(2:end-1, 2:end-1, 2:end-1, :).^2 + ...
                mfile_flows.uz(2:end-1, 2:end-1, 2:end-1, :).^2))
 xlabel('u_{norm} [m/s]')
 
end % function test_flow_estimation__planewave3d_scattered_hs3d()

function test_flows3d_estimation__spiral_wave_uah()
% NOTE: Takes about 300 seconds @dracarys -- includes interpolation of
% data.
% Generate data
 options.hxyz = 2;
 options.ht = 1;
 
 % With these parameters the wave is moving at 4 m/s along the y-axis
 
 load('513COG.mat', 'COG')
 locs = COG;
 
 
 [data, ~] = generate_data3d_spiral_wave('locs', locs, ...
                                         'hxyz', options.hxyz, ...
                                         'ht', options.ht, ...
                                         'grid_type', 'unstructured');
 
%  % Options
%  options.data_interpolation.file_exists = false;
%  options.flow_calculation.init_conditions = 'random';
%  options.flow_calculation.seed_init_vel = 42;
%  options.flow_calculation.alpha_smooth   = 0.1;
%  options.flow_calculation.max_iterations = 128;
%  options.sing_analysis.detection = false;
% 
%  mfile_flows = main_neural_flows_hs3d_scatter(wave3d, locs, options);
% 
%  fig_hist = figure('Name', 'nflows-test-spiralwave3d-scatter-hs3d');
% 
%  subplot(1, 4, 1, 'Parent', fig_hist)
%  histogram(mfile_flows.ux(2:end-1, 2:end-1, 2:end-1, :))
%  xlabel('ux')
%  
%  subplot(1, 4 ,2, 'Parent', fig_hist)
%  histogram(mfile_flows.uy(2:end-1, 2:end-1, 2:end-1, :))
%  xlabel('uy')
%  
%  subplot(1, 4, 3, 'Parent', fig_hist)
%  histogram(mfile_flows.uz(2:end-1, 2:end-1, 2:end-1, :))
%  xlabel('uz')
%  
%  subplot(1, 4, 4, 'Parent', fig_hist)
%  histogram(sqrt(mfile_flows.ux(2:end-1, 2:end-1, 2:end-1, :).^2 + ...
%                 mfile_flows.uy(2:end-1, 2:end-1, 2:end-1, :).^2 + ...
%                 mfile_flows.uz(2:end-1, 2:end-1, 2:end-1, :).^2))
%  xlabel('u_{norm} [m/s]')
 
end % function test_flow_estimation__spiralwave3d_scattered_hs3d()

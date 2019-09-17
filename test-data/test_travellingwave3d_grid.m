function test_travellingwave3d_grid()

% Generate data
[wave3d, X, Y, Z, ~] = generate_travellingwave_3d_structured();

 options.hx = 1;
 options.hy = 1;
 options.hz = 1;
 options.ht = 1;
 options.flow_calculation.init_conditions = 'random';
 options.flow_calculation.seed_init_vel = 42;
 options.flow_calculation.alpha_smooth   = 0.1;
 options.flow_calculation.max_iterations = 64;

 mfile_flows = main_neural_flows_hs3d_grid(wave3d, X, Y, Z, options);

 fig_hist = figure('Name', 'nflows-test-histograms');

 subplot(1, 3, 1, 'Parent', fig_hist)
 histogram(mfile_flows.ux(2:19, 2:19, 2:19, :))
 
 subplot(1, 3 ,2, 'Parent', fig_hist)
 histogram(mfile_flows.uy(2:19, 2:19, 2:19, :))
 
 subplot(1, 3, 3, 'Parent', fig_hist)
 histogram(mfile_flows.uz(2:19, 2:19, 2:19, :))
 %%
 %for tt=1:22; pcolor3(squeeze(wave3d(tt, :, :, :))); caxis([-40 10]); pause(0.5); clf;end
 
 %%
 %for tt=1:21; clf; pcolor3(ux(:, :, :, tt)); caxis([0 3.5]);colorbar;pause(0.5);end
 
 
end % function test_travellingwave3d_grid()
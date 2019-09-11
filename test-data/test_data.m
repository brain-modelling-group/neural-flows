[wave3d, X, Y, Z, time] = generate_planewave_3d_structured('x');
%[wave3d, X, Y, Z, time] = generate_movingbar_3d_structured();
 
 options.chunk = 42;  
 options.hx = 1;
 options.hy = 1;
 options.hz = 1;
 options.ht = 1;
 options.flow_calculation.init_conditions = 'random';
 options.flow_calculation.alpha_smooth   = 0.05;
 flows3d_compute_structured_grid(wave3d, X, Y, Z, time, options);
 %%
 clear ux uy uz
 %% 
 figure
 histogram(ux)
 hold
 histogram(uy)
 histogram(uz)
 %%
 for tt=1:22; pcolor3(squeeze(wave3d(tt, :, :, :))); caxis([0 2]); pause(0.5); clf;end
 
 %%
 for tt=1:21; clf; pcolor3(ux(:, :, :, tt));caxis([0 3]);colorbar;pause(0.5);end
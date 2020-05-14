function test_flows3d_estimation__travelling_biharmonic_wave_sah()
% NOTE: Takes about 110 seconds @ dracarys
% Generate data with these step sizes
 options.hx = 0.004;
 options.hy = 0.004;
 options.hz = 0.004;
 options.grid.lim_type = 'none'; % do not use ceil to calculate the grid.
 options.ht = 0.025;

 
 [data, ~] = generate_data3d_travelling_biharmonic_wave('hxyz', options.hx, ...
                                                        'ht',   options.ht, ...
                                                        'lim_type', options.grid.lim_type, ...
                                                        'grid_type', 'structured');


end % function test_flows3d_estimation__travelling_biharmonic_wave_sah()

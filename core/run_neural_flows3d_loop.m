function run_neural_flows3d_loop(mfile_interp, mfile_vel, options)
% TODO: Future self: Document this function. 
% Make standalone function to peform the optical flow loop

% Read kind of input paramters, options is a bad name for a structure
% with parameters that are not actually mandatory 

dtpts        = options.flow_calculation.dtpts;
alpha_smooth = options.flow_calculation.alpha_smooth;
max_iterations = options.flow_calculation.max_iterations;
grid_size      = options.flow_calculation.grid_size;

hx = mfile_vel.hx;
hy = mfile_vel.hy;
hz = mfile_vel.hz;
ht = mfile_vel.ht;

if strcmp(options.flow_calculation.init_conditions, 'random')
    seed_init_vel = options.flow_calculation.seed_init_vel;
    [uxo, uyo, uzo] = get_initial_velocity_distribution(grid_size, ~mfile_vel.in_bdy_mask, seed_init_vel);

    % Do a burn-in period for the first frame (eg, two time points of data)
    % Random initial conditions are horrible.   

    this_tpt = 1;
    FA = mfile_interp.data(:, :, :, this_tpt);
    FB = mfile_interp.data(:, :, :, this_tpt+1);


    burnin_len = 4; % for iterations, not much but better than one
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started burn-in period for random initial velocity conditions.'))

    for bb=1:burnin_len
        % Calculate the velocity components
        [uxo, uyo, uzo] = compute_flow_hs3d(FA, FB, alpha_smooth, ...
                                                    max_iterations, ...
                                                    uxo, uyo, uzo, ...
                                                    hx, hy, hz, ht);       
    end
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Finished burn-in period for random initial velocity conditions.'))

else
   fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Using pre-calculated initial velocity conditions.'))
    % NOTE: I'm going to assume that somehow we passed the uxo, uyo, uzo arrays
    % in 'options' structure
    uxo = options.flow_calculation.uxo;
    uyo = options.flow_calculation.uyo;
    uzo = options.flow_calculation.uzo;   
end
    
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Started estimation of flows.'))

for this_tpt = 1:dtpts-1

       % Read activity data                
       FA = mfile_interp.data(:, :, :, this_tpt);
       FB = mfile_interp.data(:, :, :, this_tpt+1);

       % Calculate the velocity components
        [uxo, uyo, uzo] = compute_flow_hs3d(FA, FB, alpha_smooth, ...
                                                    max_iterations, ...
                                                    uxo, uyo, uzo, ...
                                                    hx, hy, hz, ht);                                

       % Save the velocity components
       mfile_vel.ux(:, :, :, this_tpt) = single(uxo);
       mfile_vel.uy(:, :, :, this_tpt) = single(uyo);
       mfile_vel.uz(:, :, :, this_tpt) = single(uzo);
               
       % Save some other useful information
       mfile_vel = get_vfield_info(mfile_vel, uxo(:), uyo(:), uzo(:), this_tpt);
                              
end
end % function compute_3d_flows()

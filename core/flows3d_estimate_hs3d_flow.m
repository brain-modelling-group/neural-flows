function flows3d_estimate_hs3d_flow(mfile_data, mfile_vel, options)
% Read kind of input paramters, options is a bad name for a structure
% with parameters that are not actually mandatory 

% mfile_data is the mat file with the data (interpolated or not)
% but it could be a 4D array with all the data in it
try 
    % check if we can get the size, if yes, it means this var is a 4D array
    if length(size(mfile_data)) == 4
        data = mfile_data;
        clear mfile_data
        mfile_data.data = data;
        clear data
        disp(['neural-flows::', mfilename, '::Info:: Input data is stored in an array.'])
    end
catch
        disp(['neural-flows::', mfilename,'::Info:: Input data is stored in a MatFile.'])
end
            
% Get parameters
dtpts          = options.flow_calculation.dtpts;
alpha_smooth   = options.flow_calculation.alpha_smooth;
max_iterations = options.flow_calculation.max_iterations;
grid_size      = options.flow_calculation.grid_size;

hx = mfile_vel.hx;
hy = mfile_vel.hy;
hz = mfile_vel.hz;
ht = mfile_vel.ht;

x_dim = 1;
y_dim = 2;
z_dim = 3;

if strcmp(options.flow_calculation.init_conditions, 'random')
    seed_init_vel = options.flow_calculation.seed_init_vel;
    [uxo, uyo, uzo] = flows3d_hs3d_get_initial_flows(grid_size, ~mfile_vel.in_bdy_mask, seed_init_vel);

else
   fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Using pre-calculated initial velocity conditions.'))
    % NOTE: I'm going to assume that somehow we passed the uxo, uyo, uzo arrays
    % in 'options' structure
    uxo = options.flow_calculation.uxo;
    uyo = options.flow_calculation.uyo;
    uzo = options.flow_calculation.uzo;   
end

% Create mfile_vel disk
mfile_vel.ux(size(uxo, x_dim), size(uxo, y_dim), size(uxo, z_dim), dtpts-1) = 0;    
mfile_vel.uy(size(uyo, x_dim), size(uyo, y_dim), size(uyo, z_dim), dtpts-1) = 0;
mfile_vel.uz(size(uzo, x_dim), size(uzo, y_dim), size(uzo, z_dim), dtpts-1) = 0;


% Set velocity field at the points located in shell between inner and outer boundaries to zero
try 
    diff_mask = mfile_vel.diff_mask;
catch 
    diff_mask = []; % assume we are using a grid and do not need diff_mask
end


% Do a burn-in period for the first frame (eg, two time points of data)
this_tpt = 1;
FA = mfile_data.data(:, :, :, this_tpt);
FB = mfile_data.data(:, :, :, this_tpt+1);

burnin_len = 4; % for iterations, not much but better than one
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started burn-in period for random initial velocity conditions.'))

for bb=1:burnin_len
    % Calculate the velocity components
    [uxo, uyo, uzo] = flows3d_hs3d(FA, FB, alpha_smooth, ...
                                           max_iterations, ...
                                           uxo, uyo, uzo, ...
                                           hx, hy, hz, ht);       
end
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished burn-in period for random initial velocity conditions.'))


fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started estimation of flows.'))

for this_tpt = 1:dtpts-1
    
       % Dirichlet Boundary conditions - Make boundary points zero velocity                                   
    if ~isempty(diff_mask)
        uxo(diff_mask) = 0;
        uyo(diff_mask) = 0;
        uzo(diff_mask) = 0;
    end

    % Read activity data                
    FA = mfile_data.data(:, :, :, this_tpt);
    FB = mfile_data.data(:, :, :, this_tpt+1);

    % Calculate the velocity components
    [uxo, uyo, uzo] = flows3d_hs3d(FA, FB, alpha_smooth, ...
                                           max_iterations, ...
                                           uxo, uyo, uzo, ...
                                           hx, hy, hz, ht);
 
    % Save the velocity components
    mfile_vel.ux(:, :, :, this_tpt) = single(uxo);
    mfile_vel.uy(:, :, :, this_tpt) = single(uyo);
    mfile_vel.uz(:, :, :, this_tpt) = single(uzo);
    [~, mfile_vel.un(:, :, :, this_tpt)]  =  single(normalise_vector_field([uxo(:) uyo(:) uzo(:)], 2));
    % Save some other useful information to guesstimate the singularity detection threshold
    mfile_vel = flows3d_hs3d_flow_stats(mfile_vel, uxo(:), uyo(:), uzo(:), this_tpt);

end
end % function flows3d_estimate_hs3d_flow()

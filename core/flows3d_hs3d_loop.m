function flows3d_hs3d_loop(obj_data, obj_flows, params, varargin)
% This function runs the iterative part of the Horn-Schunk algorithm. 
%
% ARGUMENTS:
%          obj_data --- is the MatFile file with the data (interpolated
%                       or not), or a 4D [x,y,z,t] array with all the
%                       data.
%          obj_vel  -- a handle to the MatFile 
%          params   -- almighty structure with everything
%          varargin -- if intiail flows are precalculated, then pass them here
%                   -- a structure with initial_conditions.uxo
%                                                         .uyo
%                                                         .uzo
%
% OUTPUT: 
%          None
%
% REQUIRES: 
%           flows3d_hs3d_set_initial_flows()
%           flows3d_hs3d_step()
%           flows3d_hs3d_flow_stats()
%           normalise_3dvector_field()
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon -- QIMR December 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin > 3
    intial_conditions = varargin{1};
end
     
% Get parameters
tpts           = params.data.shape.timepoint;
alpha_smooth   = params.flows.method.hs3d.alpha_smooth;
max_iterations = params.flows.method.hs3d.max_iterations;
grid_size      = [params.interpolation.data.shape.y, ...
                  params.interpolation.data.shape.x, ...
                  params.interpolation.data.shape.z]];

% Resolution
hx = params.interpolation.hx;
hy = params.interpolation.hy;
hz = params.interpolation.hz;
ht = params.data.ht;

x_dim_mgrid = params.data.x_dim_mgrid;
y_dim_mgrid = params.data.y_dim_mgrid;
z_dim_mgrid = params.data.z_dim_mgrid;

switch params.flows.method.hs3d.initial_conditions.mode
     case {'random', 'rand'}
         seed_init = params.flows.method.hs3d.initial_conditions.seed;
         [uxo, uyo, uzo] = flows3d_hs3d_set_initial_flows(grid_size, ~mfile_flows.interp_mask, seed_init_vel);
     case {'precal', 'precalculated', 'prev', 'user'}
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Using pre-calculated initial velocity conditions.'))
        % NOTE: I need to pass initial conditions in the flow files 
        uxo = initial_conditions.uxo;
        uyo = initial_conditions.uyo;
        uzo = initial_conditions.uzo;   
     otherwise
         error(['neural-flows:' mfilename ':UnknownCase'], ...
                'Unknown grid type. Options: {"random", "precalculated"}');
end
    
else
    
end

% Write to disk 
mfile_flows.ux(params.interpolation.data.shape.y, ...
               params.interpolation.data.shape.x, ...
               params.interpolation.data.shape.z, ...
               params.data.ht-1) = 0;    

mfile_flows.uy(size(uyo, x_dim), size(uyo, y_dim), size(uyo, z_dim), dtpts-1) = 0;
mfile_flows.uz(size(uzo, x_dim), size(uzo, y_dim), size(uzo, z_dim), dtpts-1) = 0;
%mfile_flows.un(size(uzo, x_dim), size(uzo, y_dim), size(uzo, z_dim), dtpts-1) = 0;


% Set velocity field at the points located in shell between inner and outer boundaries to zero
try 
    diff_mask = mfile_flows.diff_mask;
catch 
    diff_mask = []; % assume we are using a grid and do not need diff_mask
end


% Do a burn-in period for the first frame (eg, two time points of data)
this_tpt = 1;
FA = mfile_data.data(:, :, :, this_tpt);
FB = mfile_data.data(:, :, :, this_tpt+1);

burnin_len = 8; % for iterations, not much but better than one
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started burn-in period for random initial velocity conditions.'))

for bb=1:burnin_len
    % Calculate the velocity components
    [uxo, uyo, uzo] = flows3d_hs3d_step(FA, FB, alpha_smooth, ...
                                        max_iterations, ...
                                        uxo, uyo, uzo, ...
                                        hx, hy, hz, ht, ...
                                        diff_mask);       
end
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished burn-in period for random initial velocity conditions.'))


fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started estimation of flows.'))

for this_tpt = 1:dtpts-1
    
    % Dirichlet Boundary conditions - Make boundary points zero velocity                                   
    %if ~isempty(diff_mask)
    %    uxo(diff_mask) = 0;
    %    uyo(diff_mask) = 0;
    %    uzo(diff_mask) = 0;
    %end

    % Read activity data                
    FA = mfile_data.data(:, :, :, this_tpt);
    FB = mfile_data.data(:, :, :, this_tpt+1);

    % Calculate the velocity components
    [uxo, uyo, uzo] = flows3d_hs3d(FA, FB, alpha_smooth, ...
                                           max_iterations, ...
                                           uxo, uyo, uzo, ...
                                           hx, hy, hz, ht, ...
                                           diff_mask);
 
    % Save the velocity components
    %uno = single(sqrt(uxo.^2 + uyo.^2 + uzo.^2));
    mfile_flows.ux(:, :, :, this_tpt) = single(uxo);
    mfile_flows.uy(:, :, :, this_tpt) = single(uyo);
    mfile_flows.uz(:, :, :, this_tpt) = single(uzo);
    %mfile_flows.un(:, :, :, this_tpt) =  uno;
    % Save some other useful information to guesstimate the singularity detection threshold
    %mfile_flows = flows3d_hs3d_flow_stats(mfile_flows, uxo(:), uyo(:), uzo(:), uno(:), this_tpt);

end
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished estimation of flows.'))

end % function flows3d_estimate_hs3d_flow()

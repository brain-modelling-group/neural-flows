function [params] = flows3d_hs3d_loop(obj_data, obj_flows, params, varargin)
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
tpts           = params.data.shape.timepoints;
alpha_smooth   = params.flows.method.hs3d.alpha_smooth;
max_iterations = params.flows.method.hs3d.max_iterations;
grid_size      = [params.interpolation.data.shape.y, ...
                  params.interpolation.data.shape.x, ...
                  params.interpolation.data.shape.z]];
% Save parameters for flows
params.flows.data.shape.x = params.interpolation.data.shape.x; 
params.flows.data.shape.y = params.interpolation.data.shape.y;
params.flows.data.shape.z = params.interpolation.data.shape.z;
params.flows.data.shape.t = params.data.shape.timepoints-1;

% Resolution
hx = params.interpolation.hx;
hy = params.interpolation.hy;
hz = params.interpolation.hz;
ht = params.data.ht;

% 
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

% Write to disk 
mfile_flows.ux(params.interpolation.data.shape.y, ...
               params.interpolation.data.shape.x, ...
               params.interpolation.data.shape.z, ...
               tpts-1) = 0;    

mfile_flows.uy(params.interpolation.data.shape.y, ...
               params.interpolation.data.shape.x, ...
               params.interpolation.data.shape.z, ...
               tpts-1) = 0;
mfile_flows.uz(params.interpolation.data.shape.y, ...
               params.interpolation.data.shape.x, ...
               params.interpolation.data.shape.z, ...
               tpts-1) = 0;

% Set value of flows within the inner and outer boundaries, to zero. 
try 
    mask_betweenies = obj_flows.masks.betweenies;
catch 
    mask_betweenies = []; % assume we are using a grid and do not need diff_mask
end

%---------------------------------BURN-IN--------------------------------------%
% Do a burn-in period for the first frame (eg, two time points of data)
this_tpt = 1;
FA = obj_data.data(:, :, :, this_tpt);
FB = obj_data.data(:, :, :, this_tpt+1);

if ~isfield(inparams.flows.method.hs3d.burnin, 'length')
    burnin_length = 8; % for iterations, not much but better than one
    inparams.flows.method.hs3d.burnin.length = burnin_length;
end

fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started burn-in period for random initial velocity conditions.'))
for bb=1:burnin_len
    % Calculate the velocity components
    [uxo, uyo, uzo] = flows3d_hs3d_step(FA, FB, alpha_smooth, ...
                                        max_iterations, ...
                                        uxo, uyo, uzo, ...
                                        hx, hy, hz, ht, ...
                                        mask_betweenies);       
end
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished burn-in period for random initial velocity conditions.'))
%---------------------------------BURN-IN--------------------------------------%

fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started estimation of flows.'))

for this_tpt = 1:tpts-1
    
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
    [uxo, uyo, uzo] = flows3d_hs3d_step(FA, FB, alpha_smooth, ...
                                        max_iterations, ...
                                        uxo, uyo, uzo, ...
                                        hx, hy, hz, ht, ...
                                        mask_betweenies);
 
    % Save the velocity components and norm
    obj_flows.ux(:, :, :, this_tpt) = single(uxo);
    obj_flows.uy(:, :, :, this_tpt) = single(uyo);
    obj_flows.uz(:, :, :, this_tpt) = single(uzo);
    obj_flows.un(:, :, :, this_tpt) = single(sqrt(uxo.^2 + uyo.^2 + uzo.^2));;
    %Save some other useful information to guesstimate the singularity detection threshold
    flow_stats(this_tpt);

end

function flow_stats(this_tpt)
% Get basic info of a velocity vector field
% ARGUMENTS:
%   mfile_vel  -- an MatFile handle to the file where the data will be stored 
%   ux, uy, uz, un -- arrays with the componentns of the velocity vector field
%   this_tpt       -- index to store the info.
% OUTPUT       
%  mfile_vel  -- an mFile handle to the file where the new data fields will be stored 
% REQUIRES: 
%        None
%
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon, QIMR Berghofer December 2018
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    obj_flows.ux_min(1, this_tpt) = nanmin(uxo(:));
    obj_flows.ux_max(1, this_tpt) = nanmax(uxo(:));

    obj_flows.uy_min(1, this_tpt) = nanmin(uyo(:));
    obj_flows.uy_min(1, this_tpt) = nanmax(uyo(:));

    obj_flows.uz_min(1, this_tpt) = nanmin(uzo(:));
    obj_flows.uz_min(1, this_tpt) = nanmax(uzo(:));

    obj_flows.ux_sun(1, this_tpt) = nansum(uxo(:));
    obj_flows.uy_sum(1, this_tpt) = nansum(uyo(:));
    obj_flows.uz_sum(1, this_tpt) = nansum(uzo(:)); 
    
end % function flow_stats()

fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished estimation of flows.'))

end % function flows3d_hs3d_loop()

function [params] = flows3d_cnem_amplitude(obj_data, obj_flows, params, varargin)
% This function runs the iterative part of the Horn-Schunk algorithm. 
%
% ARGUMENTS:
%          obj_data --- is the MatFile file with the data (interpolated
%                       or not), or a 2D [t, num_nodes ] array with all the
%                       data.
%          obj_flows  -- a handle to the MatFile 
%          params     -- almighty structure with everything
%          varargin   -- if intiail flows are precalculated, then pass them here
%                     -- a structure with initial_conditions.uxo
%                                                         .uyo
%                                                         .uzo
%
% OUTPUT: 
%          params
%
% REQUIRES: 
%           flows3d_cnem_set_initial_flows()
%           flows3d_cnem_step()
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon -- QIMR April 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin > 3
    initial_conditions = varargin{1};
end
     
% Get parameters
tpts           = params.data.shape.timepoints;
alpha_smooth   = params.flows.method.hs3d.alpha_smooth;
max_iterations = params.flows.method.hs3d.max_iterations;
num_nodes = params.data.shape.nodes;

% Save parameters for flows
params.flows.data.shape.n = params.data.shape.nodes;
params.flows.data.shape.t = params.data.shape.timepoints-1;
ht = params.data.resolution.ht;
params.flows.data.ht = ht;

% Get location and boundary masks
masks = obj_data.masks;
locs  = obj_data.locs;

% Calculate neighbours matrix for averages
switch params.flows.method.cnem.convex_hull
    case {'bi', 'bihemispheric'}
    boundary_triangles = masks.innies_triangles_bi; 
    case {'lr', 'left-right'}
    boundary_triangles = masks.innies_triangles_lr;
end
        
tr = triangulation(boundary_triangles, locs);
vertex_idx_list = [1:params.data.shape.nodes].'; 
temp_mat = get_nth_ring_matrix(tr, vertex_idx_list, 1);
neighbours_matrix = build_neighbour_matrix(locs, temp_mat);

% Save masks
obj_flows.masks = masks;
% Save matrix
obj_flows.neighbours_matrix = neighbours_matrix;

B = flows3d_cnem_get_B_mat(locs, boundary_triangles);

switch params.flows.method.hs3d.initial_conditions.modality
     case {'random', 'rand'}
         seed_init = params.flows.method.hs3d.initial_conditions.seed;
         [uxo, uyo, uzo] = flows3d_cnem_set_initial_flows(num_nodes, seed_init);
     case {'precal', 'precalculated', 'prev', 'user'}
        fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Using pre-calculated initial flow conditions.'))
        % NOTE: I need to pass initial conditions in the flow files 
        uxo = initial_conditions.uxo;
        uyo = initial_conditions.uyo;
        uzo = initial_conditions.uzo;   
     otherwise
         error(['neural-flows:' mfilename ':UnknownCase'], ...
                'Unknown grid type. Options: {"random", "precalculated"}');
end

% Write to disk 
obj_flows.uxyz(num_nodes, 3, tpts-1) = 0;    
obj_flows.uxyz_n(num_nodes, tpts-1) = 0;    

%---------------------------------BURN-IN--------------------------------------%
% Do a burn-in period for the first frame (eg, two time points of data)
this_tpt = 1;
FA = obj_data.data(this_tpt, :);
FB = obj_data.data(this_tpt+1, :);

if ~isfield(params.flows.method.hs3d, 'burnin')
    burnin_length = 8; % for iterations, not much but better than one
    params.flows.method.hs3d.burnin.length = burnin_length;
else
    burnin_len = params.flows.method.hs3d.burnin.length;
end

fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started burn-in period for random initial velocity conditions.'))
for bb=1:burnin_len
    % Calculate the velocity components
    [uxo, uyo, uzo] = flows3d_cnem_step(FA, FB, alpha_smooth, ...
                                        max_iterations, ...
                                        uxo, uyo, uzo, ... 
                                        ht, ...
                                        neighbours_matrix, ...
                                        B);       
end
fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished burn-in period for random initial velocity conditions.'))
%---------------------------------BURN-IN--------------------------------------%

fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started estimation of flows.'))

for this_tpt = 1:tpts-1
    
    % Read activity data                
    FA = obj_data.data(this_tpt, :);
    FB = obj_data.data(this_tpt+1, :);

    % Calculate the velocity components
    [uxo, uyo, uzo] = flows3d_cnem_step(FA, FB, alpha_smooth, ...
                                        max_iterations, ...
                                        uxo, uyo, uzo, ...
                                        ht, ...
                                        neighbours_matrix, ...
                                        B);
 
    % Save the velocity components and norm
    obj_flows.uxyz(:, 1, this_tpt) = single(uxo);
    obj_flows.uxyz(:, 2, this_tpt) = single(uyo);
    obj_flows.uxyz(:, 3, this_tpt) = single(uzo);
    obj_flows.uxyz_n(:, this_tpt)  = single(sqrt(uxo.^2 + uyo.^2 + uzo.^2));
    %Save some other useful information to guesstimate the singularity detection threshold
    flow_stats(this_tpt);

end

function flow_stats(this_tpt)
% Get basic info of a velocity vector field
    obj_flows.ux_min(1, this_tpt) = nanmin(uxo(:));
    obj_flows.ux_max(1, this_tpt) = nanmax(uxo(:));

    obj_flows.uy_min(1, this_tpt) = nanmin(uyo(:));
    obj_flows.uy_min(1, this_tpt) = nanmax(uyo(:));

    obj_flows.uz_min(1, this_tpt) = nanmin(uzo(:));
    obj_flows.uz_min(1, this_tpt) = nanmax(uzo(:));

    obj_flows.ux_sum(1, this_tpt) = nansum(uxo(:));
    obj_flows.uy_sum(1, this_tpt) = nansum(uyo(:));
    obj_flows.uz_sum(1, this_tpt) = nansum(uzo(:)); 
    
end % function flow_stats()

fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished estimation of flows.'))

end % function flows3d_cnem_loop()


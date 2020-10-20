function obj_streams = streams3d_pathlines_cnem(obj_flows, obj_streams, params)
%% Traces pathlines. These are trajectories that individual fluid activity 
%  particles follow. These can be thought of as "recording" the path of a 
%  fluid element in the flow over a certain period. The direction the 
%  path takes will be determined by the streamlines of the fluid flow at 
%  each moment in time. This function updates the fluid flow after a 8 
%  iterations streamline tracing. 
% 
% REQUIRES: 
%          m_cnem3d_interpol()
%          
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     JA Roberts, QIMR Berghofer, 2018
%     Paula Sanz-Leon, QIMR Berghofer, 2019, 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Load necessary stuff
max_pathline_length = params.streamlines.tracing.max_pathline_length;
masks = obj_flows.masks;
locs  = obj_flows.locs;

if isfield(masks, 'innies_triangles_bi')
    boundary_faces = masks.innies_triangles_bi;
else
    boundary_faces = masks.innies_triangles;
end

time_step = params.streamlines.tracing.time_step; % fake time step for streamline tracing
tpts = params.flows.data.shape.t;

% Get seeding locations
initial_seeding_locs = get_seeding_locations(locs, params.streamlines.tracing.seeding_points.modality, ...
                                                   params.streamlines.tracing.seeding_points.seed);
% Save intial seeding locations
obj_streams.initial_seeding_locs = initial_seeding_locs;

switch params.flows.modality
    case "amplitude"
        tracing_cnem_fun_step = @tracing_cnem_amplitude_step;
    case "phase"
        tracing_cnem_fun_step = @tracing_cnem_phase_step;
    otherwise
       error(['neural-flows:' mfilename ':UnknownCase'], ...
               'Requested unknown modality. Options: {"amplitude", "phase"}'); 
end

% Initialise cell to save pathlines
pathlines_cell = cell(size(initial_seeding_locs, 1));

% Call everything
trace_pathlines()

function trace_pathlines()
    output_cell = tracing_cnem_step(1, initial_seeding_locs);
    new_seeding_locs = get_pathlines_end_vertices(output_cell);
    for pp = 1:size(initial_seeding_locs, 1)
        pathlines_cell{pp} = initial_seeding_locs(pp, :);
    end
    % Do the rest
    for tt = 2:tpts
       output_cell = tracing_cnem_fun_step(tt, new_seeding_locs);
       % Get new seeding locations
       new_seeding_locs = get_pathlines_end_vertices(output_cell); 
       % Append to output cell
       pathlines_cell = append_pathline_vertices(pathlines_cell, output_cell); 
    end
    % Save pathlines
    obj_streams.pathlines = pathlines_cell;
end % function tracing_cnem_step()


function pathline_cell = tracing_cnem_tracing_loop(locs, boundary_faces, flow_field, seed_locs, time_step, max_pathline_length)
% Tracing loop
% ARGUMENTS:
%          locs     -- a 2D array of size [nodes x 3] with the x,y,z
%                      coordinates of the nodes/regions centroids.
%          boundary_faces -- a 2D array of size [num_faces x 3] with the
%                            triangulation of the brain's convex hull.
%          flow_field -- a 2D array of size [nodes x 3] with the 
%                        velocity components u, v, w at each point in locs.
%                        
%          seed_locs  -- a 2D array of size [num_seeds x 3] with the x, y,z 
%                        coordinates of the streamlines starting points. 
%          time_step  -- a float with the time step used to trace the
%                        streamlines.
%          max_streamline_length -- an integer with the maximum length acceptable 
%                                  for a streamlines (in points/samples).
%                                  Matlab's streamline functions call this number  
%                                  'max number of vertices'. In a way, this
%                                  is the maximum number of timesteps tht
%                                  we will integrate.
%                                  
%
% OUTPUT: 
%          stream_cell -- a cell of length num_streams/length seed_locs
%                         where each element is a 2D array of size
%                         [stream_length_i x 3], and stream_length_i is at
%                         most max_streamline_length.

    % CNEM parameter - needs to be set but not changed
    Type_FF = 0;
    % Number of streamlinesm to start
    num_paths = size(seed_locs, 1);

    % Streamlines that are still growing
    live_streams = true(num_paths, 1); 

    embedding_dimension = 3;
    % Preallocate, will prune later
    streams(num_paths, embedding_dimension, max_pathline_length) = 0; 


    for this_iteration=1:max_pathline_length
    
        % Stop if all streamlines are done
        if all(~live_streams)
            break
        end
        
        % Make interpolation object at every iteration. We need to get values
        % of the vector field at the tip of the streamline.
        cnem_interpol_obj = m_cnem3d_interpol(locs, boundary_faces, seed_locs(live_streams,:), Type_FF);
        
        % terminate any streamlines that have left the interior
        livej = live_streams(live_streams); % live streamlines this iteration (has same length as number of live points)
        livej = livej & cnem_interpol_obj.In_Out;
        
        streams(live_streams, :, this_iteration) = seed_locs(live_streams,:);
        
        %if already been here, done
        % % how likely is this though!?
        
        % Interpolate velocity field 
        flowfield_interp = cnem_interpol_obj.interpolate(flow_field); % has same length as number of live points
        
        % check if step length has hit zero
        validsteps = ~all(~flowfield_interp, 2);
        %if any(~validsteps), fprintf('%d steps hit zero\n',sum(~validsteps)), end
        livej = livej&validsteps;
        
        % calculate step size
        % stream3c rescales the velocities by max(abs(vcomponent))
        flowfield_step = flowfield_interp*time_step./max(abs(flowfield_interp)); % uses singleton expansion
        
        % update overall live list
        live_streams(live_streams) = livej;
        
        % update the current position
        seed_locs(live_streams, :) = seed_locs(live_streams,:) + flowfield_step(livej,:);
    
    
    end

    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Started pruning streamline cell array.'))
    % Transform the streams array into a cell.
    conn = zeros(3, 3, 3);
    conn(2, 2, :) =1; 
    conn_comp = bwconncomp(streams, conn);
    ids = conn_comp.PixelIdxList; ids=reshape(ids,[],3);
    %slens=cellfun(@length,ids); %513x3
    %any(any(diff(slens,[],2),2)) % false if all x,y,z components are same length
    %
    num_paths = size(streams, 1);
    pathline_cell = cell(1, num_paths);

    for jj=1:num_paths
        pathline_cell{jj} = streams([ids{jj,:}]);
    end
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished pruning streamline cell array.'))


end %tracing_cnem_loop()


function output_cell = tracing_cnem_amplitude_step(idx)
        flow_field = obj_flows.uxyz(:, :, idx);
        output_cell = tracing_cnem_tracing_loop(locs, boundary_faces, flow_field, seeding_locs, time_step, max_pathline_length);
end % function tracing_cnem_amplitude_step()


function output_cell = tracing_cnem_phase_step(idx)
        flow_field = [obj_flows.vx(idx, :); obj_flows.vy(idx, :); obj_flows.vz(idx, :)].'; 
        output_cell = tracing_cnem_tracing_loop(locs, boundary_faces, flow_field, seeding_locs, time_step, max_pathline_length);
end % function tracing_cnem_phase_step()

function loci = get_pathlines_end_vertices(output_cell)
    loci = cellfun(@(x) [x(end, :)], output_cell, 'UniformOutput', false);
    loci = cell2mat(loci);
end

function pathlines_cell = append_pathline_vertices(pathlines_cell, pathline_segment_cell)
    pathlines_cell = cellfun(@(x,y) [x; y], pathlines_cell, pathline_segment_cell, 'UniformOutput', false);
end
end %function streams3d_tracing_cnem()

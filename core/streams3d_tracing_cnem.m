function stream_cell = streams3d_tracing_cnem(obj_streams, obj_flows, params)
%% Traces streamlines using a velocity field defined on scattered points in space
%  based on traceStreamXYZUVW from matlab's stream3c.c, using CNEM
%  functions.
%
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
% REQUIRES: 
%          m_cnem3d_interpol()
%          
% USAGE:
%{     
    load wind
    rng(42);
    loc_idx = randperm(length(x(:)), round(length(x(:))*0.05));
    locs = [x(loc_idx); y(loc_idx); z(loc_idx)].';
    flow_field = [u(loc_idx); v(loc_idx); w(loc_idx)].';
    dt = 0.5; % this value needs to be carefully selected
    max_stream_length = 256;
     
    % Get boundary/convex hull
    [~, bdy] = get_boundary_info(locs, locs(:, 1), locs(:, 2), locs(:, 3));

 
    streams = trace_streams_cnem(locs, bdy, flow_field, locs, dt, max_stream_length);
    % Visualize what we just did
    fig_handle = figure('Name', 'nflow_traced_streams');
    ax = axes('Parent', fig_handle);
    hold(ax, 'on')

    quiver3(locs(:, 1), locs(:, 2), locs(:, 3), ...
            flow_field(:, 1), flow_field(:, 2), ...
            flow_field(:, 3));
    % Start locations
    plot3(locs(:, 1), locs(:, 2), locs(:, 3), 'k.')
    
    for ii=1:length(streams);
        plot3(squeeze(streams{ii}(:, 1)), ...
              squeeze(streams{ii}(:, 2)), ...
              squeeze(streams{ii}(:, 3)), 'color', [0.5 0.5 0.5 0.1]);
       plot3(squeeze(streams{ii}(end, 1)), ...
              squeeze(streams{ii}(end, 2)), ...
              squeeze(streams{ii}(end, 3)), 'r.');
    end

% TODO: prepare an example with brain data -- save one frame of phase flow.
 from brain waves.

%}
%
% MODIFICATION HISTORY:
%     JA Roberts, QIMR Berghofer, 2018
%     Paula Sanz-Leon, QIMR Berghofer, 2019, 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Load necessary stuff
max_stream_length = params.streamlines.tracing.max_streamline_length;
masks = obj_flows.masks;
locs  = obj_flows.locs;
boundary_faces = masks.innies_triangles;
dt = params.streamlines.tracing.time_step; % fake time step for streamline tracing

switch params.streamlines.tracing.seeding_points
    case {"nodes", "regions", "nodal"}
        seed_locs = obj_flows.locs;
    case {"random-sparse"}
        rng(params.streamlines.tracing.seed)

        % do something
    case {"random-dense"}
        % seeds 2*num nodes streamlines

    otherwise
        error(['neural-flows:' mfilename ':UnknownCase'], ...
               'Requested unknown method. Options: {"nodes", "random-sparse", "random-dense"}');
end


switch params.flows.modality
    case "amplitude"
        tracing_cnem_fun_step = @tracing_cnem_amplitude_step
    case "phase"
        tracing_cnem_fun_step = @tracing_cnem_phase_step
    otherwise
       error(['neural-flows:' mfilename ':UnknownCase'], ...
               'Requested unknown modality. Options: {"amplitude", "phase"}'); 
end


tracing_cnem_step()


function tracing_cnem_step()
    for tt = 1:tpts
       obj_streams.streamlines(tt) = tracing_cnem_fun_step(tt); 
    end
end % function tracing_cnem_step()


function output_cell = tracing_cnem_amplitude_step(idx)
        flow_field = obj_flows.uxyz(:, :, idx);
        output_cell = tracing_cnem_loop(locs, boundary_faces, flow_field, seed_locs, time_step, max_stream_length);
end % function tracing_cnem_amplitude_step()


function output_cell = tracing_cnem_phase_step(idx)
        flow_field = [obj_flows.vx(idx, :) obj_flows.vy(idx, :) obj_flows.vz(idx, :)]; 
        output_cell = tracing_cnem_loop(locs, boundary_faces, flow_field, seed_locs, time_step, max_stream_length);
end % function tracing_cnem_phase_step()


function tracing_cnem_loop(locs, boundary_faces, flow_field, seed_locs, time_step, max_stream_length)
    % tracing loop

    % CNEM parameter - needs to be set but not changed
    Type_FF = 0;
    % Number of streamlinesm to start
    num_streams = size(seed_locs, 1);

    % Streamlines that are still growing
    live_streams = true(num_streams, 1); 

    embedding_dimension = 3;
    % Preallocate, will prune later
    streams(num_streams, embedding_dimension, max_stream_length) = 0; 


    for this_iteration=1:max_stream_length
    
        % Stop if all streamlines are done
        if all(~live)
            break
        end
        
        % Make interpolation object at every iteration. We need to get values
        % of the vector field at the tip of the streamline.
        cnem_interpol_obj = m_cnem3d_interpol(locs, boundary_faces, seed_locs(live_streams,:), Type_FF);
        
        % terminate any streamlines that have left the interior
        livej = live_streams(live_streams); % live streamlines this iteration (has same length as number of live points)
        livej = livej & cnem_interpol_obj.In_Out;
        
        streams(live_streams, :, this_iteration) = seed_locs(live,:);
        
        %if already been here, done
        % % how likely is this though!?
        
        % Inteprolate velocity field 
        flowfield_interp = cnem_interpol_obj.interpolate(flow_field); % has same length as number of live points
        
        % check if step length has hit zero
        validsteps = ~all(~flowfield_interp, 2);
        %if any(~validsteps), fprintf('%d steps hit zero\n',sum(~validsteps)), end
        livej = livej&validsteps;
        
        % calculate step size
        % stream3c rescales the velocities by max(abs(vcomponent))
        flowfield_step = flowfield_interp*time_step./max(abs(flowfield_interp)); % uses singleton expanson
        
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
    num_streams = size(streams, 1);
    stream_cell = cell(1, num_streams);

    for jj=1:num_streams
        stream_cell{jj} = streams([ids{jj,:}]);
    end
    fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: Finished pruning streamline cell array.'))


end %tracing_cnem_loop()

end %function streams3d_tracing_cnem()

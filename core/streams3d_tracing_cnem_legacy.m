function stream_cell = streams3d_tracing_cnem_legacy(locs, boundary_faces, flow_field, seed_locs, time_step, max_stream_length)
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
%     Paula Sanz-Leon, QIMR Berghofer, 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin<6
    max_stream_length = 200;
end

% CNEM parameter
Type_FF = 0;

% Number of streamlines
num_streams = size(seed_locs, 1);

% Streamlines that are still growing
live = true(num_streams, 1); 

embedding_dimension = 3;
% Preallocate, will prune later
streams(num_streams, embedding_dimension, max_stream_length) = 0; 

disp([mfilename ':: Tracing streamlines ...'])
    
for it = 1:max_stream_length
    
    % Stop if all streamlines are done
    if ~live
        break
    end
    
    % Make interpolation object at every iteration. We need to get values
    % of the vector field at the tip of the streamline.
    FInterpol = m_cnem3d_interpol(locs, boundary_faces, seed_locs(live,:), Type_FF);
    
    % terminate any streamlines that have left the interior
    livej = live(live); % live streamlines this iteration (has same length as number of live points)
    livej = livej & FInterpol.In_Out;
    
    streams(live,:, it) = seed_locs(live,:);
    
    %if already been here, done
    % % how likely is this though!?
    
    % Inteprolate velocity field 
    flowfield_interp = FInterpol.interpolate(flow_field); % has same length as number of live points
    
    % check if step length has hit zero
    validsteps = ~all(~flowfield_interp, 2);
    %if any(~validsteps), fprintf('%d steps hit zero\n',sum(~validsteps)), end
    livej = livej&validsteps;
    
    % calculate step size
    % stream3c rescales the velocities by max(abs(vcomponent))
    flowfield_step = flowfield_interp*time_step./max(abs(flowfield_interp)); % uses singleton expanson
    
    % update overall live list
    live(live) = livej;
    
    % update the current position
    seed_locs(live, :) = seed_locs(live,:) + flowfield_step(livej,:);
    
    
end

disp([mfilename ':: Pruning streamline array ...'])

% Transform the streams array into a cell.
conn = zeros(3, 3, 3);
conn(2, 2, :) =1; 
conncomp = bwconncomp(streams,conn);
ids = conncomp.PixelIdxList; ids=reshape(ids,[],3);
%slens=cellfun(@length,ids); %513x3
%any(any(diff(slens,[],2),2)) % false if all x,y,z components are same length
%
ns = size(streams, 1);
stream_cell = cell(1,ns);
for j=1:ns
    stream_cell{j} = streams([ids{j,:}]);
end
disp([mfilename ':: Done.'])

end %function trace_streams_cnem()
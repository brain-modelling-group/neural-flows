function obj_streams = streams3d_tracing_mlab(obj_flows, obj_streams, params)
%% Traces streamlines using a velocity field defined on a grid in space
% % TODOC
% REQUIRES: 
%          
%          
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon, QIMR Berghofer, 2019, 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% Get some useful information for what we're about to do
masks = obj_flows.masks;
innies_idx = find(masks.innies == true);
outties_idx = find(masks.innies == false);
time_step = params.streamlines.tracing.time_step; % fake time step for streamline tracing
max_stream_length = params.streamlines.tracing.max_stream_length;
tpts = params.flows.data.shape.t;

% Get seeding locations
X0 = obj_flows.X;
Y0 = obj_flows.Y;
Z0 = obj_flows.Z;

seeding_locs = get_seeding_locations_3d_slice(X0(innies_idx), Y0(innies_idx), Z0(innies_idx), ...
                                              params.streamlines.tracing.seeding_points.modality, ...
                                              params.streamlines.tracing.seeding_points.seed);
% Save seeding locations & grid
obj_streams.seeding_locs = seeding_locs;
obj_streams.X = obj_flows.X;
obj_streams.Y = obj_flows.Y;
obj_streams.Z = obj_flows.Z;

% Allocate struct
streamlines.paths = [];

% Trace streamlines
tracing_mlab_time_loop()

function tracing_mlab_time_loop()
    for tt = 1:10
       streamlines.paths = tracing_mlab_step(tt); 
       obj_streams.streamlines(1, tt) = streamlines; 
    end
end % function tracing_mlab_time_loop()


function verts = tracing_mlab_step(t_idx)
% Load frame -- NOTE: maybe unnecessary step
ux = obj_flows.ux(:, :, :, t_idx);
uy = obj_flows.uy(:, :, :, t_idx); 
uz = obj_flows.uz(:, :, :, t_idx); 

% Set NaNs to zero -- NOTE: maybe unnecessary step
ux(outties_idx) = 0;
uy(outties_idx) = 0;
uz(outties_idx) = 0;

verts = stream3(obj_flows.X, obj_flows.Y, obj_flows.Z, ...
                ux, uy, uz, ...
                seeding_locs.X, ...
                seeding_locs.Y, ...
                seeding_locs.Z, [time_step, max_stream_length]);             
end % function tracing_mlab_time_loop()

end % function streams3d_tracing_mlab()

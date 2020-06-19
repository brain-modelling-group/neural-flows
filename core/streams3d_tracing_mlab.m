function obj_streams = streams3d_tracing_mlab(obj_flows, obj_streams, params)
%% Traces streamlines using a velocity field defined on a grid in space
%  based on.
%
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
% Trace streamlines for one frame 
tt=2;

% Save grid 
obj_streams.X = obj_flows.X;
obj_streams.Y = obj_flows.Y;
obj_streams.Z = obj_flows.Z;


x_dim = 1;
y_dim = 2;
z_dim = 3;

masks = obj_flows.masks;
innies_idx = find(masks.innies) == true;

% Get seeding locations
seeding_locs = get_seeding_locations_3d_slice(obj_flows.X(innies_idx), obj_flows.Y(innies_idx), obj_flows.Z(innies_idx), ...
                                              params.streamlines.tracing.seeding_points.modality, ...
                                              params.streamlines.tracing.seeding_points.seed);
% Save seeding locations
obj_streams.seeding_locs = seeding_locs;


streamlines.paths = [];
tracing_mlab_time_loop()

function tracing_mlab_time_loop()
    for tt = 1:tpts
       streamlines.paths = tracing_mlab_step(tt); 
       obj_streams.streamlines(1, tt) = streamlines; 
    end
end % function tracing_mlab_time_loop()


function tracing_mlab_step(t_idx)
% Trace streamlines
verts = stream3(X, Y, Z, obj_flows.ux(:, :, :, tt), ...
                         obj_flows.uy(:, :, :, tt), ...
                         obj_flows.uz(:, :, :, tt), ...
                         seeding_locs.X, ...
                         seeding_locs.Y, ...
                         seeding_locs.Z, [2^-12]); 

end % function tracing_mlab_time_loop()



end % function streams3d_tracing_mlab()

function fig_handle = plot3d_scatter_local_flow_classes(fig_handle, obj_flows, frame_idx)

    if isempty(fig_handle)
        fig_handle = figure('Name', 'neural-flows-local-flow-classes');
    end
    
ax = subplot(1,1,1, 'Parent', fig_handle);

% Load necessary stuff from obj_flows

X = obj_flows.X;
Y = obj_flows.Y;
Z = obj_flows.Z;

% Special cmap for local flow classes
cmap = divdiv2d_9();

classification_cell_num = obj_flows.flow_classification_num;
masks = obj_flows.masks;

tmp = classification_cell_num{1, frame_idx};
scatter3(ax, X(masks.innies), Y(masks.innies), Z(masks.innies), 200, cmap(tmp(masks.innies)+1, :), 'filled')
colormap(cmap)
end %function plot3d_scatter_local_flow_classes()
function ax_handle = plot3d_flows_ts(obj_flows, ax_handle)

if nargin < 2
    ax_handle = axes;
end

num_points = obj_flows.num_innies; 
figure_handle = figure('Name', 'nflows-flows-average-over-time', varargin{:});


hold(ax_handle, 'on')

plot3(ax_handle, obj_flows.sum_ux(1,1)/num_points, obj_flows.sum_uy(1,1)/num_points, obj_flows.sum_uz(1,1)/num_points, ...
                 '.', 'markerfacecolor', 'b', 'markersize', 20)
plot3(ax_handle, obj_flows.sum_ux(1,end)/num_points, obj_flows.sum_uy(1,end)/num_points, obj_flows.sum_uz(1,end)/num_points, ...
                 '.', 'markerfacecolor', 'r', 'markersize', 20)

plot3(ax_handle, obj_flows.sum_ux/num_points, obj_flows.sum_uy/num_points, obj_flows.sum_uz/num_points)


end % function plot3d_flows_ts()
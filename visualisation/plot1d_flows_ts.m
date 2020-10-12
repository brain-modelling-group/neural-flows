function ax_handle = plot1d_flows_ts(obj_flows, ax_handle)

if nargin < 2
    ax_handle = axes;
end

num_points = obj_flows.num_innies; 
figure_handle = figure('Name', 'nflows-flows-average-over-time', varargin{:});


hold(ax_handle, 'on')
plot(ax_handle, obj_flows.sum_ux/num_points, 'r')
plot(ax_handle, obj_flows.sum_uy/num_points, 'g')
plot(ax_handle, obj_flows.sum_uz/num_points, 'b')
ax_handle.XLabel.String = 'time/samples'
ax_handle.YLabel.String = 'u_{x, y, z}'

end % function plot1d_flows_ts()
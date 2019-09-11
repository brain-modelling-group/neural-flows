function ax_handle = plot_flows_ts(mflow_obj, ax_handle)

if nargin < 2
    ax_handle = axes;
end

num_voxels = 1004186;

hold(ax_handle, 'on')

plot3(ax_handle, mflow_obj.sum_ux(1,1)/num_voxels, mflow_obj.sum_uy(1,1)/num_voxels, mflow_obj.sum_uz(1,1)/num_voxels, ...
                 '.', 'markerfacecolor', 'b', 'markersize', 20)
plot3(ax_handle, mflow_obj.sum_ux(1,end)/num_voxels, mflow_obj.sum_uy(1,end)/num_voxels, mflow_obj.sum_uz(1,end)/num_voxels, ...
                 '.', 'markerfacecolor', 'r', 'markersize', 20)

plot3(ax_handle, mflow_obj.sum_ux/num_voxels, mflow_obj.sum_uy/num_voxels, mflow_obj.sum_uz/num_voxels)


end
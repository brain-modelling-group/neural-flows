function fig_handle = plot2d_svd_modes(params)
% wrapper function

% Lod necessary data
obj_flows = load_iomat_flows(params);
svd_data = obj_flows.flow_modes; 

% Define a few vecs we need
time_vec = params.data.ht:params.data.ht:params.flows.data.shape.t*params.data.ht; 
quiver_scale_factor = params.visualisation.quiver.scale;
num_modes = params.flows.decomposition.svd.modes;

fig_handle =  plot_svd_modes(vertcat(svd_data.V.vx, svd_data.V.vy, svd_data.V.vy), ...
	                         svd_data.U, svd_data.XYZ.X, svd_data.XYZ.Y, svd_data.XYZ.Z, ...
                             time_vec, num_modes, svd_data.num_points, ...
                             svd_data.prct_var, quiver_scale_factor);

end % function plot2d_svd_modes()
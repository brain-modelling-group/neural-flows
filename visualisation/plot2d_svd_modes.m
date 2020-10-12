function fig_handle = plot2d_svd_modes(params)
% wrapper function

% Lod necessary data
obj_flows = load_iomat_flows(params);
svd_data = obj_flows.flow_modes; 

% Define a few vecs we need
time_vec = params.data.ht:params.data.ht:params.flows.data.shape.t*params.data.ht; 
fig_handle =  plot_svd_modes(svd_data.V, svd_data.U, ...
                             svd_data.XYZ.X, svd_data.XYZ.Y, svd_data.XYZ.Z, ...
                             svd_data.prct_var, params.flows.decomposition.svd.modes, ...
                             time_vec);
end % function plot2d_svd_modes()
function perform_svd(params)
% Performs singular vector decomposition of a vector field.
% Plots most dominant spatial modes and their time series 
% 
% USAGE:
%{
    
%}
% AUTHOR:
% Paula Sanz-Leon, QIMR Berghofer, 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        

% Load flows data

svd_struct = svd_3d(params);
obj_flows = load_iomat_flows(params);
obj_flows.Properties.Writable = true;
obj_flows.flow_modes = svd_struct;
obj_flows.Properties.Writable = false;
end % function perform_svd()

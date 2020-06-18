function calculate_kinetic_energy(params)
% TODOC: 
% Wrapper function to call appropriate low level functions
% ARGUMENTS:
%  
% 
%
% REQUIRES: 
%
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon, QIMR Berghofer 2020
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch params.flows.quantification.energy.modality
	case {"nodal", "unstructured"}
		energy_fun = @calculate_energy_nodal;
    case {"grid", "structured"}
    	energy_fun = @calculate_energy_grid;
    case {"mesh", "triangulation", "tesselation", "surf"}
    	energy_fun = @calculate_energy_surf;
	otherwise
end

obj_flows = load_iomat_flows(params);

% Calculate stuff
energy_struct = energy_fun(params, obj_flows);

%
display_flag = 'true';
extrema_detection = 'peaks';
time_vec = params.flows.data.ht:params.flows.data.ht:params.flows.data.shape.t*params.flows.data.ht;
[stable, transient, stablePoints, transientPoints] = energy_states(energy_struct.spatial_sum, time_vec, params.flows.data.ht, min_duration, extrema_detection, display_flag);


% Save output
obj_flows.kinetic_energy = energy_struct;


end % end calculate_kinetic_energy()

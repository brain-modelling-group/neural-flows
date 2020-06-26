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
obj_flows.Properties.Writable = true;

% Calculate stuff
energy_struct = energy_fun(params, obj_flows);

% Do some basic stuff to shocawcase kintic energy functions
display_flag = 'true';
extrema_detection = 'peaks';
% TODO: TOFIX: use resolution and length of FLOWS/NOT DATA
time_vec = params.data.ht:params.data.ht:params.flows.data.shape.t*params.data.ht;
min_duration_stable_state = params.data.ht * 30;
[stable, transient, stablePoints, transientPoints] = energy_states(energy_struct.component_sum_norm, time_vec, params.data.ht, min_duration_stable_state, extrema_detection, display_flag);


% Save output
obj_flows.kinetic_energy = energy_struct;


end % end calculate_kinetic_energy()

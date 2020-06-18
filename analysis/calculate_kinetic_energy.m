function calculate_energy_grid(params)
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
%     Paula Sanz-Leon, QIMR Berghofer 2018
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE: Displacement energy, this is a kinectic energy-like expression: 1/2 m v^2
% The mass is m=1

switch params.flows.quantification.energy.modality
	case {"nodal", "unstructured"}
		energy_fun = @calculate_energy_nodal;
    case {"grid", "structured"}
    	energy_fun = @calculate_energy_grid;
    case {"mesh", "triangulation", "tesselation"}
    	energy_fun = @calculate_energy_tess;
	otherwise
end

obj_flows = load_iomat_flows(params);

% Calculate stuff
energy_struct = energy_fun(obj_flows)

% Save output
obj_flows.kinetic_energy = energy_struct;

end % end calculate_kinetic_energy()

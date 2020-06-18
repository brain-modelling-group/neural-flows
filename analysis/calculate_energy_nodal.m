function [energy] = calculate_energy_nodal(params, obj_flows)
%Computation of kinetic energy. The kinetic energy is similar to the norm of the
% vector field, but it emphasizes low ( val < 1) vs high energy states (val > 1)
% ARGUMENTS:
%  flow_field         -- A 3D array with flow fields of size
%                       [nodes, 3, timepoints]
% OUTPUT:
%
%   energy.node       -- Displacement energy in the flow field,
%                             returns energy for node    
% 
%   energy.sum        -- Displacement energy in the flow,
%                             summed over space. 
%   energy.av         -- Average displacement enegy
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
% The mass is m=1, although nodes could have different masses/weigths (eg, hubs/nonhubs)

tpts   = params.flows.data.shape.t;
num_nodes  = size(locs, 1);

% Probably best to iterate over time
temp_energy(num_nodes, tpts) = 0;

parfor tt=1:tpts
    un = obj_flows.uxyz_n(:, tt);
    temp_energy(:, tt) = kinetic_energy(un);
end
% Calculate "norm" using the sum (over space) of each individual velocity component
norm_sum_flow = sqrt(obj_flows.ux_sum.^2 + obj_flows.uy_sum.^2 + obj_flows.uz_sum.^2); 

energy.spatial_sum = nansum(temp_energy);
energy.spatial_average = nanmean(temp_energy);
energy.spatial_median  = nanmedian(temp_energy);
energy.component_sum_norm = kinetic_energy(norm_sum_flow);
energy.component_sum_ux = kinetic_energy(obj_flows.ux_sum);
energy.component_sum_uy = kinetic_energy(obj_flows.uy_sum);
energy.component_sum_uz = kinetic_energy(obj_flows.uz_sum);

end % end calculate_energy_nodal()

function [energy] = calculate_nodal_energy(flow_field)
%Computation of kinetic energy 
% ARGUMENTS:
%  flow_field         -- A 3D array with flow fields of size
%                       [nodes, 3, timepoints]
% OUTPUT:
%
%   energy_node       -- Displacement energy in the flow field,
%                             returns energy for node    
% 
%   energy_sum        -- Displacement energy in the flow,
%                             summed over space. 
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


xdim = 1;
ydim = 2;
zdim = 3;
% May use lots of memory
energy.node = squeeze((((flow_field(:, xdim, :).^2 + flow_field(:, ydim, :).^2 + flow_field(:, zdim, :).^2)/2)));

% 
energy.sum = sum(energy_node);

energy.av = mean(energy_node);

end % end calculate_nodal_energy()

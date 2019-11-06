function [energy] = calculate_energy_nodal(flow_field)
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


xdim = 1;
ydim = 2;
zdim = 3;
flow_field(isnan(flow_field)) = 0;
% May use lots of memory
energy.node = squeeze((((flow_field(:, xdim, :).^2 + flow_field(:, ydim, :).^2 + flow_field(:, zdim, :).^2)/2)));

% 
energy.sum = nansum(energy.node);

energy.av = mean(energy.node);

end % end calculate_nodal_energy()

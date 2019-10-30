function [energy] = calculate_energy_grid(mflow_obj)
%Computation of kinetic energy. The kinetic energy is similar to the norm of the
% vector field, but it emphasizes low ( val < 1) vs high energy states (val > 1)
% ARGUMENTS:
%  mflow_obj         -- a Matfile handle or structure with similar fields
% 
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
% The mass is m=1
 
tpts = size(mflow_obj.ux, 'ux', 4);

% Probably best to iterate over time

energy.node(sum(find(mflow_obj.interp_mask)), tpts) = 0;

for tt=1:tpts
    ux = mflow_obj.ux(:, :, :, tt);
    uy = mflow_obj.uy(:, :, :, tt);
    uz = mflow_obj.uz(:, :, :, tt);
    energy.node(:, tt) = 0.5*(ux(mflows.interp_mask == true).^2 + uy(mflows.interp_mask == true).^2 + uz(mflows.interp_mask == true).^2);
end
% 
energy.sum = sum(energy.node);

energy.av = mean(energy.node);

end % end calculate_energy_grid()

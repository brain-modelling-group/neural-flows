function [energy] = calculate_energy_grid(obj_flows)
%Computation of kinetic energy. The kinetic energy is similar to the norm of the
% vector field, but it emphasizes low ( val < 1) vs high energy states (val > 1)
% ARGUMENTS:
%  obj_flows         -- a Matfile handle or structure with similar fields
% 
% OUTPUT:
%% 
%   energy.spatial_sum        -- Displacement energy in the flow,
%                             summed over space. 
%   energy.spatial_average    -- Average displacement enegy
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

params = obj_flows.params; 
tpts   = params.flows.data.shape.t;


% Probably best to iterate over time
innies_idx = find(obj_flows.masks.innies == true);
temp_energy(length(innies)), tpts) = 0;
temp_energy(length(innies)), tpts) = 0;

parfor tt=1:tpts
    un = obj_flows.un(:, :, :, tt);
    temp_energy(:, tt) = kinetic_energy(un(innies_idx));
end
% 
energy.spatial_sum = nansum(temp_energy);
energy.spatial_average = nanmean(temp_energy);
energy.spatial_median  = nanmedian(temp_energy);

end % end calculate_energy_grid()
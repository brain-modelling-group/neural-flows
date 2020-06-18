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

params = obj_flows.params; 
tpts   = params.flows.data.shape.t;


% Probably best to iterate over time
temp_energy(length(find(obj_flows.in_bdy_mask)), tpts) = 0;
good_idx = find(obj_flows.interp_mask == true);
parfor tt=1:tpts
    ux = obj_flows.ux(:, :, :, tt);
    uy = obj_flows.uy(:, :, :, tt);
    uz = obj_flows.uz(:, :, :, tt);
    temp_energy(:, tt) = 0.5*(ux(good_idx).^2 + uy(good_idx).^2 + uz(good_idx).^2);
end
% 
energy.nodal = 
energy.spatial_sum = nansum(temp_energy);

energy.spatial_average = nanmean(temp_energy);

end % end calculate_energy_grid()

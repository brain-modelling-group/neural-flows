function [ux, uy, uz] = generate_flow3d_burgesvortex_grid()
% Generates Bruges vortex flow

alpha = 0.2; % strain-rate 
gamma = 0.1; % circulation
nu = 0.1;      % kinematic viscosity
ro = sqrt(4*nu/alpha); % core radius
omegaz = gamma/(pi*ro^2); % spanwise vorticity

% Author, Paula Sanz-Leon
% Reference: 
%https://aip.scitation.org/doi/full/10.1063/1.4893343
% Analytic solutions for three dimensional swirling strength in compressible and incompressible flows
% Eq (12)
x = linspace(-5, 5, 21);
[X, Y, Z] = meshgrid(x, x, x);
R = X.^2+Y.^2;

ux = -alpha/2.*X + ...
      gamma/(2*pi).*(1-exp(-R./((4*nu)/alpha))) .* (1./R) .* -Y; 
uy = -alpha/2.*Y + ...
      gamma/(2*pi).*(1-exp(-R./((4*nu)/alpha))) .* (1./R) .* X; 
uz = alpha .* Z;

fig_handle = figure('Name', 'nflows-abcflow');
unorm = sqrt(ux.^2 + uy.^2 + uz.^2);
hcone = coneplot(X, Y, Z, ux, uy, uz, X, Y, Z, unorm);
set(hcone,'EdgeColor','none');
camlight right
lighting gouraud

hcone.DiffuseStrength = 0.8;

end % function generate_burgesvortex_3d_structured()
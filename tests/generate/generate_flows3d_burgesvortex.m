function [ux, uy, uz] = generate_flows3d_burgesvortex()
% ARGUMENTS:
%            None
% OUTPUT:
%      [ux, uy, uz]  -- orthogonal velocity field components of size [ny, nx, nz] 
% 
% USAGE:
%{
    
%}
% AUTHOR:
% Paula Sanz-Leon June 2019
%
% REFERENCE: 
% https://aip.scitation.org/doi/full/10.1063/1.4893343
% Analytic solutions for three dimensional swirling strength in compressible and incompressible flows
% Eq (12)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

alfa = 0.2;   % strain-rate 
gmma = 0.1;   % circulation
nu = 0.1;      % kinematic viscosity
ro = sqrt(4*nu/alfa); % core radius
omegaz = gmma/(pi*ro^2); % spanwise vorticity


x = linspace(-5, 5, 21);
[X, Y, Z] = meshgrid(x, x, x);
R = X.^2+Y.^2;

ux = -alfa/2.*X + ...
      gmma/(2*pi).*(1-exp(-R./((4*nu)/alfa))) .* (1./R) .* -Y; 
uy = -alfa/2.*Y + ...
      gmma/(2*pi).*(1-exp(-R./((4*nu)/alfa))) .* (1./R) .* X; 
uz = alfa .* Z;

fig_handle = figure('Name', 'nflows-burges');
unorm = sqrt(ux.^2 + uy.^2 + uz.^2);
hcone = coneplot(X, Y, Z, ux, uy, uz, X, Y, Z, unorm);
set(hcone,'EdgeColor','none');
camlight right
lighting gouraud

hcone.DiffuseStrength = 0.8;

end % function generate_flow3d_burgesvortex_grid()
function [ux, uy, uz] = generate_flow3d_embeddedvortex_grid()
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
% https://www.groundai.com/project/vortex-dynamics-in-cerebral-aneurysms/1
% Eq (2)
% A maximum of two fixed points, located at xf1=(−√R,0,0) and xf2=(√R,0,0),

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

A = -5;
B = 0.2;

x = linspace(-5, 5, 21);
[X, Y, Z] = meshgrid(x, x, x);
R = 1;

ux = Y; 
uy = Z; 
G1 = X.^2 - R;
G2 = A.*Y + B.*Z.^2;
uz = G1 + G2;

fig_handle = figure('Name', 'nflows-abcflow');
unorm = sqrt(ux.^2 + uy.^2 + uz.^2);
hcone = coneplot(X, Y, Z, ux, uy, uz, X, Y, Z, unorm);
set(hcone,'EdgeColor','none');
camlight right
lighting gouraud

hcone.DiffuseStrength = 0.8;

end % function generate_embeddedvortex_3d_structured()
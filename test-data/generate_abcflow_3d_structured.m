function [ux, uy, uz] = generate_abcflow_3d_structured()

% Generates Arnold-Beltrami-Childress (ABC) flow
% Arnold-Beltrami-Childress (ABC) flow is an analytically defined velocity ...
%    field which is known toexhibit chaotic trajectories. 
% Cases A=B=1
% C=1; A^2+B^2=1
% The ABC-vector field is periodic of period in x, y and z.

% Author, Paula Sanz-Leon


x = linspace(0, 2*pi,42);
[X, Y, Z] = meshgrid(x, x, x);

A = 1;
B = sqrt(2/3);
C = sqrt(1/3);



%A = 1;
%B = 1; 
%C = 0.5;


ux = A .* sin(Z) + C .* cos(Y);
uy = B .* sin(X) + A .* cos(Z);
uz = C .* sin(Y) + B .* cos(X);


fig_handle = figure('Name', 'nflows-abcflow');
ax = subplot(111, 'Parent', fig_handle);
unorm = sqrt(ux.^2 + uy.^2 + uz.^2);
hcone = coneplot(ax, X, Y, Z, ux, uy, uz, X, Y, Z, unorm);
set(hcone,'EdgeColor','none');
camlight right
lighting gouraud

hcone.DiffuseStrength = 0.8;
end % function generate_abcflow_3d_structured()



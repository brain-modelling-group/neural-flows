function [ux, uy, uz] = generate_flow3d_abc_grid(abc)

if nargin < 1
    A = 1;
    B = sqrt(2/3);
    C = sqrt(1/3);
else
    A = abc(1);
    B = abc(2);
    C = abc(3);
end
    

% Generates Arnold-Beltrami-Childress (ABC) flow
% Arnold-Beltrami-Childress (ABC) flow is an analytically defined velocity ...
%    field which is known toexhibit chaotic trajectories. 
% Cases A=B=1
% C=1; A^2+B^2=1
% The ABC-vector field is periodic of period in x, y and z.

% Author, Paula Sanz-Leon, QIMR 2019

Nx = 42;
x = linspace(0, 2*pi,Nx);

[X, Y, Z] = meshgrid(x, x, x);

ux = A .* sin(Z) + C .* cos(Y);
uy = B .* sin(X) + A .* cos(Z);
uz = C .* sin(Y) + B .* cos(X);

x = linspace(0, 1,Nx);
[X, Y, Z] = meshgrid(x, x, x);

fig_handle = figure('Name', 'nflows-abcflow');
ax = subplot(1,1,1, 'Parent', fig_handle);
unorm = sqrt(ux.^2 + uy.^2 + uz.^2);
hcone = coneplot(ax, X, Y, Z, ux, uy, uz, X, Y, Z, unorm);
set(hcone,'EdgeColor','none');
camlight right
lighting gouraud

xlabel('x')
ylabel('y')
zlabel('z')

hcone.DiffuseStrength = 0.8;
end % function generate_abcflow_3d_structured()



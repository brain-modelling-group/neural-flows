function [ux, uy, uz, X, Y, Z] = generate_flow3d_abc_grid(abc, varargin)
% Generates Arnold-Beltrami-Childress (ABC) 3D flow 
% Arnold-Beltrami-Childress (ABC) flow is an analytically defined velocity ...
% field which is known to exhibit chaotic trajectories. 
% The ABC-vector field is periodic of period in x, y and z.
% Cases: A=B=1; C=1; A^2+B^2=1
%
% ARGUMENTS:
%        abc -- a 1 x 3 vector with the coefficients for the ABC flow.
%       
%
% OUTPUT: 
%       
%        ux -- 3D array with the x component of the vector field
%        uy -- 3D array with the y component of the vector field
%        uz -- 3D array with the z component of the vector field
%        X, Y, Z -- 3D arrays with the grid of the space where fields are defined 
%
% REQUIRES: 
%      bluegred()
% USAGE:
%{
    
%}
% AUTHOR: Paula Sanz-Leon, QIMR August 2019 

if nargin < 1
    A = 1;
    B = sqrt(2/3);
    C = sqrt(1/3);
    visual_debugging = false;
else
    A = abc(1);
    B = abc(2);
    C = abc(3);
end

if nargin > 1
    visual_debugging = varargin{1}; 
end

% Author, Paula Sanz-Leon, QIMR 2019

Nx = 32;
x = linspace(0, 2*pi, Nx);

[X, Y, Z] = meshgrid(x, x, x);

ux = A .* sin(Z) + C .* cos(Y);
uy = B .* sin(X) + A .* cos(Z);
uz = C .* sin(Y) + B .* cos(X);

x = linspace(0, 1, Nx);
[X, Y, Z] = meshgrid(x, x, x);

if visual_debugging
    fig_handle = figure('Name', 'nflows-abcflow');

    for kk=1:4
        ax(kk) = subplot(2, 2, kk, 'Parent', fig_handle);
        ax(kk).XLabel.String = 'x';
        ax(kk).YLabel.String = 'y';
        ax(kk).ZLabel.String = 'z';
        ax(kk).View = [-37.5 30];
    end

    % Norm
    unorm = sqrt(ux.^2 + uy.^2 + uz.^2);

    hcone = coneplot(ax(1), X, Y, Z, ux, uy, uz, X, Y, Z, unorm);
    camlight right
    lighting gouraud
    hcone_ux = coneplot(ax(2), X, Y, Z, ux, uy, uz, X, Y, Z, ux);
    ax(2).Colormap = bluegred(256);
    ax(2).CLim = [-1.5 1.5];


    camlight right
    lighting gouraud
    hcone_uy = coneplot(ax(3), X, Y, Z, ux, uy, uz, X, Y, Z, uy);
    ax(3).Colormap = bluegred(256);
    ax(3).CLim = [-1.5 1.5];
    camlight right
    lighting gouraud

    hcone_uz = coneplot(ax(4), X, Y, Z, ux, uy, uz, X, Y, Z, uz);
    ax(4).Colormap = bluegred(256);
    ax(4).CLim = [-1.5 1.5];
    camlight right
    lighting gouraud

    set(hcone,'EdgeColor','none');
    set(hcone_ux,'EdgeColor','none');
    set(hcone_uy,'EdgeColor','none');
    set(hcone_uz,'EdgeColor','none');


    hcone.DiffuseStrength = 0.8;
    hcone_ux.DiffuseStrength = 0.8;
    hcone_uy.DiffuseStrength = 0.8;
    hcone_uz.DiffuseStrength = 0.8;

end
end % function generate_abcflow_3d_grid()

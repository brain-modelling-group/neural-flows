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
% REFERENCES:
% Didov, Ulysky (2018) Analysis of stationary points and their bifurcations in the ABC flow

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

tmp = strcmpi(varargin,'visual_debugging'); 
if any(tmp)
    plot_stuff = varargin{find(tmp)+1}; 
else
    plot_stuff = true;
end

tmp = strcmpi(varargin,'x'); 
if any(tmp)
    x = varargin{find(tmp)+1}; 
else
    Nx = 43;
    x = linspace(-pi, pi, Nx);
    x(end) = [];
end

tmp = strcmpi(varargin,'y'); 
if any(tmp)
    y = varargin{find(tmp)+1}; 
else
    Ny = 43;
    y = linspace(-pi, pi, Ny);
    y(end) = [];
end

tmp = strcmpi(varargin,'z'); 
if any(tmp)
    z = varargin{find(tmp)+1}; 
else
    Nz = 43;
    z = linspace(-pi, pi, Nz);
    z(end) = [];
end


ux = A .* sin(z) + C .* cos(y);
uy = B .* sin(x) + A .* cos(z);
uz = C .* sin(y) + B .* cos(x);


if plot_stuff
    fig_handle = figure('Name', 'nflows-abcflow');
    plot3d_flow_frame(fig_handle, ux, uy, uz, x, y, z)  
end
end % function generate_abcflow_3d_grid()

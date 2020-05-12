function [ux, uy, uz] = generate_flow3d_abc_unsteady(abc, varargin)
% Generates time-dependent (unsteady) Arnold-Beltrami-Childress (ABC) 3D flow 
%
% ARGUMENTS:
%        abc -- a 2d array of size [tpts x 3] with the coefficients for the ABC flow.
%       
%
% OUTPUT: 
%       [ux, uy, uz] -- 4D arrays of size [ny, nx, nz, nt] or 2D arrays of size [nt, npoints]
%
% REQUIRES: 
%          generate_flow3d_abc()
%
% USAGE:
%{
tmax = 128;
a  = ones(tmax, 1);
b2 = linspace(0.5, 1, tmax).';
c2 = 1 - b2;
b = sqrt(b2);
c = sqrt(c2);
abc = horzcat(a, b, c);

[ux, uy, uz] = generate_flow3d_abc_unsteady(abc, 'visual_debugging', false);

    
%}
% AUTHOR: Paula Sanz-Leon, QIMR August 2019 
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

tmp = strcmpi(varargin,'grid_type'); 
if any(tmp)
    grid_type = varargin{find(tmp)+1}; 
else
    grid_type = 'structured';
end


max_t = size(abc, 1);
 for tt=1:max_t-1
     [ux, uy, uz, ~, ~, ~] = generate_flow3d_abc_grid(abc(tt, :), 'visual_debugging', plot_stuff);
     ux(:, :, :, tt) =  ux;
     uy(:, :, :, tt) =  uy;
     uz(:, :, :, tt) =  uz;
 end
 [ux, uy, uz, X, Y, Z] = generate_flow3d_abc_grid(abc(max_t, :), 'visual_debugging', plot_stuff]);
 mstruct_vel.ux(:, :, :, max_t) =  ux;
 mstruct_vel.uy(:, :, :, max_t) =  uy;
 mstruct_vel.uz(:, :, :, max_t) =  uz;
 
 options.flow_calculation.grid_size = size(X);
  
 mstruct_vel.options = options;
 mstruct_vel.hx = Y(2)-Y(1);
 mstruct_vel.hy = Y(2)-Y(1);
 mstruct_vel.hz = Y(2)-Y(1);
 mstruct_vel.X =  X;
 mstruct_vel.Y =  Y;
 mstruct_vel.Z =  Z;


function [ux, uy, uz] = get_flow_structured(abc, max_t)
	for tt=1:max_t-1
         [ux, uy, uz, ~, ~, ~] = generate_flow3d_abc_grid(abc(tt, :), 'visual_debugging', plot_stuff);
         ux(:, :, :, tt) =  ux;
         uy(:, :, :, tt) =  uy;
         uz(:, :, :, tt) =  uz;
     end
end

function [ux, uy, uz] = get_flow_unstructured()
	for tt=1:max_t-1
         [ux, uy, uz] = generate_flow3d_abc_grid(abc(tt, :), 'visual_debugging', plot_stuff);
         ux(tt, :) =  ux;
         uy(tt, :) =  uy;
         uz(tt, :) =  uz;
     end
end

end % generate_flow3d_abc_unsteady()

function [ux, uy, uz] = generate_flows3d_abc_unsteady(abc_vec, varargin)
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


max_t = size(abc_vec, 1);

switch grid_type
    case {'structured', 'grid', 'voxel'}
        [xx, yy, zz] = meshgrid(x, y, z);
        ux = zeros(size(xx, 1), size(xx, 2), size(xx, 3), max_t);
        uy = ux;
        uz = uy;
        for tt=1:max_t-1
            abc = abc_vec(tt, :);
            [uxo, uyo, uzo] = generate_flows3d_abc(abc,'x', xx, ...
                                                       'y', yy, ...
                                                       'z', zz, ...
                                                       'visual_debugging', plot_stuff);
            ux(:, :, :, tt) =  uxo;
            uy(:, :, :, tt) =  uyo;
            uz(:, :, :, tt) =  uzo;
        end

    case {'unstructured', 'scattered', 'points', 'nodal'}
        xx = x;
        yy = y;
        zz = z;
        ux = zeros(size(xx, 1), max_t);
        uy = ux;
        uz = uy;
        for tt=1:max_t-1
            abc = abc_vec(tt, :);
            [uxo, uyo, uzo] = generate_flows3d_abc(abc,'x', xx, ...
                                                       'y', yy, ...
                                                       'z', zz, ...
                                                       'visual_debugging', plot_stuff);
            ux(:, tt) =  uxo;
            uy(:, tt) =  uyo;
            uz(:, tt) =  uzo;
        end
    otherwise
        error(['neural-flows:' mfilename ':UnknownCase'], ...
               'Requested unknown grid type. Options: {"structured", "unstructured"}');
end

end % generate_flow3d_abc_unsteady()

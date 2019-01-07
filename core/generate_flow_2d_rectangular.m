function V = generate_flow_2d_rectangular(centroids, rotating_centres, node_centres, displacement, grid_size)
%% Generate a velocity vector field correspoding to a sink, source
%  or vortex/spiral - rotational component
%
%
% ARGUMENTS:
%          centroids -- a [2 x num_sing] vector with the (x, y) coordinates of the
%          singularities centroids.
%    
%
% REQUIRES:
%     
%
% OUTPUT:
%
% AUTHOR:
%    Paula Sanz-Leon 
%
% USAGE:
%{
    
% For only one rotating singularity
centroid = [0.5; 0.5];
rotating_centre = [1];
node_centre     = [0];


centroids = [[0.1; 0.1], [0.3; 0.3], [0.2; 0.8], [0.5; 0.5]];
c = [0, 0, 0; 0 0 0];

V = generate_flow_2d_rectangular(centroid, rotating_centre, node_centre);
[h, hs] = plot_velocity_fields(V)

Vn = perform_vf_normalization(V);
plot_vf(Vn);


%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%   V = compute_flow(p, r, s, c, n);
%
% Generate a flow, using the equation
%           [ node  -rotating ]     d
%   v(x) =  [                 ] * ----- + displacement  with d = x-p
%           [ rotating   node ]    |d|
%
% If node_centre > 0 source 
%    node_centre < 0 sink 
% If rotating_centre > 0 (resp. <0) then there is a clockwise (spiral) 
%    rotating_centre < 0 there is an aticlockwise rotation (spiral)
%   vortex at location p.
%
% IMPORTANT : The grid is assumed to be in the square with corners [0,0] [0, 1] [1, 0] [1, 1].
%   The resulting flow is of size (n,n), regularly sampled
%   in [0,1].
%
% If p is a (2, k) vector, then the resulting flow field is 
%   the sum of the 'k' fields with the basic singularities.
%   (and then 'r', 's' and 'c' should be length-k vectors).
%
% Original - Copyright (c) 2005 Gabriel Peyre


if nargin < 5
    grid_size = 64;
end

if size(centroids,1) ~= 2
    centroids = centroids.';
end

if size(centroids,1)~=2
    error('Centroids should be a vector of size (2, num_sing)');
end

% number of singularities
num_sing = size(centroids, 2);

% x, y displacement of each singularity -- assume it is
if nargin < 4 
    displacement = zeros(2, num_sing);
end

% Same displacement for every singularity
if length(displacement) == 1
   displacement = displacement*ones(2, num_sing);
end

% Check size of displacement
if size(displacement,1) ~= 2
    displacement = displacement.';
end

% Check again
if size(displacement,1)~=2
    error('Displacement should be a vector of size (2, num_sing)');
end

if length(node_centres, 2) ~= num_sing || length(rotating_centres)~=num_sing
    error('rotating_centres/node_centres should be of length num_sing.');
end

% 
if num_sing > 1
    V = zeros(grid_size, grid_size, 2);
    for this_singularity = 1:size(centroids, 2)
        V = V + generate_flow_2d_rectangular(centroids(:,this_singularity), ...
                                             rotating_centres(this_singularity), ...
                                             node_centres(this_singularity), ...
                                             displacement(:,this_singularity), grid_size);
    end
    return;
end

x = 0:1/(grid_size-1):1;

[Y,X] = meshgrid(x, x);

% Centre
X1 = X - centroids(1);
Y1 = Y - centroids(2);

% Disk
D = X1.^2 + Y1.^2;

% Radidus from the centre
D(D < eps) = 1;

% Normalize grid points
X1 = X1./D;
Y1 = Y1./D;

% Preallocate memory for the velocity field components Vx and Vy
V = zeros(grid_size, grid_size, 2);
V(:,:,1) = node_centres*X1     - rotating_centres*Y1 + displacement(1);
V(:,:,2) = rotating_centres*X1 + node_centres*Y1     + displacement(2);


function [barycenter] = get_triangle_barycenter(vx0, vx1, vx2)
% Calculates the barycenter of a triangle, given the vertex coordinates 
% ARGUMENTS:
%    vx0 -- coordinate of first vertex. A vector of [1 x 3] or [3 x 1]
%    vx1 -- coordinate of second vertex. A vector of [1 x 3] or [3 x 1]
%    vx2 -- coordinate of third vertex. A vector of [1 x 3] or [3 x 1]
%
% OUTPUT:
%    barycenter -- the coordinates of the barycentre
%
% REQUIRES:
%          None
%
% AUTHOR:
%     Paula Sanz-Leon (2019-02-09).
%
% USAGE:
%{
    
%}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Pa = vx0(:); 
Pb = vx1(:); 
Pc = vx2(:); 

L1 = (Pb + Pc)/2 -Pa; 
L2 = (Pa + Pc)/2 -Pb; % directrices
P21 = Pb - Pa;      
P1 = Pa;            

ML = [L1 -L2];    % Coefficient Matrix
lambda = ML\P21;  % Solving the linear system
barycenter = P1 + lambda(1)*L1; % Line Equation evaluated at lambda(1)

% end function get_triangle_barycenter()

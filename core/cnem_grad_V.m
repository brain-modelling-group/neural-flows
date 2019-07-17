function nabla_V = grad_cnem(XYZ, V, IN_Tri_Ini)
% Calculates the gradient of V (\nabla V) evaluated at 3-D scattered points in array XYZ
%
% ARGUMENTS:
%          XYZ -- a 2D array of size n x 3 with coodinates of points in 3D space.
%          V   --  the matrix (??) of (???) of size ??? x ????
%          IN_Tri_Ini -- a 2D array of size [num_faces x 3] with the 
%                        triangulation of the boundary that contains
%                        XYZ
%
% OUTPUT: 
%          nabla_V      -- gradient of V
%
% REQUIRES: 
%        CNEM: https://ff-m2p.cnrs.fr/projects/cnem/, which itself depends on 
%        TBB: http://www.threadingbuildingblocks.org/  
%
% USAGE:
%{     

gradV = grad_cnem(XYZ, V);

% or, if we precalculated B, then

gradV = grad_cnem(B, V);



%}
%
% MODIFICATION HISTORY:
%     JA Roberts, QIMR Berghofer, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  gradV = grad_cnem(XYZ,V,[IN_Tri_Ini])
% Gradient \nabla V evaluated at 3-D scattered points in matrix XYZ
%
% Alternatively, can call 
%  gradV = grad_cnem(B,V);
% to use a precalculated B matrix
%
% Uses CNEM.
%
%
% JA Roberts, QIMR Berghofer, 2018

if nargin < 3
    IN_Tri_Ini=[];
end

% Check if we got the locations in 3D space of the matrix Bs
if size(XYZ,2) == 3 % if loc matrix, calculate the B matrix
    B = grad_B_cnem(XYZ,IN_Tri_Ini);
else % already given the B matrix
    B = XYZ;
end

Grad_V = B*V;

Grad_V_mat = reshape(Grad_V,4,[]).';
nabla_V = Grad_V_mat(:,1:3); % 4th column is V

end % funcion grad_cnem()
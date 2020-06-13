function nabla_V = flows3d_cnem_grad_V(B, V)
% Calculates the gradient of V (\nabla V) evaluated at 3-D scattered points in array XYZ
%
% ARGUMENTS:
%          V   --  the matrix (??) of (???) of size ??? x ????
%          B   -- assembled matrix
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

gradV = flows3d_cnem_grad_V(B, V);

%}
%
% MODIFICATION HISTORY:
%     JA Roberts, QIMR Berghofer, 2018
%     Updated, documented by Paula Sanz-Leon -- QIMR 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% gradV = grad_cnem(XYZ,V,[IN_Tri_Ini])
% Gradient \nabla V evaluated at 3-D scattered points in matrix XYZ
%
% Alternatively, can call 
% gradV = grad_cnem(B,V);
% to use a precalculated B matrix
%
% Uses CNEM.

% JA Roberts, QIMR Berghofer, 2018

Grad_V = B*V;

Grad_V_mat = reshape(Grad_V,4,[]).';
nabla_V = Grad_V_mat(:,1:3); % 4th column is Gradient Operator

end % funcion cnem_grad_V()

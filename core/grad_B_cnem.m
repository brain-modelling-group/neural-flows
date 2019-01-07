function B = grad_B_cnem(XYZ, IN_Tri_Ini)
%% Calculate the matrix B for calculating the gradient \nabla V evaluated at
% 3-D scattered points in matrix XYZ
%
% ARGUMENTS:
%          XYZ -- a 2D array of size n x 3 with coodinates of points in 3D space.
%          sIN_Tri_Ini -- is the triangulation of the boundary nodes (????)
%
% OUTPUT: 
%      B       -- Matrix B of size ??? x ??? 
%
% REQUIRES: 
%        CNEM: https://ff-m2p.cnrs.fr/projects/cnem/, which itself depends on 
%        TBB: http://www.threadingbuildingblocks.org/  
%        cal_B_Mat()
%
% USAGE:
%{     
% Grad_V=B*V; Grad_V_mat=reshape(Grad_V,4,[])';



%}
%
% MODIFICATION HISTORY:
%     JA Roberts, QIMR Berghofer, 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2
    IN_Tri_Ini=[];
end

Sup_NN_GS = 0;
Type_FF   = 0;% 0 -> Sibson, 1 -> Laplace, 2 -> Linear fem

[GS,XYZ,IN_Tri_Ini,IN_Tri,IN_Tet,INV_NN,PNV_NN,IN_New_Old,IN_Old_New] = m_cnem3d_scni(XYZ, ...
	                                                                    IN_Tri_Ini, Type_FF, Sup_NN_GS);

nb_var = 1;

B = cal_B_Mat(GS, nb_var);

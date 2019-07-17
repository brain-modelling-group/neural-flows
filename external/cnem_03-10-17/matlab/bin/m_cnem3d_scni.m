% This file is part of CNEMLIB.
% 
% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France
% 
% CNEMLIB is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% CNEMLIB is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
%
% Please report bugs to illoul_lounes@yahoo.fr 

% PSL-REQUIRES -- mex-compiled function cnem3d()

function [GS,XYZ_Noeud_New,IN_Tri_Ini_New,IN_Tri,IN_Tet,INV_NN,PNV_NN,IN_New_Old,IN_Old_New]=...
m_cnem3d_scni(XYZ_Noeud,IN_Tri_Ini,Type_FF,Sup_NN_GS)

Type_Call_Tet=1;

a=sparse(1,1);
s=whos('a');
if s.bytes==20 %32bit
   IN_Tri_Ini=uint32(IN_Tri_Ini-1);
else %64bit
   IN_Tri_Ini=uint64(IN_Tri_Ini-1);
end
    
[IN_New_Old,IN_Old_New,XYZ_New_Noeud,INV_NN,PNV_NN,Vol_C,Nb_V,Ind_V,Grad,IN_Tri,IN_Tet]=...
cnem3d(0,XYZ_Noeud',IN_Tri_Ini',Type_Call_Tet,Type_FF,Sup_NN_GS);

IN_New_Old=double(IN_New_Old)';
IN_Old_New=double(IN_Old_New)';
IN_Tri=double(IN_Tri)'+1;
IN_Tet=double(IN_Tet)'+1;
IN_Tri_Ini=double(IN_Tri_Ini)+1;

XYZ_Noeud_New=[XYZ_Noeud(IN_Old_New,:);XYZ_New_Noeud'];
IN_Tri_Ini_New=IN_New_Old(IN_Tri_Ini);

GS.Vol_C=Vol_C;
GS.Nb_V=double(Nb_V);
GS.Ind_V=double(Ind_V);
GS.Grad=Grad;


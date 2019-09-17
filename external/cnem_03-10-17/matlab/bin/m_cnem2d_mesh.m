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

function [XY_Noeud_New,IN_Front_New,IN_Tri,IN_New_Old,IN_Old_New]=...
    m_cnem2d_mesh(XY_Noeud,Nb_Noeud_Front,IN_Front)

a=sparse(1,1);s=whos('a');
if s.bytes==20 %32bit
    Nb_Noeud_Front=uint32(Nb_Noeud_Front);
    IN_Front=uint32(IN_Front-1);
else %64bit
    Nb_Noeud_Front=uint64(Nb_Noeud_Front);
    IN_Front=uint64(IN_Front-1);
end
   
[IN_New_Old,IN_Old_New,IN_Tri]=cnem2d(2,XY_Noeud',Nb_Noeud_Front',IN_Front');

IN_New_Old=double(IN_New_Old)';
IN_Old_New=double(IN_Old_New)';
IN_Tri=double(IN_Tri)'+1;
IN_Front=double(IN_Front)+1;

XY_Noeud_New=XY_Noeud(IN_Old_New,:);
IN_Front_New=IN_New_Old(IN_Front);


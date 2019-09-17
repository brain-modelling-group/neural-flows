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

function [GS,XY_Noeud_New,IN_Front_New,IN_Tri,IN_New_Old,IN_Old_New,Cel]=...
    m_cnem2d_scni_axi(XY_Noeud,Nb_Noeud_Front,IN_Front)

Out_Cel_Vc=1;
Int_CdM=1;

a=sparse(1,1);s=whos('a');
if s.bytes==20 %32bit
    Nb_Noeud_Front=uint32(Nb_Noeud_Front);
    IN_Front=uint32(IN_Front-1);
    Int_CdM=uint32(Int_CdM);
    Out_Cel_Vc=uint32(Out_Cel_Vc);
else %64bit
    Nb_Noeud_Front=uint64(Nb_Noeud_Front);
    IN_Front=uint64(IN_Front-1);
    Int_CdM=uint64(Int_CdM);
    Out_Cel_Vc=uint64(Out_Cel_Vc);
end

if Int_CdM 
    [IN_New_Old,IN_Old_New,Vol_C,XY_CdM,Nb_V,Ind_V,Grad,IN_Tri,Nb_V_Int,Ind_V_Int,FF_Int,Ind_Noeud_Cel,Nb_S_Cel,S_Cel]...
        =cnem2d(0,XY_Noeud',Nb_Noeud_Front',IN_Front',Out_Cel_Vc,Int_CdM);
    assert(min(Nb_V_Int)~=0)
else
    [IN_New_Old,IN_Old_New,Vol_C,XY_CdM,Nb_V,Ind_V,Grad,IN_Tri,Ind_Noeud_Cel,Nb_S_Cel,S_Cel]...
        =cnem2d(0,XY_Noeud',Nb_Noeud_Front',IN_Front',Out_Cel_Vc,Int_CdM);
    n=size(IN_Old_New,2);
    Nb_V_Int=ones(1,n);
    Ind_V_Int=(0:n-1);
    FF_Int=ones(1,n);
end

IN_New_Old=double(IN_New_Old)';
IN_Old_New=double(IN_Old_New)';
IN_Tri=double(IN_Tri)'+1;
IN_Front=double(IN_Front)+1;

XY_Noeud_New=XY_Noeud(IN_Old_New,:);
IN_Front_New=IN_New_Old(IN_Front);

Ind_Noeud_Cel=double(Ind_Noeud_Cel)'+1;
Nb_S_Cel=double(Nb_S_Cel)';
S_Cel=S_Cel';

r=XY_CdM(1,:);
Vol_C=Vol_C*2.*pi.*r;

GS.Vol_C=Vol_C;
GS.Nb_V=double(Nb_V);
GS.Ind_V=double(Ind_V);
GS.Grad=Grad;
GS.Nb_V_Int=double(Nb_V_Int);
GS.Ind_V_Int=double(Ind_V_Int);
GS.FF_Int=FF_Int;
GS.r=r;

Cel.Ind_Noeud_Cel=Ind_Noeud_Cel;
Cel.Nb_S_Cel=Nb_S_Cel;
Cel.S_Cel=S_Cel;


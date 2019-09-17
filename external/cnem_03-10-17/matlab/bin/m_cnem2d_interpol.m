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

classdef m_cnem2d_interpol
    properties
        In_Out
        Mat_INT
    end
    methods
        function obj=m_cnem2d_interpol(XY_Noeud,Nb_Noeud_Front,IN_Front,XY_PntInt)
            a=sparse(1,1);s=whos('a');
            if s.bytes==20 %32bit
                Nb_Noeud_Front=uint32(Nb_Noeud_Front);
                IN_Front=uint32(IN_Front-1);
            else %64bit
                Nb_Noeud_Front=uint64(Nb_Noeud_Front);
                IN_Front=uint64(IN_Front-1);
            end

            [IN_New_Old,IN_Old_New,Nb_V,Ind_V,FF]=...
            cnem2d(1,XY_Noeud',Nb_Noeud_Front',IN_Front',XY_PntInt');

            IN_New_Old=double(IN_New_Old)';
            IN_Old_New=double(IN_Old_New)';
            Nb_V=double(Nb_V)';
            Ind_V=double(Ind_V)'+1;
            IN_Front=double(IN_Front)+1;

            for i=1:size(Ind_V,1)
                Ind_V(i)=IN_Old_New(Ind_V(i));
            end

            i_Point=zeros(1,size(Ind_V,1));
            k=1;
            for i=1:size(Nb_V,1)
                for j=1:Nb_V(i)
                    i_Point(k)=i;
                    k=k+1;
                end
            end

            obj.Mat_INT=sparse(i_Point',Ind_V,FF',size(XY_PntInt,1),size(XY_Noeud,1));
            obj.In_Out=logical(Nb_V);
        end
        
        function Var_Int=interpolate(obj,Var)
            Var_Int=obj.Mat_INT*Var;
        end
    end
end


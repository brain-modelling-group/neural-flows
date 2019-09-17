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

classdef m_cnem3d_interpol
    properties
        In_Out
        Mat_INT
        Mat_INT_NN
    end
    methods
        function obj=m_cnem3d_interpol(XYZ_Noeud,IN_Tri_Ini,XYZ_Point,Type_FF)

            Type_Call_Tet=1;
            nb_noeud_ini=size(XYZ_Noeud,1);

            if size(IN_Tri_Ini,1)~=0
                fid=fopen('bbox_03','r');
                nb_node_bbox=fread(fid,1,'uint32');
                nb_tri_bbox=double(fread(fid,1,'uint32'));
                xyz_node_bbox=fread(fid,nb_node_bbox*3,'float32');
                in_tri_bbox=fread(fid,nb_tri_bbox*3,'uint32');
                fclose(fid);
                xyz_node_bbox=reshape(xyz_node_bbox,3,nb_node_bbox)';
                in_tri_bbox=reshape(in_tri_bbox,3,nb_tri_bbox)'+1;

                max_XYZ_Noeud=max(XYZ_Noeud,[],1);
                min_XYZ_Noeud=min(XYZ_Noeud,[],1);
                O_dbox=(max_XYZ_Noeud+min_XYZ_Noeud)/2;
                L_dbox=max(max_XYZ_Noeud-min_XYZ_Noeud);
                R_dbox=sqrt(3)*L_dbox/2.;
                coef=1.5;

                xyz_node_bbox=xyz_node_bbox*(coef*R_dbox)+repmat(O_dbox,size(xyz_node_bbox,1),1);
                IN_Tri_Ini=[IN_Tri_Ini;in_tri_bbox+size(XYZ_Noeud,1)];
                XYZ_Noeud=[XYZ_Noeud;xyz_node_bbox];
            end

            a=sparse(1,1);s=whos('a');
            if s.bytes==20 %32bit
               IN_Tri_Ini=uint32(IN_Tri_Ini-1);
            else %64bit
               IN_Tri_Ini=uint64(IN_Tri_Ini-1);
            end

            [IN_New_Old,IN_Old_New,INV_NN,PNV_NN,Ind_Point,Nb_V,Ind_V,FF]=...
            cnem3d(1,XYZ_Noeud',IN_Tri_Ini',XYZ_Point',Type_Call_Tet,Type_FF);

            IN_New_Old=double(IN_New_Old)';
            IN_Old_New=double(IN_Old_New)';
            INV_NN=double(INV_NN)'+1;
            PNV_NN=PNV_NN';
            Ind_Point=double(Ind_Point)'+1;
            Nb_V=double(Nb_V)';
            Ind_V=double(Ind_V)'+1;

            nb_noeud_ini_new=size(IN_Old_New,1);

            new_ind_new_noeud=zeros(size(INV_NN,1),1);
            nb_new_noeud=size(INV_NN,1);
            INV_NN_new=zeros(nb_new_noeud,3);
            PNV_NN_new=zeros(nb_new_noeud,3);
            I=0;
            for i=1:size(Ind_V,1)
                if Ind_V(i)<=nb_noeud_ini_new
                    Ind_V(i)=IN_Old_New(Ind_V(i));
                else
                    j=Ind_V(i)-nb_noeud_ini_new;
                    if new_ind_new_noeud(j)==0
                        I=I+1;
                        new_ind_new_noeud(j)=nb_noeud_ini+I;
                        INV_NN_new(I,:)=IN_Old_New(INV_NN(j,:))';
                        PNV_NN_new(I,:)=PNV_NN(j,:);
                    end
                    Ind_V(i)=new_ind_new_noeud(j);
                end
            end
            INV_NN=INV_NN_new(1:I,:);
            PNV_NN=PNV_NN_new(1:I,:);

            INT_NN=[];
            if I~=0
                i_NN=reshape(repmat(1:I,3,1),3*I,1);
                INV_NN=reshape(INV_NN',3*I,1);
                PNV_NN=reshape(PNV_NN',3*I,1);
                INT_NN=sparse(i_NN,INV_NN,PNV_NN,I,nb_noeud_ini);
            end

            Inv_Ind_Point=(1:size(Ind_Point,1));
            Inv_Ind_Point(Ind_Point)=Inv_Ind_Point;

            i_Point=zeros(1,size(Ind_V,1));
            k=1;
            for i=1:size(Nb_V,1)
                for j=1:Nb_V(i)
                    i_Point(k)=i;
                    k=k+1;
                end
            end

            INT=sparse(i_Point',Ind_V,FF',size(XYZ_Point,1),nb_noeud_ini+I);
            obj.Mat_INT=INT(Inv_Ind_Point,:);

            In_Out=logical(Nb_V);
            In_Out(Ind_Point)=In_Out;
            obj.In_Out=In_Out;
            
            obj.Mat_INT_NN=INT_NN;
        end
        
        function Var_Int=interpolate(obj,Var)
            Var_Add_Node=[];
            if size(obj.Mat_INT_NN,1)~=0
                Var_Add_Node=obj.Mat_INT_NN*Var;
            end 
            Var_Int=obj.Mat_INT*[Var;Var_Add_Node];
        end
        
        function Mat=mat_interpol_glob(obj)
            if size(obj.Mat_INT_NN,1)~=0
                n=size(obj.Mat_INT_NN,2);
                m=size(obj.Mat_INT,2);
                Mat=obj.Mat_INT(:,1:n)+obj.Mat_INT(:,n+1:m)*obj.Mat_INT_NN;
            else
                Mat=obj.Mat_INT;
            end
        end
    end
end
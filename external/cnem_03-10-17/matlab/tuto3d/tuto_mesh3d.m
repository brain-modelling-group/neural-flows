% illoul_lounes@yahoo.fr
% ENSAM Paris

clear all;
close all; 
clc;

addpath('../bin');

%% load domain (nodes + boundary(s)) and  draw boundary(s) 

load('data_mesh'); 

figure;
hold on
tri_out_handle=trimesh(IN_Tri_Ini,XYZ_Noeud(:,1),XYZ_Noeud(:,2),XYZ_Noeud(:,3),'edgecolor','black');
alpha(tri_out_handle,0.5);
plot3(XYZ_Noeud(:,1),XYZ_Noeud(:,2),XYZ_Noeud(:,3),'.','color','red');
axis vis3d
axis equal
hold off

%% mesh

[XYZ_Noeud,IN_Tri_Ini,IN_Tri,IN_Tet,IN_New_Old,IN_Old_New]=...
    m_cnem3d_mesh(XYZ_Noeud,IN_Tri_Ini);

%% plot

centre=[0,0,0];
r_int=0.5;
n=[0,0,1];

id_tet_util=[];

for i=1:size(IN_Tet,1)
    tet_i=IN_Tet(i,:);
    geoc=(XYZ_Noeud(tet_i(1),:)+...
          XYZ_Noeud(tet_i(2),:)+...
          XYZ_Noeud(tet_i(3),:)+...
          XYZ_Noeud(tet_i(4),:))/4;
     
    vec_r=geoc-centre;
    r=norm(vec_r-(vec_r*n')*n,2);
    if r > r_int
        id_tet_util=[id_tet_util;i];
    end
      
end

figure;
hold on
tri_out_handle=trimesh(IN_Tri,XYZ_Noeud(:,1),XYZ_Noeud(:,2),XYZ_Noeud(:,3),'edgecolor','black');
tet_out_handle=tetramesh(IN_Tet(id_tet_util,:),XYZ_Noeud,'edgecolor','black');
alpha(tri_out_handle,0.5);
alpha(tet_out_handle,0.5);
plot3(XYZ_Noeud(:,1),XYZ_Noeud(:,2),XYZ_Noeud(:,3),'.','color','red');
axis vis3d
axis equal
hold off

% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

clc
clear all;
close all; 
clc;
addpath('../bin');

%% load domain (nodes + boundary(s)) and  draw boundary(s) 

load('data_small');% the domain : nodes + bounary(s) 

% plot 
% boundarys

figure;
hold on;
axis equal;

plot_boundary(XY_Node,Nb_Node_Front,Ind_Node_Front);

% node

plot(XY_Node(:,1),XY_Node(:,2),'.','color','green');

hold off;

%% constrained Delaunay mesh

[XY_Node,Ind_Node_Front,Ind_Node_Tri,Ind_Node_New_Old,Ind_Node_Old_New]=...
m_cnem2d_mesh(XY_Node,Nb_Node_Front,Ind_Node_Front);

figure
hold on;
axis equal;
trimesh(Ind_Node_Tri,XY_Node(:,1),XY_Node(:,2),'color','red');
hold off;

%%
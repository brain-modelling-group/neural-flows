% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

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

%% SCNI integration

[GS,XY_Node,Ind_Node_Front,Ind_Node_Tri,Ind_Node_New_Old,Ind_Node_Old_New,Cel]=...
m_cnem2d_scni(XY_Node,Nb_Node_Front,Ind_Node_Front);

%% mechanical problem : 

%% Assembling

n=size(XY_Node,1);

E_NU=[200e9,0.266];

% e_nu_left=[200e9,0.266];
% e_nu_right=[20e9,0.266];
% 
% E_NU=zeros(n,2);
% for i=1:n
%     if XY_Node(i,1)<0.5
%         E_NU(i,:)=e_nu_left;
%     else
%         E_NU(i,:)=e_nu_right;
%     end
% end

[B,C,V]= m_assembling_meca(GS,E_NU);
K_Mat_meca=B'*V*C*B;

%% boundary condition definition

V_bh=0.; % Y displacement at x==0. and x==1.
U_b=0.; % X Displacement at x==0.;
U_h=1.; % X displacement at x==1.;
%

UV=zeros(2*n,1);
DDL_bloc=[];

for i=1:size(Ind_Node_Front,1)
    if abs(XY_Node(Ind_Node_Front(i),2))<1.e-6
       DDL=2*(Ind_Node_Front(i)-1)+0+1;
       DDL_bloc=[DDL_bloc,DDL];
       UV(DDL)=U_b;
       DDL=2*(Ind_Node_Front(i)-1)+1+1;
       DDL_bloc=[DDL_bloc,DDL];
       UV(DDL)=V_bh;
    end
    
    if abs(XY_Node(Ind_Node_Front(i),2)-1.)<1.e-6
       DDL=2*(Ind_Node_Front(i)-1)+0+1;
       DDL_bloc=[DDL_bloc,DDL];
       UV(DDL)=U_h;
       DDL=2*(Ind_Node_Front(i)-1)+1+1;
       DDL_bloc=[DDL_bloc,DDL];
       UV(DDL)=V_bh;
    end
end 

DDL_bloc=unique(DDL_bloc);

DDL_Tot=1:2*n;
DDL_Libre=setdiff(DDL_Tot,DDL_bloc);

%% solve problem

Vec_B=-K_Mat_meca(:,DDL_bloc)*UV(DDL_bloc);
UV(DDL_Libre)=K_Mat_meca(DDL_Libre,DDL_Libre)\Vec_B(DDL_Libre);
%UV(DDL_Libre)=gmres(K_Mat_meca(DDL_Libre,DDL_Libre),B(DDL_Libre),[],1.e-6,100);

%% post

Strain=B*UV;
Stress=C*Strain;

%% Plot result

% Displacement

h=figure;
set(h,'Name','Displacement');
hold on;
axis equal;
XY_Node_dep=XY_Node+0.2*reshape(UV,2,[])';
plot(XY_Node_dep(:,1),XY_Node_dep(:,2),'r.');
hold off;

h=figure;
set(h,'Name','X Displacement ');
hold on;
axis equal;
plot_cel_vc(Cel,UV(1:2:size(UV,1)));
hold off;

h=figure;
set(h,'Name','Y Displacement');
hold on;
axis equal;
plot_cel_vc(Cel,UV(2:2:size(UV,1)));
hold off;

% Stress

h=figure;
set(h,'Name','XX Stress');
hold on;
axis equal;
plot_cel_vc(Cel,Stress(1:3:size(Stress,1)));
hold off;

h=figure;
set(h,'Name','YY Stress');
hold on;
axis equal;
plot_cel_vc(Cel,Stress(2:3:size(Stress,1)));
hold off;

h=figure;
set(h,'Name','XY Stress');
hold on;
axis equal;
plot_cel_vc(Cel,Stress(3:3:size(Stress,1)));
hold off;

%%















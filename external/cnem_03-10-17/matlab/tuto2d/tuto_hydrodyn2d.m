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

%% SCNI integration

[GS,XY_Node,Ind_Node_Front,Ind_Node_Tri,Ind_Node_New_Old,Ind_Node_Old_New,Cel]=...
m_cnem2d_scni(XY_Node,Nb_Node_Front,Ind_Node_Front);

%% hydrodynamic problem : 

%% Assembling

n=size(XY_Node,1);

NU=1.*ones(n,1);% NU=1. work also !
[B,C,V]= m_assembling_hydrodyn(GS,NU);
K_Mat_HD=B'*V*C*B;

%% boundary condition definition

U_Inf=1.;
V_hb=0.; % y velocity y==0. and y==1. 
U_g=U_Inf; % x velocity at x==0.
V_g=0.; % y velocity at x==0.
U_C=0.; % x velocity at the hole boundary (perfect adherence)
V_C=0.; % y velocity at the hole boundary (perfect adherence)
%

UVP=zeros(3*n,1);
DDL_bloc=[];

for i=1:size(Ind_Node_Front,1)
    
    if  abs(XY_Node(Ind_Node_Front(i),1)-0.)<1.e-6
        DDL=3*(Ind_Node_Front(i)-1)+0+1;
        DDL_bloc=[DDL_bloc,DDL];
        UVP(DDL)=U_g;
        DDL=3*(Ind_Node_Front(i)-1)+1+1;
        DDL_bloc=[DDL_bloc,DDL];
        UVP(DDL)=V_g;
    end
        
    if  abs(XY_Node(Ind_Node_Front(i),2))<1.e-6
        DDL=3*(Ind_Node_Front(i)-1)+1+1;
        DDL_bloc=[DDL_bloc,DDL];
        UVP(DDL)=V_hb;
    end
    
    if  abs(XY_Node(Ind_Node_Front(i),2)-1)<1.e-6
        DDL=3*(Ind_Node_Front(i)-1)+1+1;
        DDL_bloc=[DDL_bloc,DDL];
        UVP(DDL)=V_hb;
    end
end 

n_C=[];
Ind_C=2;
j=1;

Nb_Front=size(Nb_Node_Front,1);

for i=1:Nb_Front
    if i==2
        n_C=Ind_Node_Front([j:(j+Nb_Node_Front(i)-1),j]);
        break;
    end
    j=j+Nb_Node_Front(i);
end

for i=1:size(n_C,1)
    DDL=3*(n_C(i)-1)+0+1;
    DDL_bloc=[DDL_bloc,DDL];
    UVP(DDL)=U_C;
    DDL=3*(n_C(i)-1)+1+1;
    DDL_bloc=[DDL_bloc,DDL];
    UVP(DDL)=V_C;
end

DDL_bloc=unique(DDL_bloc);

DDL_Tot=1:3*n;
DDL_Libre=setdiff(DDL_Tot,DDL_bloc);

%% solve problem

Vec_B=-K_Mat_HD(:,DDL_bloc)*UVP(DDL_bloc);
UVP(DDL_Libre)=K_Mat_HD(DDL_Libre,DDL_Libre)\Vec_B(DDL_Libre);
%UVP(DDL_Libre)=gmres(Mat_K_HD(DDL_Libre,DDL_Libre),B(DDL_Libre),[],1.e-6,100);

%% Plot result

% Velocity

h=figure;
set(h,'Name','Velocity vector');
hold on;
axis equal;
quiver(XY_Node(:,1),XY_Node(:,2),UVP(1:3:size(UVP,1)),UVP(2:3:size(UVP,1)))
hold off;

h=figure;
set(h,'Name','X Velocity');
hold on;
axis equal;
plot_cel_vc(Cel,UVP(1:3:size(UVP,1)));
hold off;

h=figure;
set(h,'Name','Y Velocity');
hold on;
axis equal;
plot_cel_vc(Cel,UVP(2:3:size(UVP,1)));
hold off;

% Pressure

h=figure;
set(h,'Name','Pressure');
hold on;
axis equal;
plot_cel_vc(Cel,UVP(3:3:size(UVP,1)));
hold off;

%Stream line

% 'compute stream line...'
% 
% h=figure;
% set(h,'Name','streame line');
% hold on;
% axis equal;
% dec=1.e-3;
% x_min=min(XY_Node(:,1))+dec;
% x_max=max(XY_Node(:,1))-dec;
% y_min=min(XY_Node(:,2))+dec;
% y_max=max(XY_Node(:,2))-dec;
% nb_sl=50;
% x0=(x_min)*ones(nb_sl,1);
% y0=y_min+(y_max-y_min)*(0:(nb_sl-1))'/nb_sl;

% xy_stream=TriStream(Ind_Node_Tri,XY_Node(:,1),XY_Node(:,2),UVP(1:3:size(UVP,1)),UVP(2:3:size(UVP,1)),x0,y0);
% for i=1:size(xy_stream,2)
%     plot(xy_stream(i).x,xy_stream(i).y,'r');
% end
%hold off;

%%

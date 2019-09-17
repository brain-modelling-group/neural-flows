% Copyright (C) 2003-2011
% Lounes ILLOUL (illoul_lounes@yahoo.fr)
% Philippe LORONG (philippe.lorong@ensam.eu)
% Arts et Metiers ParisTech, Paris, France

clc;
clear all;
close all;
addpath('../bin');

%% load domain (nodes + boundary(s))

load('data_small'); 

%% creat dummy point location for interpolation evaluation

XY_Point=(rand(1000,2)-0.5)*1.5+0.5;

%% plot 

% boundarys

figure;
hold on;
axis equal;

plot_boundary(XY_Node,Nb_Node_Front,Ind_Node_Front);

% node

plot(XY_Node(:,1),XY_Node(:,2),'.','color','green');

% point

plot(XY_Point(:,1),XY_Point(:,2),'o','color','blue');

hold off;

%% initialize the interpolator

Interpol=m_cnem2d_interpol(XY_Node,Nb_Node_Front,Ind_Node_Front,XY_Point);

%% interpolate a filds
% test : Var = XY_Noeud ==> interpolated Var on XY_Point = XY_Point

Var=XY_Node;
Var_Int=Interpol.interpolate(Var);

%% cal error

dif=Var_Int-XY_Point;
j=0;
ind_p_in=zeros(sum(Interpol.In_Out),1);
for i=1:size(Interpol.In_Out,1)
    if Interpol.In_Out(i)
        j=j+1;
        ind_p_in(j)=i;
    end
end
int_p_out=setdiff(1:size(Interpol.In_Out,1),ind_p_in);

err=max(max(abs(dif(ind_p_in,:))))

%% plot in/out point

% boundarys

figure;
hold on;
axis equal;

j=1;
for i=1:size(Nb_Node_Front,1)
    XY_Node_Front_i=XY_Node(Ind_Node_Front([j:(j+Nb_Node_Front(i)-1)]),:);
    plot(XY_Node_Front_i(:,1),XY_Node_Front_i(:,2),'color','black','LineWidth',2);
    j=j+Nb_Node_Front(i);
end

% in

plot(XY_Point(ind_p_in,1),XY_Point(ind_p_in,2),'*','color','red');

% out

plot(XY_Point(int_p_out,1),XY_Point(int_p_out,2),'+','color','blue');

hold off;

%%
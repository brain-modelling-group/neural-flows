clear all;
clc;

n=400;

fac=1.;
lx=1.*fac;
ly=1.*fac;
h=(1/sqrt(n))*fac;

R=0.1*fac;
xc=0.5*fac;
yc=0.5*fac;

nx=round(lx/h)+1;
ny=round(ly/h)+1;
nc=round(R*2*pi/h);

XY_Node=[];
Ind_Node_Front=[];
Nb_Node_Front=[];
Nb_Node_Front_Temp=0;
I=1;

for i=0:(ny-2)
    x=0;
    y=(ly/(ny-1))*i;
    XY_Node=[XY_Node;[x,y]];
    Ind_Node_Front=[Ind_Node_Front;I];
    I=I+1;
    Nb_Node_Front_Temp=Nb_Node_Front_Temp+1;
end

for i=0:(nx-2)
    x=(lx/(nx-1))*i;
    y=ly;
    XY_Node=[XY_Node;[x,y]];
    Ind_Node_Front=[Ind_Node_Front;I];
    I=I+1;
    Nb_Node_Front_Temp=Nb_Node_Front_Temp+1;
end

for i=0:(ny-2)
    x=lx;
    y=ly-(ly/(ny-1))*i;
    XY_Node=[XY_Node;[x,y]];
    Ind_Node_Front=[Ind_Node_Front;I];
    I=I+1;
    Nb_Node_Front_Temp=Nb_Node_Front_Temp+1;
end

for i=0:(nx-2)
    x=lx-(lx/(nx-1))*i;
    y=0;
    XY_Node=[XY_Node;[x,y]];
    Ind_Node_Front=[Ind_Node_Front;I];
    I=I+1;
    Nb_Node_Front_Temp=Nb_Node_Front_Temp+1;
end

Nb_Node_Front=[Nb_Node_Front;Nb_Node_Front_Temp];
Nb_Node_Front_Temp=0;

% for i=0:(nc-1)
%     x=xc+R*cos((2*pi/nc)*i);
%     y=yc+R*sin((2*pi/nc)*i);
%     XY_Node=[XY_Node;[x,y]];
%     Ind_Node_Front=[Ind_Node_Front;I];
%     I=I+1;
%     Nb_Node_Front_Temp=Nb_Node_Front_Temp+1;
% end
% 
% Nb_Node_Front=[Nb_Node_Front;Nb_Node_Front_Temp];
% Nb_Node_Front_Temp=0;

for i=1:(nx-2)
    for j=1:(ny-2)
        x=((lx/(nx-1))*(i)-lx/2)+lx/2+h*(rand-0.5)*3.e-1;
        y=((ly/(ny-1))*(j)-ly/2)+ly/2+h*(rand-0.5)*3.e-1;
        XY_Node=[XY_Node;[x,y]];
    end
end

% h_x=h;
% h_y=h*sin(pi/3);
% y=h_y;
% i=0;
% while 1  
%     
%     if mod(i,2)
%         x=h;
%     else
%         x=h/2;
%     end
%    
%     while 1
%         x=x+h*(rand-0.5)*2*1e-9;
%         y=y+h*(rand-0.5)*2*1e-9;
%         XY_Node=[XY_Node;[x,y]];
%         
%         x=x+h_x;
%         
%         if x>lx-h*0.01
%             break;
%         end
%     end
%     
%     y=y+h_y;
%     i=i+1;
%     
%     if y>ly-h*0.01
%         break;
%     end
% end

%xy=rand((nx-2)*(ny-2),2);
%XY_Node=[XY_Node;[lx*((xy(:,1)-0.5)*0.99+0.5),ly*((xy(:,2)-0.5)*0.99+0.5)]];

save data_400 XY_Node Nb_Node_Front Ind_Node_Front h

%----------------------------------------------------------

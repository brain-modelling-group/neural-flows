function theHandle = vfield3(axh, x,y,z,u,v,w,varargin)
%VFIELD3   Plot 3D velocity field
%   Plots 3-D arrows as cones. Is similar to CONEPLOT but the inputs
%   can have any dimension.
%
%   Syntax:
%      HANDLE = VFIELF3(X,Y,Z,U,V,W,VARARGIN)
%
%   Inputs:
%      X, Y, X   Positions, N-D arrays
%      U, V, W   Field, N-D arrays
%      VARARGIN:
%         CData, by default the speed is used as CData
%         'color', <color>, patches color (then CData is not used)
%         'tr', <val>, tip length with respect to intensity or
%            absolute length if is a string
%            [ <value> <value as string> {0.3} ]
%         'ar', <val>, arrow radius with respect to tip width/2 [0.3 ]
%         'fi' <deg>, tip angle [  20 ]
%         'n', <num>, ponts used in the circunferences [ 25 ]
%
%   Output:
%      HANDLE   Patch handle
%
%   Examples:
%      r = linspace(0.5,1,2);
%      tt = linspace(0,2*pi,20);
%      [r,tt] = meshgrid(r,tt);
%      [x,z] = pol2cart(tt,r);
%      y = zeros(size(x));
%      u = zeros(size(x));
%      v = 2-r.^2; v=v./1.5;
%      w = zeros(size(x));
%
%      figure
%      vfield3(x,y,z,u,v,w);
%      vfield3(x,y+2,z,u,v,w,'tr',1,'fi',5);
%      vfield3(x,y+4,z,u,v,w,'ar',1,'fi',10);
%
%      caxis([-0.5 2])
%      axis equal
%      camlight
%      view(50,30)
%
%   MMA 2-10-2005, martinho@fis.ua.pt
%
%   See also VFIELD
%   Department of Physics
%   University of Aveiro, Portugal
n     = 25;
fi    = 20;
r     = 0.3;
rp    = 0.3;
useC     = 0;
useColor = 0;
color    = 'b';
for i=1:length(varargin)
  vin = varargin{i};
  if isnumeric(varargin{1});
    C = varargin{1};
    useC = 1;
  end
  if isequal(vin,'color')
    useColor = 1;
    color = varargin{i+1};
  end
  if isequal(vin,'tr')
    r = varargin{i+1};
  end
  if isequal(vin,'ar')
    rp = varargin{i+1};
  end
  if isequal(vin,'fi')
    fi = varargin{i+1};
  end
  if isequal(vin,'n')
    n = varargin{i+1};
  end
end
tt=linspace(0,2*pi,n);
nvals=prod(size(x));
x0 = reshape(x,nvals,1);
y0 = reshape(y,nvals,1);
z0 = reshape(z,nvals,1);
u  = reshape(u,nvals,1);
v  = reshape(v,nvals,1);
w  = reshape(w,nvals,1);
speed = sqrt(u.^2+v.^2+w.^2);
if ~isstr(r)
  L = speed.*r;
else
  L = repmat(str2num(r),size(speed));
end
rr = L*tan(fi*pi/180);
x  = rr*cos(tt);
y  = rr*sin(tt);
zz  = zeros(size(x0));
xxz = x * rp;
yyz = y * rp;
x=[zz  x xxz  xxz zz];
y=[zz  y yyz  yyz zz];
z=[speed repmat(speed-L,1,length(tt)) repmat(speed-L,1,length(tt)),...
   zeros(nvals,length(tt)) zeros(1,length(x0))'];
[th,phi,r]=cart2sph(u,v,w);
th  = repmat(th, 1,size(x,2));
phi = repmat(phi,1,size(x,2))-pi/2;
[x,y,z]=rot3d(x,y,z,th*180/pi,phi*180/pi);
x=x+repmat(x0,1,size(x,2));
y=y+repmat(y0,1,size(x,2));
z=z+repmat(z0,1,size(x,2));
x = reshape(x',prod(size(x)),1);
y = reshape(y',prod(size(y)),1);
z = reshape(z',prod(size(z)),1);
fff = [
       ones(n-1,1)       ones(n-1,1)     [2     : n    ]'    [3    : n+1  ]';
       [2     : n    ]'  [3   : n+1   ]' [n+3   : 2*n+1]'    [n+2  : 2*n  ]';
       [n+3   : 2*n+1]'  [n+2 : 2*n   ]' [2*n+2 : 3*n  ]'    [2*n+3: 3*n+1]';
       [2*n+2 : 3*n  ]'  [2*n+3: 3*n+1]' (3*n+2)*ones(n-1,1) (3*n+2)*ones(n-1,1)
];
add = [0:nvals-1]*(3*n+2);
add = repmat(add',1,size(fff,1));
add = reshape(add',prod(size(add)),1);
add = repmat(add,1,size(fff,2));
if ~useColor
  if ~useC
    C = speed;
  else
    C = reshape(C,nvals,1);
  end
  C = repmat(C,1,3*n+2);
  C = reshape(C',prod(size(C)),1);
  p = patch(axh, x,y,z,C);
else
  p = patch(axh, x,y,z, color);
end
fff = repmat(fff,nvals,1);
fff = fff+add;

set(p,'faces',fff);
set(p,'edgecolor','none');
theHandle = p;

function [x2,y2,z2]=rot3d(x,y,z,tt,fi)
%ROT3D   3D solid rotation
%   Rotation arround OY (X to Z) followed by rotation arround OZ
%   (X to Y).
%
%   Syntax:
%      [X,Y,Z] = ROT3D(XI,YI,ZI,TH,PHI)
%
%   Inputs:
%      XI, YI, ZI   Initical positions, N-D arrays
%      TH    OZ rotation angle (deg)
%      PHI   OY rotation angle (deg)
%
%   Outputs:
%      X, Y, Z
%
%   Example:
%      figure
%      r = 1;
%      t = linspace(0,2*pi,20);
%      x = r*cos(t);
%      y = r*sin(t);
%      z = zeros(size(x));
%      plot3([-1 1 nan 0 0 nan 0 0],[0 0 nan -1 1 nan 0 0],[0 0 nan 0 0 nan -1 1]);
%      hold on, axis equal
%      plot3(x,y,z,'ro-')
%      [x,y,z] = rot3d(x,y,z,40,30)
%      plot3(x,y,z,'ko-')
%      text(1,0,0,'x');
%      text(0,1,0,'y');
%      text(0,0,1,'z');
%      view(75,25)
%
%   MMA 13-1-2003, martinho@fis.ua.pt
%
%   See also ROT2D
%   Department of Physics
%   University of Aveiro, Portugal
%   07-07-2004 - Correction
%   02-10-2005 - allow inputs as N-D arrays
x2=[];
y2=[];
z2=[];
theSize = size(x);
n = prod(theSize);
x = reshape(x,n,1);
y = reshape(y,n,1);
z = reshape(z,n,1);
if size(tt)==1 & size(fi)==1
  tt = repmat(tt,n,1);
  fi = repmat(fi,n,1);
else
  tt = reshape(tt,n,1);
  fi = reshape(fi,n,1);
end
v=[x y z];
v2 = rot(v,tt,fi);
x2=v2(1,:);  x2 = reshape(x2,theSize);
y2=v2(2,:);  y2 = reshape(y2,theSize);
z2=v2(3,:);  z2 = reshape(z2,theSize);
function v2 = rot(v,tt,fi)
v = repmat(v,1,3);
v  = reshape(v',1,prod(size(v)));
tt=-tt*pi/180; tt=tt';
fi=-fi*pi/180; fi=fi';
n=length(tt);
M = [ cos(tt).*cos(fi) ;  sin(tt)          ;   cos(tt).*sin(fi) ;
     -sin(tt).*cos(fi) ;  cos(tt)          ;  -sin(tt).*sin(fi) ;
     -sin(fi)          ;  zeros(size(tt))  ;   cos(fi)           ];
M  = reshape(M,1,9*n);
v2 = M.*v;
v2 = reshape(v2,3,3*n);
v2 = sum(v2);
v2 = reshape(v2,3,n);

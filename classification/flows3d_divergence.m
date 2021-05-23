function [div, px, qy, rz] = flows3d_divergence(varargin)
%DIVERGENCE  Divergence of a 3D vector field. Based on Matlab's divergence
%function.
%   DIV = DIVERGENCE(X,Y,Z,U,V,W) computes the divergence of a 3-D
%   vector field U,V,W. The arrays X,Y,Z define the coordinates for
%   U,V,W and must be monotonic and 3-D plaid (as if produced by
%   MESHGRID).
%   DIV_EQUAL_SIGN: checks the sign of the partial derivatives
%             if all 0 => div_equal_sign = -1
%             if all +++ or --- = >  div_equal_sign = 1
%             if ++- or --+ (any arrangement) div_equal_sign = 0
%{
USAGE:
      load wind
      div = divergence(x,y,z,u,v,w);
      slice(x,y,z,div,[90 134],[59],[0]); shading interp
      daspect([1 1 1])
      camlight
%}      
%   Copyright 1984-2012 The MathWorks, Inc.

narginchk(2,6);
[x, y, z, u, v, w] = parseargs(nargin,varargin);

% Take this out when other data types are handled
u = double(u);
v = double(v);
w = double(w);

  
% Only 3D  
if isempty(x)
    [px, ~, ~] = gradient(u); 
    [~, qy, ~] = gradient(v); 
    [~, ~, rz] = gradient(w); 
else
    hx = x(1,:,1); 
    hy = y(:,1,1); 
    hz = z(1,1,:); 
    [px, ~, ~] = gradient(u, hx, hy, hz); 
    [~, qy, ~] = gradient(v, hx, hy, hz); 
    [~, ~, rz] = gradient(w, hx, hy, hz); 
end
  if nargout >=1 
     div = px+qy+rz;
  end

end % flows3d_divergence()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z, u, v, w] = parseargs(nin, vargin)

x = [];
y = [];
z = [];
w = [];

if nin==2         % divergence(u,v)
  u = vargin{1};
  v = vargin{2};
elseif nin==3     % divergence(u,v,w)
  u = vargin{1};
  v = vargin{2};
  w = vargin{3};
elseif nin==4     % divergence(x,y,u,v)
  x = vargin{1};
  y = vargin{2};
  u = vargin{3};
  v = vargin{4};
elseif nin==6     % divergence(x,y,z,u,v,w)
  x = vargin{1};
  y = vargin{2};
  z = vargin{3};
  u = vargin{4};
  v = vargin{5};
  w = vargin{6};
else
  error(message('MATLAB:divergence:WrongNumberOfInputs')); 
end 
end % function parseargs()

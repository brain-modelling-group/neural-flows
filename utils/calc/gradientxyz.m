function varargout = gradientxyz(f,varargin)
%GRADIENT Approximate gradient in 3D. This is a stripped version of 
% Matlab's function gradient()
%   [FX,FY,FZ] = GRADIENT(F, HY, HX, HZ) uses the spacing given by
%  **** HY, HX, HZ. NOTE THAT HY has to be specified first ******
% **** Note: The first output FX is always the gradient along the 2nd
%   dimension of F, going across columns.  The second output FY is always
%   the gradient along the 1st dimension of F, going across rows.  For the
%   third output FZ and the outputs that follow, the Nth output is the
%   gradient along the Nth dimension of F.
%
%   Class support for input F:
%      float: double, single
%
%   See also DIFF, DEL2.

%   Copyright 1984-2015 The MathWorks, Inc.

[f,ndim,loc, ~] = parse_inputs(f,varargin);
nargoutchk(0,ndim);

% Loop over each dimension. 

varargout = cell(1,ndim);
siz = size(f);
% first dimension 
g  = zeros(size(f),class(f)); % case of singleton dimension
h = loc{1}(:); 
n = siz(1);
% Take forward differences on left and right edges
if n > 1
   g(1,:) = (f(2,:) - f(1,:))/(h(2)-h(1));
   g(n,:) = (f(n,:) - f(n-1,:))/(h(end)-h(end-1));
end

% Take centered differences on interior points
if n > 2
   g(2:n-1,:) = (f(3:n,:)-f(1:n-2,:)) ./ (h(3:n) - h(1:n-2));
end

varargout{1} = g;


    % N-D case
    for k = 2:ndim
        n = siz(k);
        newsiz = [prod(siz(1:k-1)) siz(k) prod(siz(k+1:end))];
        nf = reshape(f,newsiz);
        h = reshape(loc{k},1,[]);
        g  = zeros(size(nf),class(nf)); % case of singleton dimension
        
        % Take forward differences on left and right edges
        if n > 1
            g(:,1,:) = (nf(:,2,:) - nf(:,1,:))/(h(2)-h(1));
            g(:,n,:) = (nf(:,n,:) - nf(:,n-1,:))/(h(end)-h(end-1));
        end
        
        % Take centered differences on interior points
        if n > 2
            h = h(3:n) - h(1:n-2);
            g(:,2:n-1,:) = (nf(:,3:n,:) - nf(:,1:n-2,:)) ./ h;
        end
        
        varargout{k} = reshape(g,siz);
    end

% Swap 1 and 2 since x is the second dimension and y is the first.
varargout(2:-1:1) = varargout(1:2);


end
%-------------------------------------------------------
function [f,ndim,loc,rflag] = parse_inputs(f,v)
%PARSE_INPUTS
%   [ERR,F,LOC,RFLAG] = PARSE_INPUTS(F,V) returns the spacing
%   LOC along the x,y,z,... directions and a row vector
%   flag RFLAG. 

% Flag vector case and row vector case.
ndim = ndims(f);
rflag = false;
indx = size(f);

% Swap 1 and 2 since x is the second dimension and y is the first.
loc = v;

%replace any scalar step-size with corresponding position vector
for k = 1:ndims(f)
    loc{k} = loc{k}*(1:indx(k));
end 
end

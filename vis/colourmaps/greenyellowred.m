%% Return a colormap array [m,3] -- diverging data or sequential data, like 
%  a traffic light. 
% ARGUMENTS:
%    m -- number of colours in colormap.
%    order -- ['fwd'|'rev'] ordering of returned colormap array.
%
% OUTPUT:
%    c -- [m,3] colormap array.
%
% REQUIRES:
%
% AUTHOR:
%     Paula Sanz-Leon (2019-06-18).
%
% USAGE:
%{
    
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [c] = greenyellowred(m, order)
    %% If number of colours (m) not specified, try setting from current colormap.
    if nargin < 1 || isempty(m)
       f = get(groot, 'CurrentFigure');
       if isempty(f)
          m = size(get(groot, 'DefaultFigureColormap'), 1);
       else
          m = size(f.Colormap, 1);
       end
    end

    if nargin < 2  || isempty(order)
        order = 'fwd';
    end

    %% Basis colormap from http://colorbrewer2.org
    bcm = [165,0,38; ...
           215,48,39; ...
           244,109,67; ...
           253,174,97; ...
           254,224,139; ...
           255,255,191; ...
           217,239,139; ...
           166,217,106; ...
           102,189,99; ...
           26,152,80; ...
           0,104,55] ./ 255.0;
     bcm = flipud(bcm);

    %% Number of colours in basis colormap.
    nc = size(bcm, 1);

    %% Colour step size to produce m colours for output.
    cstep = (nc - 1) / (m - 1);

    %% Linear interpolation of basis colormap.
    c = interp1(1:nc, bcm, 1:cstep:nc);

    if strcmp(order, 'rev') % reverse colormap
        c = c(end:-1:1, :);
    end

end % function greenyellowred()

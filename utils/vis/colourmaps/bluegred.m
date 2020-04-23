%% Return a colormap array [m,3] -- diverging, blue to red, with gray in the 
%  middle.
% NOTE: to preserve symmetry, use: odd numbers <= 11; or odd multiple of 11.
%
% ARGUMENTS:
%    m -- number of colours in colormap.
%    ordering -- ['fwd'|'rev'] ordering of returned colormap array.
%
% OUTPUT:
%    c -- [m,3] colormap array.
%
% REQUIRES:
%
% AUTHOR:
%     Paula Sanz-Leon (2018-12-21).
%
% USAGE:
%{
    cmap = bluegred(65);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [c] = bluegred(m, ordering)
    %% If number of colours (m) not specified, try setting from current colormap.
    if nargin < 1 || isempty(m)
       f = get(groot, 'CurrentFigure');
       if isempty(f)
          m = size(get(groot, 'DefaultFigureColormap'), 1);
       else
          m = size(f.Colormap, 1);
       end
    end

    if nargin < 2  || isempty(ordering)
        ordering = 'fwd';
    end

    %% Basis colormap from http://colorbrewer2.org
    bcm = [  5,  48,  97; ...
            33, 102, 172; ...
            67, 147, 195; ...
           146, 197, 222; ...
           209, 229, 240; ...
           225, 225, 225; ...
           253, 219, 199; ...
           244, 165, 130; ...
           214,  96,  77; ...
           178,  24,  43; ...
           103,   0,  31  ...
                             ] ./ 255.0;

    %% Number of colours in basis colormap.
    nc = size(bcm, 1);

    %% Colour step size to produce m colours for output.
    cstep = (nc - 1) / (m - 1);

    %% Linear interpolation of basis colormap.
    c = interp1(1:nc, bcm, 1:cstep:nc);

    if strcmp(ordering, 'rev') % reverse colormap
        c = c(end:-1:1, :);
    end

end % function bluered()

%% Return a colormap array [m,3] -- diverging, shades of red-yellow-blue.
% Colourblind friendly
%
%
% ARGUMENTS:
%    m -- number of colours in colormap.
%    ordering -- ['fwd'|'rev'] ordering of returned colormap array.
%
% OUTPUT:
%    c -- [m,3] colormap array.
% AUTHOR:
%     Paula Sanz-Leon (2018-12-21).
%
% USAGE:
%{
    cmap = redyellowblue(64);
%}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [c] = redyellowblue(m, ordering)
    %% If number of colours (m) not specified, try setting from current colormap.
    if nargin < 1
       f = get(groot, 'CurrentFigure');
       if isempty(f)
          m = size(get(groot, 'DefaultFigureColormap'), 1);
       else
          m = size(f.Colormap, 1);
       end
    end
    
    if nargin < 2 
        ordering='fwd';
    end

    bcm =[165,0,38;...
          215,48,39;...
          244,109,67;...
          253,174,97;...
          254,224,144;...
          255,255,191;...
          224,243,248;...
          171,217,233;...
          116,173,209;...
          69,117,180;...
          49,54,149]./255;

    %% Number of colours in basis colormap.
    nc = size(bcm, 1);

    %% Colour step size to produce m colours for output.
    cstep = (nc - 1) / (m - 1);

    %% Linear interpolation of basis colormap.
    c = interp1(1:nc, bcm, 1:cstep:nc);

    if strcmp(ordering, 'rev') % reverse colormap
        c = c(end:-1:1, :);
    end
end % function redyellowwhiteblue()

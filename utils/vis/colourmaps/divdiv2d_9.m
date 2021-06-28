% Return a colormap array [m,3] -- divergent divergent bivariate colourmap
% NOTE: it only has 9 colours
%
% ARGUMENTS:
%
% OUTPUT:
%    c -- [m,3] colormap array.
%
% REQUIRES:
%
% AUTHOR:
%     Paula Sanz-Leon (2012-06-07).
%
% USAGE:
%{
    cmap = divdiv2d_9();

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [c] = divdiv2d_9()

c = [200, 200, 200; % class 00
     254, 154, 166; % class 01
     154, 201, 213; % class 02
     240, 4, 127;   % class 03
     90, 77, 164;   % class 04
     243, 115, 0;   % class 05
     0, 136, 55;    % class 06 
     205, 154, 204; % class 07
     204, 232, 139; % class 08
     255, 255, 255] ... % class 09 - nan
     ./255;

end % function divdiv2d_9()

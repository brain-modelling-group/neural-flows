
% Return a colormap array [m,3] -- sequential
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
%     Paula Sanz-Leon (2019-11-04).
%
% USAGE:
%{
    imagesc(rand(256))
    cmap = viridis(64);
    colormap(cmap)
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [c] = brewer_dark2_six(m, ordering)

c = [128, 128, 128; % unclassified
    102, 166, 30; % plane flow
     230,171,2; % shear flow
     217, 95, 2; % divering
     117, 112, 179; % converging
     231, 41, 138; % rotating
     ]./ 256;

end

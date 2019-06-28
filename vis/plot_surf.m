% Plots a triangulated surface in 3D with white background and no axes. 
% Mainly done for generting movie frames.  
% ARGUMENTS:
%    surf_struct -- a structure with fields:
%                   .vertices [num_vertices x 3]
%                   .faces    
%    data        -- data to plot on the surface [num_vertices x 1]
%    cmap        -- a string with the name of the colourmap to use.
%                   Available: {'default' | 'rwb' | 'bgr'};
%    fax         -- a structure with fields:   
%                   .figure: figure handle
%                   .axes: axes handle
%
% OUTPUT:
%    surf_handle -- handle to trisurf graphics object
%    fax         -- a structure with figure and axes handles.
%
% REQUIRES:
%
% AUTHOR:
%     Paula Sanz-Leon (2018-12-21).
%
% USAGE:
%{
    
%}
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [surf_handle, fax] = plot_surf(surf_struct, data, cmap, fax)

if nargin < 3
    cmap='default';
end

if nargin < 4
    figure_handle = figure('Name', 'plot_surf');
    ax = subplot(1,1,1, 'Parent', figure_handle);
    fax.figure = figure_handle;
    fax.axes = ax;
end

switch cmap
    case 'default'
        colour_map=colormap('parula');
    case 'bgr' % blue-gray-red  
        colour_map=bluegred(129);
    case 'rywb'% red-yellow-white-blue
        colour_map=redyellowwhiteblue(255);
    case 'gyr'
        colour_map=greenyellowred(255);
    otherwise 
        error(['patchflow:' mfilename ':UnknownArg'], ...
               'The cmap requested does not exist.');
        
end

xdim = 1;
ydim = 2;
zdim = 3;

surf_handle = trisurf(surf_struct.faces, surf_struct.vertices(:,xdim), ...
                                         surf_struct.vertices(:,ydim), ...
                                         surf_struct.vertices(:,zdim), ...
                                         data);
                                    
fax.axes.DataAspectRatio = [1 1 1];
fax.axes.View = [0 90]; % top view
axis tight; axis vis3d off;
 
lighting gouraud 
material shiny 
shading interp

set(fax.figure,'Color','w')
set(fax.figure, 'Colormap', colour_map)
% end function plot_surf()

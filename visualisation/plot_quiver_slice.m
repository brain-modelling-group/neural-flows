function [figure_handle] = plot_quiver_slice(obj_flows, slice_axis, slice_idx, tpt_idx, options)
%% Plots 2D stream-quivers. The 2D velocity field is a slice of a 3D+t field.
%
% ARGUMENTS: 
%    obj_flows  -- MatFile object
%    slice_axis -- a string with the axis along which we'll slice
%                  Options: {'xaxis', 'yaxis', 'zaxis'}. Default: {'x-axis'}
%    slice_idx  -- slice index along slice_axis. No dim checks implemented
%    tpt_idx    -- the index along the 4th dimension
%    varargin   -- options structure for the plot
%
% OUTPUT:
%    None
%
% AUTHOR:
%    Paula Sanz-Leon, (2019), QIMR Berghofer
%
% USAGE:
%{ 


%}
%
% REQUIRES:
%         draw_stream_arrow()
%         yellowgreenblue()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(options)
    options.start_points_mode = 'random_dense';
    options.curved_arrow = 1;
    options.stream_length_steps=128;
    cmap = yellowgreenblue(256, 'rev');
    %cmap = inferno(256);
    options.cmap = cmap;

end

switch slice_axis
    
    case {'xaxis', 'x', 'x-axis'}
        % plane zy
        %vx = squeeze(obj_flows.ux(:, slice_idx, :, tpt_idx));
        u = squeeze(obj_flows.uy(:, slice_idx, :, tpt_idx))';
        v = squeeze(obj_flows.uz(:, slice_idx, :, tpt_idx))';
        w = squeeze(obj_flows.ux(:, slice_idx, :, tpt_idx))';
        uvw = sqrt(u.^2+v.^2+w.^2);
        XX = squeeze(obj_flows.Y(:, slice_idx, :))';
        YY = squeeze(obj_flows.Z(:, slice_idx, :))';             
    case {'yaxis', 'y', 'y-axis'}
        % plane zx
        u = squeeze(obj_flows.ux(slice_idx, :, :, tpt_idx))';
        %vy = squeeze(obj_flows.uy(slice_idx, :, :, tpt_idx));
        v = squeeze(obj_flows.uz(slice_idx, :, :, tpt_idx))';
        w = squeeze(obj_flows.uy(slice_idx, :, :, tpt_idx))';
        XX = squeeze(obj_flows.X(slice_idx, :, :))';
        YY = squeeze(obj_flows.Z(slice_idx, :, :))';
    case {'zaxis', 'z', 'z-axis'}  
        % plane xy
        u = squeeze(obj_flows.ux(:, :, slice_idx, tpt_idx));
        v = squeeze(obj_flows.uy(:, :, slice_idx, tpt_idx));
        w = squeeze(obj_flows.uz(:, :, slice_idx, tpt_idx));
        %v = squeeze(obj_flows.uz(slice_idx, :, :, tpt_idx));
        XX = squeeze(obj_flows.X(:, :, slice_idx));
        YY = squeeze(obj_flows.Y(:, :, slice_idx));
    otherwise
        error(['neural-flows:' mfilename ':BadInputArgument'], ...
              'The slice_axis you requested is not available.');
               
end
uvw = sqrt(u.^2+v.^2+w.^2);
options.Vmag = uvw;
% Plot the stuff
[figure_handle] = draw_stream_arrow(XX, YY, u, v, options);

end % function plot_quiver_slice()

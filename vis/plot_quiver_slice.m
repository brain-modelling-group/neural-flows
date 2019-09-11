function [figure_handle] = plot_quiver_slice(mfile_vel, slice_axis, slice_idx, tpt_idx, options)
%% Plots 2D stream-quivers. The 2D velocity field is a slice of a 3D+t field.
%
% ARGUMENTS: 
%    mfile_vel  -- MatFile object
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
    options.stream_length_steps=42;
    cmap = yellowgreenblue(256, 'rev');
    options.cmap = cmap;

end

switch slice_axis
    
    case {'xaxis', 'x', 'x-axis'}
        % plane zy
        %vx = squeeze(mfile_vel.ux(:, slice_idx, :, tpt_idx));
        u = squeeze(mfile_vel.uy(:, slice_idx, :, tpt_idx))';
        v = squeeze(mfile_vel.uz(:, slice_idx, :, tpt_idx))';
        XX = squeeze(mfile_vel.Y(:, slice_idx, :))';
        YY = squeeze(mfile_vel.Z(:, slice_idx, :))';             
    case {'yaxis', 'y', 'y-axis'}
        % plane zx
        u = squeeze(mfile_vel.ux(slice_idx, :, :, tpt_idx))';
        %vy = squeeze(mfile_vel.uy(slice_idx, :, :, tpt_idx));
        v = squeeze(mfile_vel.uz(slice_idx, :, :, tpt_idx))';
        XX = squeeze(mfile_vel.X(slice_idx, :, :))';
        YY = squeeze(mfile_vel.Z(slice_idx, :, :))';
    case {'zaxis', 'z', 'z-axis'}  
        % plane xy
        u = squeeze(mfile_vel.ux(:, :, slice_idx, tpt_idx));
        v = squeeze(mfile_vel.uy(:, :, slice_idx, tpt_idx));
        %v = squeeze(mfile_vel.uz(slice_idx, :, :, tpt_idx));
        XX = squeeze(mfile_vel.X(:, :, slice_idx));
        YY = squeeze(mfile_vel.Y(:, :, slice_idx));
    otherwise
        error(['patchflow:' mfilename ':BadInputArgument'], ...
              'The slice_axis you requested is not available.');
               
end

% Plot the stuff
[figure_handle] = draw_stream_arrow(XX, YY, u, v, options);


end % function plot_quiver_slice()

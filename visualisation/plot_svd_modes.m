function fig_spatial_modes = plot_svd_modes(V, U, X, Y, Z, time_vec, num_modes, num_points, prct_var, quiver_scale_factor)
    % V spatial svd modes
    % U temporal svd modes

    fig_spatial_modes = figure('Name', 'nflows-spatial-modes');

    num_planes = 3; % number of spatial projections
    ax = gobjects(num_planes+1, num_modes);
    
    for ii=1:num_planes
        for kk=1:num_modes
            ax(ii, kk) = subplot(num_planes+1, num_modes, sub2ind([num_modes, num_planes+1], kk, ii), 'Parent', fig_spatial_modes);
            hold(ax(ii, kk), 'on');
        end
    end

    ax(num_planes+1, 1) = subplot(num_planes+1, num_modes, [(num_planes*num_modes)+1 (num_modes*num_planes)+num_modes], 'Parent', fig_spatial_modes);
    hold(ax(num_planes+1, 1), 'on');
    
    x_idx = 1:num_points;
    y_idx = num_points+1:2*num_points;
    z_idx = 2*num_points+1:3*num_points;
    
    Vnorm =  sqrt(V(x_idx, :).^2+ V(y_idx, :).^2+ V(z_idx, :).^2);
    
    % Get overall direction along each axis
    Vx = sign(sum(V(x_idx, :)));
    Vy = sign(sum(V(y_idx, :)));
    Vz = sign(sum(V(z_idx, :)));
    
    % NOTE: maybe enable this check to avoid zero division
    %Vnorm(Vnorm < 2^-9) = 1;
    
    cmap = plasma(num_modes+2);
    cmap = cmap(1:num_modes, :);
    cmap = cmap(end:-1:1, :);

    xy = 1;
    xz = 2;
    zy = 3;
    scaling_vxyz = 32;
    axes_offset = 4;
    x_lims = [min(X(:))-axes_offset, max(X(:))+axes_offset];
    y_lims = [min(Y(:))-axes_offset, max(Y(:))+axes_offset];
    z_lims = [min(Z(:))-axes_offset, max(Z(:))+axes_offset];
    
    draw_arrow_fun = @(axh, x, y, z, varargin) vfield3(axh, x(1), y(1), z(1), x(2)-x(1), y(2)-y(1), z(2)-z(1), varargin{:});    
    mode_str = cell(num_modes, 1);
    for imode = 1:num_modes
        quiver3(ax(xy, imode), X, Y, Z, V(x_idx, imode)./Vnorm(:, imode), ...
                                        V(y_idx, imode)./Vnorm(:, imode), ...
                                        V(z_idx, imode)./Vnorm(:, imode), ...
                                        quiver_scale_factor, 'Linewidth', 1, ...
                                        'Color', cmap(imode, :));
        quiver3(ax(xz, imode), X, Y, Z, V(x_idx, imode)./Vnorm(:, imode), ...
                                        V(y_idx, imode)./Vnorm(:, imode), ...
                                        V(z_idx, imode)./Vnorm(:, imode), ...
                                        quiver_scale_factor, 'Linewidth', 1, ...
                                        'Color', cmap(imode, :));
        quiver3(ax(zy, imode), X, Y, Z, V(x_idx, imode)./Vnorm(:, imode), ...
                                        V(y_idx, imode)./Vnorm(:, imode), ...
                                        V(z_idx, imode)./Vnorm(:, imode), ...
                                        quiver_scale_factor, 'Linewidth', 1, ...
                                        'Color', cmap(imode, :));
        % XY
        draw_arrow_fun(ax(xy, imode), [0 scaling_vxyz*Vx(imode)], [0 0], [z_lims(end) z_lims(end)], 'color', [1 0 0]);
        draw_arrow_fun(ax(xy, imode), [0 0], [0 scaling_vxyz*Vy(imode)], [z_lims(end) z_lims(end)], 'color', [0 1 0]);
   
        % XZ
        draw_arrow_fun(ax(xz, imode), [0 scaling_vxyz*Vx(imode)], [y_lims(1) y_lims(1)], [0 0], 'color', [1 0 0]);
        draw_arrow_fun(ax(xz, imode), [0 0], [y_lims(1) y_lims(1)], [0 scaling_vxyz*Vz(imode)], 'color', [0 0 1]);
        
        % ZY
        draw_arrow_fun(ax(zy, imode), [x_lims(end) x_lims(end)], [0 0], [0 scaling_vxyz*Vz(imode)], 'color', [0 0 1]);
        draw_arrow_fun(ax(zy, imode), [x_lims(end) x_lims(end)], [0 scaling_vxyz*Vy(imode)], [0 0], 'color', [0 1 0]);
        
        ax(xy, imode).View = [ 0 90];
        ax(xz, imode).View = [ 0  0];
        ax(zy, imode).View = [90  0];

        ax(xy, imode).Title.String = sprintf('Mode %i, Var = %0.1f%%', imode, prct_var(imode));
        mode_str{imode} = sprintf('%i', imode);
        
        % Axis Limits
        ax(xy, imode).XLim = x_lims;
        ax(xy, imode).YLim = y_lims;
        ax(xy, imode).ZLim = z_lims;
        
        ax(xz, imode).XLim = x_lims;
        ax(xz, imode).YLim = y_lims;
        ax(xz, imode).ZLim = z_lims;
        
        ax(zy, imode).XLim = x_lims;
        ax(zy, imode).YLim = y_lims;
        ax(zy, imode).ZLim = z_lims;
        
        axis(ax(xy, imode), 'tight', 'off')
        axis(ax(xz, imode), 'tight', 'off')
        axis(ax(zy, imode), 'equal', 'off')

    end
    
     smooth_window = 2; % number of samples to smooth the envelope
     [~, Upeak] = envelope(U, smooth_window, 'peak');
     max_u_val = 1.1*max(abs(Upeak(:)));
     ulims = [-max_u_val max_u_val];
     
     for imode=1:num_modes
         plot(ax(num_planes+1, 1), time_vec, U(:, imode), 'Color', cmap(imode, :))
     end
     ax(num_planes+1, 1).Title.String = sprintf('Modes timeseries');
     ax(num_planes+1, 1).YLim = ulims;
     ax(num_planes+1, 1).XLim = [time_vec(1), time_vec(end)];
     line(ax(num_planes+1, 1), ax(num_planes+1, 1).XLim, [0 0], 'Color', 'k', 'LineStyle', '--')
     ax(num_planes+1, 1).XLabel.String = 'Time';
     ax(num_planes+1, 1).YLabel.String = 'Component score';
     ax(num_planes+1, 1).Box = 'on';
     lg_obj = legend(ax(num_planes+1, 1));
     lg_obj.String = mode_str;
     lg_obj.Title.String = 'Modes';
     lg_obj.Orientation = 'horizontal';
     
 end % function plot_svd_modes()
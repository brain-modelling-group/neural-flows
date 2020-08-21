function fig_spatial_modes = plot_svd_modes(V, U, X, Y, Z, prct_var, num_modes, time_vec)
    % V struct with components of spatial svd modes
    % U array temporal svd modes
    
    % Graphics elements
    fig_spatial_modes = figure('Name', 'nflows-spatial-modes');
    fig_spatial_modes.Position = [1340         360        1240        1600];
    num_planes = 3; % number of spatial projections
    num_temp_plot = 1;
    num_rows = num_planes + num_temp_plot;
    num_cols = num_modes;
    ax = gobjects(num_rows, num_cols);
    
    for ii=1:num_rows
        for kk=1:num_cols
            ax(ii, kk) = subplot(num_rows, num_cols, sub2ind([num_rows, num_cols], ii, kk), 'Parent', fig_spatial_modes);
            hold(ax(ii, kk), 'on');
        end
    end
    
    %ax(num_rows, 1) = subplot(num_rows, num_cols, [(num_planes*num_modes)+1 (num_modes*num_planes)+num_modes], 'Parent', fig_spatial_modes);
    hold(ax(num_planes+1, 1), 'on');

    threshold = 1e-6; % NOTE: should be a parameter
    V.vx(abs(V.vx) < threshold) = 0;
    V.vy(abs(V.vy) < threshold) = 0;
    V.vz(abs(V.vz) < threshold) = 0;
    
    % Get overall direction along each axis = +/-/null 
    Vx_sign = sign(sum(V.vx));
    Vy_sign = sign(sum(V.vy));
    Vz_sign = sign(sum(V.vz));
    
    % NOTE: maybe enable this check to avoid zero division    
    cmap = plasma(num_modes+2);
    cmap = cmap(1:num_modes, :);
    cmap = cmap(end:-1:1, :);
    
    % Temporal modes
    
    smooth_window = 2; % number of samples to smooth the envelope
    [~, Upeak] = envelope(U, smooth_window, 'peak');
    max_u_val = 1.1*max(abs(Upeak(:)));
    ulims = [-max_u_val max_u_val];

    % Orthognal plane indices
    xy = 1;
    xz = 2;
    zy = 3;
    tt = 4;
    
    width_01 = 0.2;
    width_02 = 0.25;
    
    scaling_vxyz = 32;
    axes_offset = 4;
    x_lims = [min(X(:))-axes_offset, max(X(:))+axes_offset];
    y_lims = [min(Y(:))-axes_offset, max(Y(:))+axes_offset];
    z_lims = [min(Z(:))-axes_offset, max(Z(:))+axes_offset];
    
    draw_arrow_fun = @(axh, x, y, z, varargin) vfield3(axh, x(1), y(1), z(1), x(2)-x(1), y(2)-y(1), z(2)-z(1), varargin{:});    
    mode_str = cell(num_modes, 1);
    colormap(cmap)
    for kthmode = 1:num_modes
        this_color = cmap(:, kthmode);
        [faces,vertices,colors] = quiver3Dpatch(X, Y, Z, ...
                                V.vx(:, kthmode), ...
                                V.vy(:, kthmode), ...
                                V.vz(:, kthmode), ...
                                this_color(ones(1, numel(V.vz(:, kthmode))), :), [10 11]); 
        hp=patch(ax(xy, kthmode), 'faces', faces,'vertices', vertices,'cdata', colors,'edgecolor','none','facecolor','flat');

        ax(xy, kthmode).DataAspectRatio = [1 1 1];

        [faces,vertices,colors] = quiver3Dpatch(X, Y, Z, ...
                                V.vx(:, kthmode), ...
                                V.vy(:, kthmode), ...
                                V.vz(:, kthmode), ...
                                this_color(ones(1, numel(V.vz(:, kthmode))), :), [10 11]); 
        hp=patch(ax(xz, kthmode), 'faces', faces,'vertices', vertices,'cdata', colors,'edgecolor','none','facecolor','flat');

        ax(xz, kthmode).DataAspectRatio = [1 1 1];
                [faces,vertices,colors] = quiver3Dpatch(X, Y, Z, ...
                                V.vx(:, kthmode), ...
                                V.vy(:, kthmode), ...
                                V.vz(:, kthmode), ...
                                this_color(ones(1, numel(V.vz(:, kthmode))), :), [10 11]); 
        hp=patch(ax(zy, kthmode), 'faces', faces,'vertices', vertices,'cdata', colors,'edgecolor','none','facecolor','flat');

        ax(zy, kthmode).DataAspectRatio = [1 1 1];
        % XY
        draw_arrow_fun(ax(xy, kthmode), [0 scaling_vxyz*Vx_sign(kthmode)], [0 0], [z_lims(end) z_lims(end)], 'color', [1 0 0]);
        draw_arrow_fun(ax(xy, kthmode), [0 0], [0 scaling_vxyz*Vy_sign(kthmode)], [z_lims(end) z_lims(end)], 'color', [0 1 0]);
   
        % XZ
        draw_arrow_fun(ax(xz, kthmode), [0 scaling_vxyz*Vx_sign(kthmode)], [y_lims(1) y_lims(1)], [0 0], 'color', [1 0 0]);
        draw_arrow_fun(ax(xz, kthmode), [0 0], [y_lims(1) y_lims(1)], [0 scaling_vxyz*Vz_sign(kthmode)], 'color', [0 0 1]);
        
        % ZY
        draw_arrow_fun(ax(zy, kthmode), [x_lims(end) x_lims(end)], [0 0], [0 scaling_vxyz*Vz_sign(kthmode)], 'color', [0 0 1]);
        draw_arrow_fun(ax(zy, kthmode), [x_lims(end) x_lims(end)], [0 scaling_vxyz*Vy_sign(kthmode)], [0 0], 'color', [0 1 0]);
        
        ax(xy, kthmode).View = [ 0 90];
        ax(xz, kthmode).View = [ 0  0];
        ax(zy, kthmode).View = [90  0];
        
        posxy = ax(xy, kthmode).Position;
        posxz = ax(xz, kthmode).Position;
        poszy = ax(zy, kthmode).Position;
        postt = ax(tt, kthmode).Position;
        
        ax(xy, kthmode).Position = [0.05+width_01*(kthmode-1) 0.7 width_01 0.20];
        ax(xz, kthmode).Position = [0.02+width_02*(kthmode-1) 0.5 width_02 0.20];
        ax(zy, kthmode).Position = [0.02+width_02*(kthmode-1) 0.3 width_02 0.25];
        ax(tt, kthmode).Position = [0.05+width_01*(kthmode-1) 0.1 width_01 0.20];

        ax(xy, kthmode).Title.String = sprintf('Spatial mode %i\n Var = %0.1f%%', kthmode, prct_var(kthmode));
        mode_str{kthmode} = sprintf('%i', kthmode);
        
        % Axis Limits
        ax(xy, kthmode).XLim = x_lims;
        ax(xy, kthmode).YLim = y_lims;
        ax(xy, kthmode).ZLim = z_lims;
        
        ax(xz, kthmode).XLim = x_lims;
        ax(xz, kthmode).YLim = y_lims;
        ax(xz, kthmode).ZLim = z_lims;
        
        ax(zy, kthmode).XLim = x_lims;
        ax(zy, kthmode).YLim = y_lims;
        ax(zy, kthmode).ZLim = z_lims;
        
        axis(ax(xy, kthmode), 'off')
        axis(ax(xz, kthmode), 'off')
        axis(ax(zy, kthmode), 'off')
        
        % Temporal modes
        plot(ax(tt, kthmode), time_vec, U(:, kthmode), 'Color', cmap(kthmode, :))
        %ax(tt, kthmode).Title.String = sprintf('Temporal mode %i', kthmode);
        ax(tt, kthmode).YLim = ulims;
        ax(tt, kthmode).XLim = [time_vec(1), time_vec(end)];
        line(ax(tt, kthmode), ax(tt, kthmode).XLim, [0 0], 'Color', 'k', 'LineStyle', '--')
        ax(tt, kthmode).XLabel.String = 'Time';
        ax(tt, kthmode).YLabel.String = 'Mode score';
        ax(tt, kthmode).Box = 'on';
%         lg_obj = legend(ax(tt, kthmode));
%         lg_obj.String = mode_str;
%         lg_obj.Title.String = ['Temporal mode ' num2str(kthmode)];
%         lg_obj.Orientation = 'horizontal';
    end
     
 end % function plot_svd_modes()
function fig_spatial_modes = plot_svd_modes(V, U, X, Y, Z, time_vec, num_modes, num_points, prct_var, quiver_scale_factor)

    fig_spatial_modes = figure('Name', 'nflows-spatial-modes');

    num_planes = 3; % number of spatial projections
    ax = gobjects(num_planes+1, num_modes);
    
    for ii=1:num_planes
        for kk=1:num_modes
            ax(ii, kk) = subplot(num_planes+1, num_modes, sub2ind([num_modes, num_planes+1], kk, ii), 'Parent', fig_spatial_modes);
            hold(ax(ii, kk), 'on')
        end
    end

    ax(num_planes+1, 1) = subplot(num_planes+1, num_modes, [(num_planes*num_modes)+1 (num_modes*num_planes)+num_modes], 'Parent', fig_spatial_modes);
    hold(ax(num_planes+1, 1), 'on')
    
    x_idx = 1:num_points;
    y_idx = num_points+1:2*num_points;
    z_idx = 2*num_points+1:3*num_points;
    
    Vnorm =  sqrt(V(x_idx, :).^2+ V(y_idx, :).^2+ V(z_idx, :).^2);
    % NOTE: maybe enable this check to avoid zero division
    %Vnorm(Vnorm < 2^-9) = 1;
    
    cmap = plasma(num_modes+2);
    cmap = cmap(1:num_modes, :);
    cmap = cmap(end:-1:1, :);

    xy = 1;
    xz = 2;
    zy = 3;
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

        ax(xy, imode).View = [ 0 90];
        ax(xz, imode).View = [ 0  0];
        ax(zy, imode).View = [90  0];

        ax(xy, imode).Title.String = sprintf('Mode %i, Var = %0.1f%%', imode, prct_var(imode));
        axis(ax(xy, imode), 'tight', 'off')
        axis(ax(xz, imode), 'tight', 'off')
        axis(ax(zy, imode), 'tight', 'off')

    end
    
     smooth_window = 8; % number of samples to smooth the envelope
     [~, Upeak] = envelope(U, smooth_window, 'peak');
     max_u_val = 1.1*max(abs(Upeak(:)));
     ulims = [-max_u_val max_u_val];
     
     for imode=1:num_modes
         plot(ax(num_planes+1, 1), time_vec, Upeak(:, imode), 'Color', cmap(imode, :))
     end
     ax(num_planes+1, 1).Title.String = sprintf('Modes timeseries');
     ax(num_planes+1, 1).YLim = ulims;
     ax(num_planes+1, 1).XLim = [time_vec(1), time_vec(end)];
     line(ax(num_planes+1, 1), ax(num_planes+1, 1).XLim, [0 0], 'Color', 'k', 'LineStyle', '--')
     ax(num_planes+1, 1).XLabel.String = 'Time';
     ax(num_planes+1, 1).YLabel.String = 'Component score';


 end % function plot_svd_modes()
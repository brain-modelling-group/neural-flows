function fig_spatial_modes = plot_svd_modes(V, U, X, Y, Z, time_vec, num_modes, num_points, prct_var, quiver_scale_factor)

  fig_spatial_modes = figure('Name', 'nflows-spatial-modes');

    for kk=1:num_modes
       ax(kk) = subplot(2, num_modes, kk, 'Parent', fig_spatial_modes);
       hold(ax(kk), 'on')
    end

    ax(num_modes+1) = subplot(2, num_modes, [num_modes+1 2*num_modes], 'Parent', fig_spatial_modes);
    hold(ax(num_modes+1), 'on')

    for imode = 1:num_modes
        x_idx = 1:num_points;
        y_idx = num_points+1:2*num_points;
        z_idx = 2*num_points+1:3*num_points;
        quiver3(ax(imode), X, Y, Z, V(x_idx, imode), V(y_idx, imode), V(z_idx, imode), quiver_scale_factor);
        ax(imode).View = [0 90];
        ax(imode).Title.String = sprintf('Mode %i, Var = %0.1f%%', imode, prct_var(imode));

    end
    
     smooth_window = 4; % number of samples to smooth the envelope
     [~, Upeak] = envelope(U, smooth_window, 'peak');
     max_u_val = 1.1*max(abs(Upeak(:)));
     ulims = [-max_u_val max_u_val];
     
     plot(ax(num_modes+1), time_vec, Upeak)
     ax(num_modes+1).Title.String = sprintf('Modes timeseries');
     ax(num_modes+1).YLim = ulims;
     ax(num_modes+1).XLim = [time_vec(1), time_vec(end)];
     line(ax(num_modes+1), ax(num_modes+1).XLim, [0 0], 'Color', 'k')
     ax(num_modes+1).XLabel.String = 'Time';
     ax(num_modes+1).YLabel.String = 'Component score';


 end % function plot_svd_modes()
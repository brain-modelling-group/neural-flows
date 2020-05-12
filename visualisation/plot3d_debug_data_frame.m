function fig_handle = plot3d_debug_data_frame(fig_handle, data, X, Y, Z, time)
%     % Visual debugging of the first time point
%     % TODO: generate a movie, perhaps of projections onto a 2d plane.
%     %figure('Name', 'nflows-planewave3d-space');
%     tt = 1;
%     %colormap(bluegred(256))
%     pcolor3(X, Y, Z, squeeze(data(:, :, :, tt)));
%     colormap(bluegred(256))
%     ylabel('Y')
%     xlabel('X')
%     zlabel('Z')

%     figure('Name', 'nflows-planewave3d-time')
%     plot(time, wave2d, 'color', [0.0 0.0 0.0 0.5]);
%     xlabel('time')
%     ylabel('p(x, y, z)')

end
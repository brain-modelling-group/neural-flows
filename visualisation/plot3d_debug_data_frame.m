function fig_handle = plot3d_debug_data_frame(fig_handle, data, X, Y, Z, time)


if isempty(fig_handle)
    fig_handle = figure('Name', 'nflows-plot3d-debug-wave-frame')
end


    if length(size(data)) == 4
        tt = 1;
        %colormap(bluegred(256))
        pcolor3(X, Y, Z, squeeze(data(:, :, :, tt)), 'fig', fig_handle);
        colormap(bluegred(256))
        ylabel('Y')
        xlabel('X')
        zlabel('Z')

%         figure('Name', 'nflows-planewave3d-time')
%         plot(time, wave2d, 'color', [0.0 0.0 0.0 0.5]);
%         xlabel('time')
%         ylabel('p(x, y, z)')
    else
        tt = 1;
        these_axes = subplot(1,1,1, 'Parent', fig_handle); 
        scatter3(data(tt, :));
        colormap(bluegred(256))
        ylabel('Y')
        xlabel('X')
        zlabel('Z')
    end
        

end
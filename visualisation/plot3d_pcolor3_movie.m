function [figure_handle] = plot3d_pcolor3_movie(X, Y, Z, V)

% Plots volumetric data over time - memory consuming
% V is a 4D array, where the three frost dimensions are spatial dimensions
% and time is the fourth diemnsions




crange=quantile(V(1:100:end),[0.001 0.999]); 
max_val = max(abs(crange));

time = 1:size(V, 4);
fig_pcolor = figure('Name', 'nflows-pcolor3-movie');
fig_pcolor.Position = [31.6442   10.0013   29.5010   22.5954];
colormap(yellowgreenblue(256, 'rev'))
colorbar


try
        vidfile = VideoWriter('pcolor3_movie.mp4','MPEG-4');
catch
        vidfile = VideoWriter('pcolor3_movie.avi');
end    
        vidfile.FrameRate = 15;
        open(vidfile);
        
for tt=1:length(time)
        these_axes = subplot(1, 1, 1, 'Parent', fig_pcolor);
        colorbar(these_axes)
        these_axes.XLabel.String = 'X';
        these_axes.YLabel.String = 'Y';
        these_axes.ZLabel.String = 'Z';
        cla;
        pcolor3(X, Y, Z, squeeze(V(:, :, :, tt)), 'axes', these_axes);
        axis off
        title(['Time:' num2str(time(tt), '%.3f') ' ms'])
        view([0 90])
        %view([0 0])
        %view([90 0]) 
        caxis([crange]);
        pause(0.01); 
        writeVideo(vidfile, getframe(fig_pcolor));
end     


close(vidfile)


end % function plot3d_pcolor3_movie()
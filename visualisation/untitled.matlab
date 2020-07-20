%     min_val = min(wave3d(:));
%     max_val = max(wave3d(:));
%     
% %     fig_pcolor3 = figure('Name', 'nflows-travellingwave3d-space');
% %     these_axes = subplot(1,1,1, 'Parent', fig_pcolor3);
% %     tt = 1;
% %     pcolor3(X, Y, Z, squeeze(wave3d(tt, :, :, :)), 'axes', these_axes);
% %     xlabel('X')
% %     ylabel('Y')
% %     zlabel('Z')
% % 
% %     figure('Name', 'nflows-travellingwave3d-time')
% %     plot(time, squeeze(wave3d(:, idx_1, idx_2, idx_2)));
% %     xlim([time(1) time(end)])
% %     xlabel('time')
% %     ylabel('p(x, y, z)')
% % 
% %     figure('Name', 'nflows-travellingwave3d-space-time-1d')
% %     plot(time, temp, 'color', [0.65 0.65 0.65]);
% %     xlim([time(1) time(end)])
% %     xlabel('time')
% %     ylabel(['space: ' ylabel_str])
%     
%     fig_spiral = figure('Name', 'nflows-spiralwave3d-space-time');
%     for tt=1:length(time)
%         these_axes = subplot(1, 1, 1, 'Parent', fig_spiral);
%         these_axes.XLabel.String = 'X';
%         these_axes.YLabel.String = 'Y';
%         these_axes.ZLabel.String = 'Z';
%         cla;
%         pcolor3(X, Y, Z, squeeze(wave3d(tt, :, :, :)), 'axes', these_axes); 
%         caxis([min_val  max_val]);pause(0.5); 
%     end     
% 
%     %make_movie_gif(temp2)
% end
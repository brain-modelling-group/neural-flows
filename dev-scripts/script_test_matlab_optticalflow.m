for kk=1:4000 
    frameGray = data_grey(:, :, kk);
    frameGray(isnan(frameGray)) = 0;
    %[FX,FY] = gradient(frameGray);
    
   OF(kk) = estimateFlow(opticFlow,frameGray); 
%     imshow(frameGray); hold on;     
%     plot(flow,'ScaleFactor',10); 
%     hold off; 
end

%% 

ax1 = subplot(1,2,1);
ax2 = subplot(1,2,2); hold on


I1handle = imagesc(ax1, OF(1).Orientation);
axis equal
I2handle =  imagesc(ax2, data_grey(:, :, 1));
axis equal
caxis(ax1, [-pi, pi]);
caxis(ax2, [0 1]);

ANGLE_MAP = hsv(255);
ANGLE_MAP = [ANGLE_MAP; 1 1 1];


%n = 4000;             %// number of colors

%R = linspace(1,0,n);  %// Red from 1 to 0
%B = linspace(0,1,n);  %// Blue from 0 to 1
%G = zeros(size(R));   %// Green all zero

%sQUIVER_MAP =  colormap( [R(:), G(:), B(:)] );  %// create colormap

set(ax1, 'Colormap', ANGLE_MAP);
set(ax2, 'Colormap', gray(256));

for kk=1:4000
    OMap = OF(kk).Orientation;
    OMap(isnan(data_grey(:, :, kk))) = nan;
    set(I1handle, 'CData', OMap,  'AlphaData', ~isnan(data_grey(:, :, kk)))
    set(I2handle, 'CData', data_grey(:, :, kk), 'AlphaData', ~isnan(data_grey(:, :, kk)))
    quiver(ax2, OF(kk).Vx, OF(kk).Vy, 'color', QUIVER_MAP(kk, :))
    pause(0.01)
end

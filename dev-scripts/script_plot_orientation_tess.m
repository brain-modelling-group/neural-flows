


tt = 1;

lh = 1:8192;
tri_lh = 1:16380;

fax.figure = figure(1);
fax.axes = subplot(1,1,1);
hold(fax.axes, 'on')
[~, norm_vf] = normalise_vector_field(flow_fields(lh, :, tt), 3);

nmax = max(norm_vf(:));

% Plot colour images of projections. 
c = double(squeeze(compute_circular_jet_hue(flow_fields(lh, 1, tt)/nmax, flow_fields(lh, 2, tt)/nmax))) ./ 255;
quiv_handle = quiver3(fax.axes, cortex.vertices(lh, 1), ...
                                cortex.vertices(lh, 2), ...
                                cortex.vertices(lh, 3), ...
                                flow_fields(lh, 1, tt), ...
                                flow_fields(lh, 2, tt), ...
                                flow_fields(lh, 3, tt), ...
                                5, 'color', [0.5 0.5 0.5 0.1], 'linewidth', 0.5);
                            
surf_handle = trisurf(cortex.faces(tri_lh, :), cortex.vertices(lh, 1), cortex.vertices(lh, 2), cortex.vertices(lh, 3), ...
        'FaceColor', 'interp', 'FaceVertexCData', c, 'EdgeColor', 'none');
daspect([1, 1, 1]);
view([0 90]);


xlims = fax.axes.XLim;
ylims = fax.axes.YLim;
zlims = fax.axes.ZLim;


for tt=1:idx_end-20
    
    [~, norm_vf] = normalise_vector_field(flow_fields(lh, :, tt), 3);
     nmax = max(norm_vf(:));

    % Plot colour images of projections. 
    c = double(squeeze(compute_circular_jet_hue(flow_fields(lh, 1, tt)/nmax, flow_fields(lh, 2, tt)/nmax))) ./ 255;
               
    set(surf_handle, 'FaceVertexCData', c)
    set(quiv_handle, 'UData', flow_fields(lh, 1, tt), ...
                     'VData', flow_fields(lh, 2, tt), ...
                     'WData', flow_fields(lh, 3, tt))
    
    %Hacky bit: Avoid jitter from frame to frame
    fax.axes.XLim = xlims;
    fax.axes.YLim = ylims;
    fax.axes.ZLim = zlims;
    %caxis([-max_val max_val])
    pause(0.1)
    TheMovie(1,tt) = getframe(fax.figure);
end

%% Write movie to file
videoname = strcat('neural_flows_dataset_', num2str(this_dataset, '%02d'));
v = VideoWriter([ videoname '.avi']);
v.FrameRate = 10;

open(v);
for kk=1:size(TheMovie,2)
   writeVideo(v,TheMovie(1, kk)) 
end
close(v)
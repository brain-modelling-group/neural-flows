% This scripts tests the estimation of neural flows on curved manifolds, and 
% the classification of the flow on each triangle of the mesh.
% Critical points are classified either as saddles or nodes (sinks, or
% sources). Further analysis is required to distinguish between sinks/sources. 

% Author: Paula Sanz-Leon, QIMR June 2019

% Load surface
load('neural_flows_cortex_mesh')

% Load data
load('neural_flows_surf_wave_data', 'smooth_wave_data')

% Generate timevec -- not really used at the moment
time_data = 1:1:size(smooth_wave_data{1}, 1);

%% Estimate neural flows
this_dataset = 1; % NOTE: change this index to access 1 of 4 datasets availble
hs_smoothness = 1;
idx_start = 1;   
idx_end   = 201;

% NOTE: the calculation takes about 50s for input data of size [v: 16384 x t: 201] 
[flow_fields, ~, ~, ~, poincare_index, time_flow] = estimate_flow_tess(smooth_wave_data{this_dataset}.', ...
                                                                     cortex, time_data, ...
                                                                     idx_start, idx_end, ...
                                                                     hs_smoothness);
%% Set up graphics objects
tt=1;
[surf_handle, fax] = plot_surf(cortex, smooth_wave_data{this_dataset}(tt, :), 'bgr');
hold(fax.axes, 'on')
quiv_handle = quiver3(fax.axes, cortex.vertices(:, 1), ...
                                cortex.vertices(:, 2), ...
                                cortex.vertices(:, 3), ...
                                flow_fields(:, 1, tt), ...
                                flow_fields(:, 2, tt), ...
                                flow_fields(:, 3, tt), ...
                                5, 'color', [0.5 0.5 0.5 0.1], 'linewidth', 0.5);
                  
% Find indices of critical points
cp_idx = find(poincare_index(:, tt)==1);

cp_handle = scatter3(fax.axes, cortex.face_barycentres(cp_idx, 1), ....
                               cortex.face_barycentres(cp_idx, 2), ...
                               cortex.face_barycentres(cp_idx, 3), 'k', 'filled');

xlims = fax.axes.XLim;
ylims = fax.axes.YLim;
zlims = fax.axes.ZLim;

%%
max_pos_val = max( smooth_wave_data{this_dataset}(:));
max_neg_val = max(-smooth_wave_data{this_dataset}(:));
max_val = min([max_pos_val, max_neg_val]);
caxis([-max_val max_val])

%% Make a movie out of the data
for tt=1:idx_end-1
    set(quiv_handle, 'UData', flow_fields(:, 1, tt), ...
                     'VData', flow_fields(:, 2, tt), ...
                     'WData', flow_fields(:, 3, tt))
    
    cp_idx = find(poincare_index(:, tt) ==1 );
    set(cp_handle, 'XData', cortex.face_barycentres(cp_idx, 1), ...
                   'YData', cortex.face_barycentres(cp_idx, 2), ...
                   'ZData', cortex.face_barycentres(cp_idx, 3))
               
    set(surf_handle, 'FaceVertexCData', smooth_wave_data{this_dataset}(tt, :).')
    
    %Hacky bit: Avoid jitter from frame to frame
    fax.axes.XLim = xlims;
    fax.axes.YLim = ylims;
    fax.axes.ZLim = zlims;

    caxis([-max_val max_val])
    pause(1)
    TheMovie(1,tt) = getframe(fax.figure);
end

%% Write movie to file
videoname = 'neural_flows_dataset_03';
v = VideoWriter([ videoname '.avi']);
v.FrameRate = 10;

open(v);
for kk=1:size(TheMovie,2)
   writeVideo(v,TheMovie(1, kk)) 
end
close(v)

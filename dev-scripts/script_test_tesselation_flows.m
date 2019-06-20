% This scripts tests the estimation of neural flows on curved manifolds, and 
% the classification of the flow on each triangle of the mesh.
% Author: Paula Sanz-Leon, QIMR June 2019

% Load surface
load('/home/paula/Work/Code/Networks/patchflow/demo-data/Cortex_reg13_to_513parc.mat')

% Load data
save('neural_flows_surf_wave_data', 'smooth_wave_data')

% Generate timevec -- not really used at the moment
time_data = 1:1:size(wave_data{1}, 1);



%% Estimate neural flows
this_dataset = 3;
hs_smoothness = 1;
idx_start = 2; % Should always start with 2 or larger
idx_end   = 201;
tic;
[flowField, int_dF, errorData, errorReg, poincare_idx, time_flow] = estimate_flow_tess(weighted_signal{this_dataset}.', cortex, time_data, idx_start, idx_end, hs_smoothness);
toc;

% benchmarks --> 50 seconds for flow calculation for data of size 16384 x 201 
%%
tt=1;
surf_handle = figure_surf(cortex, weighted_signal{this_dataset}(1, :), 'rwb');
view(2)
fig_handle = gcf;
ax_handle  = gca;
hold on
h = quiver3(ax_handle, cortex.vertices(:, 1), cortex.vertices(:, 2), cortex.vertices(:, 3), flowField(:, 1, tt), flowField(:, 2, tt), flowField(:, 3, tt), 5, 'color', [0.5 0.5 0.5 0.1], 'linewidth', 0.5);

%%
max_val = max(abs(weighted_signal{this_dataset}(:)));
caxis([-max_val max_val])

%%
for tt=1:idx_end-1
    set(h, 'UData', flowField(:, 1, tt), 'VData', flowField(:, 2, tt), 'WData', flowField(:, 3, tt))
    %set(surf_handle, 'FaceVertexCData', weighted_signal{this_dataset}(tt, :).')
    set(surf_handle, 'FaceVertexCData', poincare_idx(:, tt))

    %caxis([-max_val max_val])
    pause(0.1)
    TheMovie(1,tt) = getframe(fig_handle);
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

%% Plot distribution of speed
figure
subplot(121)
histogram(sqrt((1000*flowField(:, 1, :)).^2+(1000*flowField(:, 2, :)).^2+(1000*flowField(:, 3, :)).^2))
subplot(122)
histogram(log10(sqrt(flowField(:, 1, :).^2+flowField(:, 2, :).^2+flowField(:, 3, :).^2)))





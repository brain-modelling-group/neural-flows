% This scripts test brainstorm's optical flow technique on curved manifolds. 

%% Load some timeseries [time x nodes] 

% Load region mapping and project BNM -> Surface
load('data/simulations/long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat', 'soln')
%load('data/simulations/long_cd_ictime50_seg7999_outdt1_d0ms_W_coupling0.2_trial1.mat', 'soln')
load('data/RegionMapping_513parc_to_Cortex_reg13.mat')
load('data/Cortex_reg13_to_513parc.mat')
load('data/simulations/long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat', 'time')
t = time(end-4000:end-1);
%%
cortex_signal = soln(RegionMapping_voronoi, end-4000:end-1);
cortex_signal = cortex_signal.';
clear soln

%% Should be consistent with the names of vertices and faces/triangles
cortex.triangles    = Triangles;
cortex.vertices = Vertices;
cortex.VertexNormals = VertexNormals;
%% % Calculate a matrix of weight to smooth activity within the regions
% and across the boundaries
TR = TriRep(cortex.faces, cortex.vertices);

%From BNM if Local Cpupling is not calculated beforehand
LocalCoupling = NearestNeighbourCoupling(TR, 2);

%% If we already calculated LocalCoupling, then load the matrix
load('data/Cortex_reg13_LocalCoupling_NN_2ring.mat')

%% Calculate the smooth time series
% NOTE: this step can be done in paralllel for long timeseries / I think
% the results from BNM need to be transposed
weighted_signal = cortex_signal*LocalCoupling;


%% Look at the differences
figure(1)
figure_surf(cortex, cortex_signal(1, :), 'rwb')
caxis([-0.5, 0.5])
view(2)
figure(2)
figure_surf(cortex, weighted_signal(1, :), 'rwb')
caxis([-0.5, 0.5])
view(2)

%% 
hs_smoothness = 1;
idx_start = 2; % Should always start with 2 or larger
idx_end   = 4000;

[flowField, int_dF, errorData, errorReg, poincare_idx, time_flow] =  bst_opticalflow(weighted_signal.', cortex, t, idx_start, idx_end, hs_smoothness);

%%
tt=1;
surf_handle = figure_surf(cortex, weighted_signal(1, :), 'rwb');
fig_handle = gcf;
ax_handle  = gca;
hold on
h = quiver3(ax_handle, cortex.vertices(:, 1), cortex.vertices(:, 2), cortex.vertices(:, 3), flowField(:, 1, tt), flowField(:, 2, tt), flowField(:, 3, tt), 6, 'k', 'linewidth', 1);

%%
max_val = max(abs(weighted_signal(:)));
caxis([-max_val max_val])

%%
for tt=1:idx_end-1
    set(h, 'UData', flowField(:, 1, tt), 'VData', flowField(:, 2, tt), 'WData', flowField(:, 3, tt))
    set(surf_handle, 'FaceVertexCData', weighted_signal(tt, :).')
    caxis([-max_val max_val])
    pause(0.1)
    TheMovie(1,tt) = getframe(fig_handle);
end

%% Write movie to file
videoname = 'neural_flows_d1ms_coupling_0-6';

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

%% Calculate states
dimension_emb = 3;
%%
[stable, transient, stablePoints, transientPoints, dEnergy] = compute_neuralflow_states(flowField, cortex, dimension_emb, ...
                                                                                     time_flow, time_flow(2)-time_flow(1), ...
                                                                                     5, 'valleys', 'triangle', 1);

%% Save

figure_handle = gcf;
save_formats = {'eps', 'tiff', 'fig'}; %
output_path = pwd;
save_figure(figure_handle, save_formats, 'energy_state_classification_mockup', output_path);

%% Test dbscan function for classification

av_e = mean(dEnergy);
std_e = std(dEnergy);

[C, ptsC, centres] = dbscan(dEnergy, std_e, 1);

%% Try additional filtering to detect transitions times
sampling_period = time_flow(2)-time_flow(1);
filt_length_t = 10; % ms
filt_length = round(filt_length_t / sampling_period);
filt_fn =  ones(1,filt_length)/filt_length;
s = conv(dEnergy, filter_fn, 'same');
av_s = mean(s);
std_s = std(s);
[~, locs] = findpeaks(s, 'MinPeakHeight', av_s+1.5*std_s);



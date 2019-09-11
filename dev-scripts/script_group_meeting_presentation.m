%% load('/home/paula/Work/Code/Networks/patchflow/metastable_patterns_W_c1_d1ms_trial1.mat')
regions_labels = {'Frontal_{Sup_L_7}', 'Temporal_{Inf_L_9}', 'Occipital_{Sup_L_4}', ...
                  'Frontal_{Sup_R_7}', 'Temporal_{Inf_R_10}', 'Occipital_{Sup_R_4}'};

lr_region_idx = [136, 165, 219, 451, 421, 425];


figure_handle = figure;

for kk=1:4
    ax(kk) = subplot(2, 2, kk);
    hold(ax(kk), 'on')
end

lr_idx = [1, 3, 6, 4];
string_title = {'travelling', 'rotating', 'sinks-sources', 'spiral-sink'};
% Travelling wave
spacing = 1.2;
for tt=1:length(lr_idx)
    plot(ax(1), (spacing*tt-1)+travelling_wave(:, lr_region_idx(lr_idx(tt))))
end

% Rotating 
for tt=1:length(lr_idx)
plot(ax(2), (spacing*tt-1)+rotating_wave(:, lr_region_idx(lr_idx(tt))))
end
% Sink-source
for tt=1:length(lr_idx)

plot(ax(3), (spacing*tt-1)+sink_sources_wave(:, lr_region_idx(lr_idx(tt))))
end
% Rotating-sink
for tt=1:length(lr_idx)
plot(ax(4), (spacing*tt-1)+rotating_sink_wave(:, lr_region_idx(lr_idx(tt))))
end


for kk=1:4
    ax(kk).XLabel.String = 'time [ms]'; 
    ax(kk).XLim = [0 200];
    ax(kk).YLim = [-1 spacing*(length(lr_idx))];
    legend(ax(kk), 'show')
end

for kk=1:4
    ax(kk).Title.String = string_title{kk};  
end

lh = findobj(figure_handle,'Type','Legend');

for kk=1:4
    lh(kk).EdgeColor = 'none';
    lh(kk).String = {regions_labels{lr_idx}};
end
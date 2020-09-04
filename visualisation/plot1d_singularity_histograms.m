function figure_handle = plot1d_singularity_histograms(singularity_count)
% This function takes as input the counts of each singularity type per
% timepoint or frame.

base_cp = s3d_get_base_singularity_list();
cmap = s3d_get_colours('critical-points');

% Create figure
figure_handle = figure;
figure_handle.Units = 'centimeters';
figure_handle.Position = [10 10 18 20];
subplot_height = 3.5;
subplot_width = 6.5;

% Create axes
for kk=1:2:8
    axes2(kk) = subplot(4,2, kk);
    axes2(kk).Units = 'centimeters';
    axes2(kk).Position = [2.2 16-(2.2*(kk-1)) subplot_width subplot_height];
end

for kk=2:2:8
    axes2(kk) = subplot(4,2, kk);
    axes2(kk).Units = 'centimeters';
    axes2(kk).Position = [10 16-(2.2*(kk-2)) subplot_width subplot_height];
end

% hardcoded, we do not expect to have more than 1000 critical points per
% frame
bin_edges = [1:1:50] - 0.5;

for ii=1:8
    
hist_handle = histogram(singularity_count(:, ii), bin_edges, ...
                      'DisplayName',base_cp{ii},'Parent', axes2(ii), ...
                      'Linewidth', 2, ...
                      'EdgeColor', [0.4 0.4 0.4], ...
                      'FaceColor', cmap(ii, 1:3));

% Find maximum for which counts are nonzero, sets the x-axis. 
%[~, idx] = find(diff(cumsum(hist_handle.Values)));
%axes2(ii).XLim = [0 idx(end)+1];
axes2(ii).XLim = [0 200];
if ii > 6
    axes2(ii).XTick = bin_edges + 0.5;
else
    axes2(ii).XTick = [];
end
lh = legend(axes2(ii),'show');
lh.EdgeColor = 'none';

end

axes2(7).XLabel.String = '# cp / frame';
axes2(8).XLabel.String = '# cp / frame';
axes2(1).YLabel.String = {'counts',  '[# frames]'};

end %plot1d_singularity_histograms()
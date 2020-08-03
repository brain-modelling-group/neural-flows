function figure1 = plot_cp_histograms(singularity_cell)
% This function takes as input a cell with the integer classification of
% singular points and plots histograms.
% 
%  DATA1:  histogram data

%  Auto-generated by MATLAB on 25-May-2019 12:34:57

% Create figure
figure1 = figure;
figure1.Units = 'centimeters';
figure1.Position = [3 23 21 11.5];

% Create axes
axes1 = axes('Parent',figure1);
hold(axes1,'on');


num_sing = cellfun(@length, singularity_cell);

% get colors
for tt=1:length(num_sing)
    for ss=1:num_sing(tt)
     [label(tt).label(ss), ~] = map_str2int(singularity_cell{tt}{ss});
    end
end

% Create histogram
bin_edges = [0 1 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150];
histogram(num_sing, bin_edges, 'DisplayName','0.1*eps','Parent',axes1,'LineWidth',2,...
                   'EdgeColor',[1 1 1],...
                   'FaceColor',[0.5 0.5 0.5]);
% Create ylabel
axes1.YLabel.String = 'counts (#frames)';

% Create xlabel
axes1.XLabel.String = '# critical points / frame';
xlim(axes1,[-1 120]);
% Create legend
legend(axes1,'show');

% Create figure
figure2 = figure;
figure2.Units = 'centimeters';
figure2.Position = [10 10 14.5 20];
subplot_height = 3.5;
subplot_width = 5.3;

% Create axes
for kk=1:2:8
    axes2(kk) = subplot(4,2, kk);
    axes2(kk).Units = 'centimeters';
    axes2(kk).Position = [2.2 16-(2.2*(kk-1)) subplot_width subplot_height];
end

for kk=2:2:8
    axes2(kk) = subplot(4,2, kk);
    axes2(kk).Units = 'centimeters';
    axes2(kk).Position = [8.8 16-(2.2*(kk-2)) subplot_width subplot_height];
end

out = count_singularities(label);

% Get text labels
singularity_list = get_singularity_list();
% Get colours                
for ii=1:length(singularity_list)
  [~, cmap(ii, :)] = map_str2int(singularity_list{ii});
end

bin_edges = [1 2 3 4 5 6 7 8 9 10 11] -0.5;

for ii=1:size(out, 2)/2
histogram(out(:, ii), bin_edges, 'DisplayName', singularity_list{ii},'Parent', axes2(ii), ...
                      'Linewidth', 2, ...
                      'EdgeColor', [1 1 1], ...
                      'FaceColor', cmap(ii, 1:3))

axes2(ii).XLim = [0 6];
axes2(ii).XTick = bin_edges + 0.5;
lh = legend(axes2(ii),'show');
lh.EdgeColor = 'none';

end

axes2(7).XLabel.String = '# singularity / frame';
axes2(8).XLabel.String = '# singularity / frame';
axes2(1).YLabel.String = {'counts',  '(#frames)'};

% Adjust ylims: todo something better
axes2(1).YLim = [0 45];
axes2(2).YLim = [0 45];
axes2(3).YLim = [0 300];
axes2(4).YLim = [0 300];
axes2(5).YLim = [0 350];
axes2(6).YLim = [0 350];
axes2(7).YLim = [0 250];
axes2(8).YLim = [0 250];


end %plot_cp_histograms()
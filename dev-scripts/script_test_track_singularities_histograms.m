% Get colors for each singularity

num_sing = cellfun(@length, singularity_classification);

% get colors
for tt=5:200
    
    for ss=1:num_sing(tt)
     [label(tt).label(ss), color_map(tt).colormap(ss, :)] = map_str2int(singularity_classification{tt}{ss});
    
    end
end



singularity_list = {'sink', ...
                    'source', ...
                    '1-2-saddle',... 
                    '2-1-saddle',...
                    'spiral-source',... 
                    'spiral-sink',...
                    'source-po',...
                    'sink-po',...
                    'saddle-po',...
                    'twisted-po',...
                    'spiral-source-po',...
                    'spiral-sink-po', ...
                    'nan'};
                
for ii=1:12
  [~, cmap(ii, :)] = map_str2int(singularity_list{ii});
end

bin_edges = 0.5:1:12.5;

figure_handle = figure;
ax = subplot(1,1,1);
hold(ax, 'on')
this_frame = 5;
size_marker = 100;

ax.XLim = [0 200];
%ax.YLim = [0 200];


counts = zeros(200, length(bin_edges)-1);

for tt=this_frame+1:200
    
        [countsd, ~] = histcounts(label(tt).label, bin_edges);
        counts(tt, :) = countsd;
     
end

bar_handle = bar(1:200, counts, 'stacked', 'EdgeColor',[0 0 0]);

for kk=1:length(bar_handle)
    bar_handle(kk).FaceColor = cmap(kk, 1:3);
    
end
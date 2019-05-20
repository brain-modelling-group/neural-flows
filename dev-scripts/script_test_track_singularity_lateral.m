[singularity_classification] =   classify_singularities(xyz_idx, mfile_vel);


num_sing = cellfun(@length, singularity_classification);

% get colors
for tt=1:200
    for ss=1:num_sing(tt)
        singularity_classification{tt}{ss}
     [label(tt).label(ss), color_map(tt).colormap(ss, :)] = map_str2int(singularity_classification{tt}{ss});
    end
end

out = count_singularities(label);

% Get text labels
singularity_list = get_singularity_list();

% Get colours                
for ii=1:length(singularity_list)
  [~, cmap(ii, :)] = map_str2int(singularity_list{ii});
end

figure_handle = figure;
for ii=1:size(out, 2)
    ax(ii) = subplot(8,2,ii);
    hold(ax(ii), 'on')
end


for ii=1:size(out, 2)
stairs(ax(ii), log(out(:, ii)), 'color', cmap(ii, 1:3), 'linewidth', 2)
ax(ii).Title.String = singularity_list{ii};
end




function analyse_singularities(singularity_output, XYZ, )
% This function takes as an input a matfile with the list of
% singularities, or the cell array with the singularities.
%
%
% ARGUMENTS:
%        singularity_output -- a matfile with the classified singularities
%        XYZ                -- the original XYZ grid as a 2D array of size [numpoints x 3] array  
%
% OUTPUT: 
%        <output1> -- <description>
%        <output2> -- <description>
%
% REQUIRES: 
%        get_singularity_list()
%        map_str2int()
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
%
% This plot type of singularity as timeseries




num_sing = cellfun(@length, singularity_classification);

% get colors
for tt=1:size(mfile_vel, 'ux', 4)
    for ss=1:num_sing(tt)
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
stairs(ax(ii), out(:, ii), 'color', cmap(ii, 1:3), 'linewidth', 2)
ax(ii).Title.String = singularity_list{ii};
end

end

end




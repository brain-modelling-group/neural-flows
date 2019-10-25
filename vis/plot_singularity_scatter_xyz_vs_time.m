function figure_handle_xyz = plot_singularity_scatter_xyz_vs_time(singularity_list_num, null_points_3d, cp_type, figure_handle_xyz)

% This function plots different type of singularities as a a function of 
% position along one axis (X, Y, Z) vs time.

numsubplot = 3; % One for each spatial dimension

if nargin < 4
    figure_handle_xyz = figure('Name', 'nflows-singularities-over-1d-space-time');
    ax_xyz = gobjects(numsubplot);

    for jj=1:numsubplot
        ax_xyz(jj) = subplot(numsubplot, 1, jj, 'Parent', figure_handle_xyz);
        hold(ax_xyz(jj), 'on')
    end

else 
    ax_xyz = gobjects(numsubplot);
    for jj=1:3
       ax_xyz(4-jj) = figure_handle_xyz.Children(jj);
    end
        
end

num_frames = length(singularity_list_num);
    
y_labels = {'X', 'Y', 'Z'};
x_labels = {'', '', 'time'};
xplot = 1;
yplot = 2;
zplot = 3;


num_sing_to_plot = length(cp_type);

get_idx_cp_type = @(sing_list_frame, num_label_cp_type) find(sing_list_frame == num_label_cp_type);


for cc=1:num_sing_to_plot
    
    num_label_cp = s3d_get_numlabel(cp_type{cc});
    cmap_cp = s3d_get_colours(cp_type{cc});
    % Remove alpha
    cmap_cp(:, 4) = []; 

    
    for tt=1:num_frames
        x = null_points_3d(1, tt).x;
        y = null_points_3d(1, tt).y;
        z = null_points_3d(1, tt).z;
        idx_cp_type = get_idx_cp_type(singularity_list_num{tt}, num_label_cp);
        plot(ax_xyz(xplot), tt*ones(length(idx_cp_type), 1), x(idx_cp_type), '.', 'markeredgecolor', cmap_cp)
        plot(ax_xyz(yplot), tt*ones(length(idx_cp_type), 1), y(idx_cp_type), '.', 'markeredgecolor', cmap_cp)
        plot(ax_xyz(zplot), tt*ones(length(idx_cp_type), 1), z(idx_cp_type), '.', 'markeredgecolor', cmap_cp)

    end
           
       
        [ax_xyz(xplot:zplot).XLim] = deal([1 num_frames]);
        ax_xyz(xplot).YLabel.String = y_labels{xplot}; 
        ax_xyz(xplot).XLabel.String = x_labels{xplot};
        ax_xyz(yplot).YLabel.String = y_labels{yplot}; 
        ax_xyz(yplot).XLabel.String = x_labels{yplot}; 
        ax_xyz(zplot).YLabel.String = y_labels{zplot}; 
        ax_xyz(zplot).XLabel.String = x_labels{zplot}; 
        
end
    linkaxes(ax_xyz, 'x')
end

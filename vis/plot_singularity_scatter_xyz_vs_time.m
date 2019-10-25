function figure_handle_xyz = plot_singularity_scatter_xyz_vs_time(singularity_list_num, null_points_3d, figure_handle_xyz)

% This function plots different type of singularities as a a function of 
% position along one axis (X, Y, Z) vs time.

numsubplot = 3; % One for each spatial dimension

if nargin < 3
    figure_handle_xyz = figure('Name', 'nflows-singularities-over-spacetime');
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

% Get numeric labels of singularities we want to plot
source_ = s3d_get_numlabel('source');
spiral_source_ = s3d_get_numlabel('spiral-source');
saddle_source =  s3d_get_numlabel('1-2-saddle');
saddle_source_ = s3d_get_numlabel('1-2-spiral-saddle');

sink_ = s3d_get_numlabel('sink');
spiral_sink_ = s3d_get_numlabel('spiral-sink');
saddle_sink  = s3d_get_numlabel('2-1-saddle');
saddle_sink_ = s3d_get_numlabel('2-1-spiral-saddle'); 
    
y_labels = {'X', 'Y', 'Z'};
x_labels = {'', '', 'time'};

cmap_base_list = s3d_get_colours('all');


    for ii=1:numsubplot     
        for tt=1:num_frames
            x = null_points_3d(1, tt).x;
            y = null_points_3d(1, tt).y;
            z = null_points_3d(1, tt).z;
            
            idx_source = find(singularity_list_num{tt} == source_);
            idx_spiral_source = find(singularity_list_num == spiral_source_);
            idx_saddle_source = find(sigunlariy_list_num(tt).numlabel == saddle_source);
            idx_saddle_source_ = find(sing_labels(tt).numlabel == saddle_source_);

            idx_sink = find(sing_labels(tt).numlabel == sink_);
            idx_spiral_sink = find(sing_labels(tt).numlabel == spiral_sink_);
            idx_saddle_sink = find(sing_labels(tt).numlabel == saddle_sink);
            idx_saddle_sink_ = find(sing_labels(tt).numlabel == saddle_sink_);


            plot(ax_xyz(ii), tt*ones(length(idx_source), 1), x(idx_source), ...
                 '.', 'markeredgecolor', 'r')
            plot(ax_xyz(ii), tt*ones(length(idx_spiral_source), 1), y(idx_spiral_source), ii), ...
                 '.', 'markeredgecolor', 'r')
            % 
            plot(ax_xyz(ii), tt*ones(length(idx_sink), 1), z(idx_sink), ii), ...
                 '.', 'markeredgecolor', 'b')
            plot(ax_xyz(ii), tt*ones(length(idx_spiral_sink), 1), XYZ(xyz(idx_spiral_sink), ii), ...
                 '.', 'markeredgecolor', 'b')

            plot(ax_xyz(ii), tt*ones(length(idx_saddle_sink), 1), XYZ(xyz(idx_saddle_sink), ii), ...
                 'v', 'markeredgecolor', cmap(saddle_sink_, 1:3), 'markersize', 4 )
            plot(ax_xyz(ii), tt*ones(length(idx_saddle_sink_), 1), XYZ(xyz(idx_saddle_sink_), ii), ...
                 'v', 'markeredgecolor', cmap(saddle_sink_, 1:3), 'markersize', 4) 

            plot(ax_xyz(ii), tt*ones(length(idx_saddle_source), 1), XYZ(xyz(idx_saddle_source), ii), ...
                 '^', 'markeredgecolor', cmap(saddle_source_, 1:3), 'markersize', 4)
            plot(ax_xyz(ii), tt*ones(length(idx_saddle_source_), 1), XYZ(xyz(idx_saddle_source_), ii), ...
                 '^', 'markeredgecolor', cmap(saddle_source_, 1:3), 'markersize', 4) 

            

        end
        ax_xyz(ii).YLim = [-max(abs(XYZ(:, ii))) max(abs(XYZ(:, ii)))];
        ax_xyz(ii).XLim = [1 num_frames];
        ax_xyz(ii).YLabel.String = y_labels{ii}; 
        ax_xyz(ii).YLabel.String = x_labels{ii}; 
        
    end
    linkaxes(ax_xyz, 'x')
end

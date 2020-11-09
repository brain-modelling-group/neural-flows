function figure_handle = plot1d_singularity_punchcard(params)

nodes_str_lbl = params.data.nodes_str_lbl;
obj_singularity = load_iomat_singularity(params);
num_base_sngs = 8;
nodal_singularity_summary = obj_singularity.nodal_singularity_summary;

% TODO: configiure graphics property to handle paper units so we can plot
% stuff and give figure sizes
figure_handle = figure('Name', 'nflows-nodal-punchcard');
ax_pc = subplot(2, 4, [1 2 3 5 6 7], 'Parent', figure_handle);
ax_sc = subplot(2, 4, [4 8], 'Parent', figure_handle);
hold(ax_pc, 'on')
base_cp = s3d_get_base_singularity_list();
cmap = s3d_get_colours('critical-points');
total_frames = size(obj_singularity, 'tracking_2d_matrix', 2);

 plot_punchcard(ax_pc)
 plot_size_scale(ax_sc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting functions %%%%%%%%%%%%%%%%%%%%%%%
    function plot_punchcard(ax_pc)
        % 
        xdata = 1:length(nodal_singularity_summary.active_nodes.idx);
        ydata = 1:size(cmap, 1);
        for kk=1:size(cmap, 1)
            cdata = cmap(kk*ones(length(xdata), 1), :);
            sizedata = nodal_singularity_summary.occupancy_partial(kk, nodal_singularity_summary.active_nodes.idx) / total_frames; 
            sizedata = sizedata*1000; % percentage;
            sizedata(sizedata == 0) = 0.01; % Make super small dots
            sh(kk) = scatter(ax_pc, xdata, ydata(9-kk)*ones(1,length(xdata)), sizedata, cdata, 'filled');
        end 
        ax_pc.XTick = 1:length(nodal_singularity_summary.active_nodes.idx);
        ax_pc.XTickLabel = nodes_str_lbl(nodal_singularity_summary.active_nodes.idx);
        ax_pc.XTickLabelRotation = 45;
        %ax_pc.XAxisLocation = 'top';
        ax_pc.YTick = 1:size(cmap, 1); 
        ax_pc.YTickLabel = base_cp(8:-1:1);
        ax_pc.YLabel.String = 'critical point';
        ax_pc.XLabel.String = 'nodes';
        ax_pc.YLim = [0.5, 8.5];
        ax_pc.XLim = [0.5 length(xdata)+0.5];
        
        lgd_ax = legend(base_cp(1:num_base_sngs));
        lgd_ax.Title.String = 'Singularity Type';
        lgd_ax.Orientation = 'horizontal';
        lgd_ax.Location = 'south';
    end % function plot_stacked_bars

    function plot_size_scale(ax_sc)
        ydata = [5 10 15 20 25 30 35 40 45 50];
        scatter(ax_sc, ones(1, length(ydata)), ydata, ydata*10, [0.5 0.5 0.5], 'filled');
        ax_sc.YLabel.String = 'occupancy [% of time]';
        ax_sc.XTick = [];
        ax_sc.YLim = [0.5, 8.5];
        ax_sc.XLim = [0.5 length(xdata)+0.5];
        ax_sc.YLim = [2.5, 52.5];        
        ax_sc.TickLength = [0 0];
    end
   

end % function plot1d_singularity_punchcard()
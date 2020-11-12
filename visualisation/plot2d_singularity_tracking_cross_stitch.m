function [figure_handle, varargout] = plot2d_singularity_cross_stitch_tracking(params)

nodes_str_lbl = params.data.nodes_str_lbl;
obj_singularity = load_iomat_singularity(params);
nodal_singularity_summary = obj_singularity.nodal_singularity_summary;

% TODO: configiure graphics property to handle paper units so we can plot
% stuff and give figure sizes
figure_handle = figure('Name', 'nflows-sandplot-nodes-vs-time');
ax_pc = subplot(1,1,1, 'Parent', figure_handle);
hold(ax_pc, 'on');
base_cp = s3d_get_base_singularity_list();
cmap = s3d_get_colours('critical-points');
num_base_sngs = size(obj_singularity, 'tracking_3d_matrix', 1);
active_nodes = length(nodal_singularity_summary.active_nodes.idx); 
total_frames = size(obj_singularity, 'tracking_3d_matrix', 3);

% Load data to plot
data = obj_singularity.tracking_2d_matrix;
% Remove inactive singular nodes
data = data(nodal_singularity_summary.active_nodes.idx, :);
cmap = [cmap ; 1.0 1.0 1.0];
ax_pc = plot_cross_stitch(ax_pc);
ax_handles{1} = ax_pc;
varargout{1} = ax_handles;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting functions %%%%%%%%%%%%%%%%%%%%%%%
    function ax_pc = plot_cross_stitch(ax_pc)
        % 
        xdata = 1:total_frames;
        ydata = 1:active_nodes;
                
        for kk=1:active_nodes
            cdata_idx = data(kk, :);
            cdata_idx(cdata_idx == 0) = 9;
            cdata = cmap(cdata_idx, :);
            scatter(ax_pc, xdata, ydata(kk)*ones(1,length(xdata)), 120, cdata, ...
                    'filled', 'marker', 's', 'markerfacealpha', 1.0, 'markeredgecolor', [0.2 0.2 0.2], 'markeredgealpha', 0.5);
        end
        ax_pc.YTick = 1:length(nodal_singularity_summary.active_nodes.idx);
        ax_pc.YTickLabel = nodes_str_lbl(nodal_singularity_summary.active_nodes.idx);
        ax_pc.YLabel.String = 'nodes';
        ax_pc.YTickLabelRotation = 00;
        ax_pc.XLabel.String = 'time [samples]';
        ax_pc.YLim = [0.5, active_nodes + 0.5];
        ax_pc.XLim = [0.0 length(xdata)+1];
        ax_pc.Box = 'on';
        
        cmap_mat = cmap(end:-1:1, :);
        colormap(ax_pc, cmap_mat)
        cbarh = colorbar(ax_pc);
        dTk = diff(cbarh.Limits)/(2*length(cmap));
        set(cbarh,'Ticks', cbarh.Limits(1)+dTk:2*dTk:cbarh.Limits(2)-dTk, 'TickLabels',[{'none'} base_cp(num_base_sngs:-1:1)])


    end % function 
   
end % function plot1d_singularity_punchcard()

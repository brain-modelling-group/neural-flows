
function [figure_handle, varargout] = plot1d_singularity_global_occupancy(params)

nodes_str_lbl = params.data.nodes_str_lbl;
obj_singularity = load_iomat_singularity(params);
nodal_singularity_summary = obj_singularity.nodal_singularity_summary;

% TODO: configiure graphics property to handle paper units so we can plot
% stuff and give figure sizes
figure_handle = figure('Name', 'nflows-singularity-global-occupancy');
ax_pc = subplot(2, 4, [1 2 3 5 6 7], 'Parent', figure_handle);
ax_sc = subplot(2, 4, [4 8], 'Parent', figure_handle);
hold(ax_pc, 'on');
base_cp = s3d_get_base_singularity_list();
cmap = s3d_get_colours('critical-points');
num_base_sngs = size(obj_singularity, 'tracking_3d_matrix', 1);
active_nodes = length(nodal_singularity_summary.active_nodes.idx); 
total_frames = size(obj_singularity, 'tracking_3d_matrix', 3);

% Load data to plot
data = obj_singularity.tracking_3d_matrix;
% Remove inactive nodes
data = data(:, nodal_singularity_summary.active_nodes.idx, :);

ax_pc = plot_punchcard(ax_pc);
ax_sc = plot_size_scale(ax_sc);
ax_handles{1} = ax_pc;
ax_handles{2} = ax_sc;
varargout{1} = ax_handles;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting functions %%%%%%%%%%%%%%%%%%%%%%%
    function ax_pc = plot_punchcard(ax_pc)
        % 
        xdata = 1:total_frames;
        ydata = 1:num_base_sngs;
        
        for kk=1:num_base_sngs
            cdata = cmap(kk*ones(length(xdata), 1), :);
            sizedata = sum(squeeze(data(kk, :, :))) / active_nodes;
            sizedata = sizedata*1000; % sort of percentage;
            sizedata(sizedata == 0) = 0.01; % Make super small dots
            scatter(ax_pc, xdata, ydata(9-kk)*ones(1,length(xdata)), sizedata, cdata, ...
                    'filled', 'markerfacealpha', 1.0, 'markeredgecolor', [0.65 0.65 0.65]);
        end 
        ax_pc.YTick = 1:size(cmap, 1); 
        ax_pc.YTickLabel = base_cp(8:-1:1);
        ax_pc.YLabel.String = 'critical point';
        ax_pc.XLabel.String = 'time [samples]';
        ax_pc.YLim = [0.5, 8.5];
        ax_pc.XLim = [0.5 length(xdata)+0.5];
        ax_pc.Box = 'on';

    end % function plot_stacked_bars

    function ax_sc = plot_size_scale(ax_sc)
        ydata = [5 10 15 20 25 30 35 40 45 50]; % percentages
        scatter(ax_sc, ones(1, length(ydata)), ydata, ydata*10, [0.5 0.5 0.5], 'filled');
        ax_sc.YLabel.String = 'occupancy [% space]';
        ax_sc.XTick = [];
        ax_sc.YLim = [2.5, 52.5];
        ax_sc.XLim = [0.5 1.5];
        ax_sc.TickLength = [0 0];
        ax_sc.Box = 'on';
    end
   
end % function plot1d_singularity_punchcard()

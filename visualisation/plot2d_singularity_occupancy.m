function figure_handle = plot2d_singularity_occupancy(params, nodes_str_lbl)

obj_singularity = load_iomat_singularity(params);
% NOTE: this variable should be part of params or stored in obj_singularity
num_nodes = size(obj_singularity, 'tracking_2d_matrix', 1);
%nodes_str_lbl = params.data.nodes_str_lbl;
num_base_sngs = 8;
nodal_singularity_summary = obj_singularity.nodal_singularity_summary;
% Plot the occupancy of every type of singularity for valid nodes
%stairs(nodal_occupancy_matrix(:, valid_node_idx).')

% TODO: configiure graphics property to handle paper units so we can plot
% stuff and give figure sizes
figure_handle = figure('Name', 'nflows-nodal-occupancy');
ax_bar = subplot(5,1,3, 'Parent', figure_handle);

base_cp = s3d_get_base_singularity_list();
cmap = s3d_get_colours('critical-points');

ax_2d_mat = subplot(5,1,[1 2], 'Parent', figure_handle);
ax_3d_mat_a = subplot(5,1,5, 'Parent', figure_handle);
ax_3d_mat_b = subplot(5,1,4, 'Parent', figure_handle);

plot_stacked_bars(ax_bar)
plot_2d_matrix(ax_2d_mat)
plot_3d_matrix_a(ax_3d_mat_a)
plot_3d_matrix_b(ax_3d_mat_b)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plotting functions %%%%%%%%%%%%%%%%%%%%%%%
    function plot_stacked_bars(ax_bar)
        % 
        bh = bar(ax_bar, nodal_singularity_summary.occupancy_partial(:, nodal_singularity_summary.active_nodes.idx).', 'stacked');
        % 
        for ii=1:length(bh)
            bh(ii).FaceColor = cmap(ii, :);
        end
        ax_bar.XTick = 1:length(nodal_singularity_summary.active_nodes.idx);
        ax_bar.XTickLabel = nodes_str_lbl(nodal_singularity_summary.active_nodes.idx);
        ax_bar.XTickLabelRotation = 45;
        ax_bar.YLabel.String = 'occupancy [#frames]';
        ax_bar.XLabel.String = 'nodes';
        lgd_ax = legend(base_cp(1:num_base_sngs));
        lgd_ax.Title.String = 'Singularity Type';
        lgd_ax.Orientation = 'vertical';
        lgd_ax.Location = 'northwest';
    end % function plot_stacked_bars

    function plot_2d_matrix(ax_mat)
        imagesc(ax_mat, obj_singularity.tracking_2d_matrix)
        ax_mat.YLabel.String = 'nodes';
        ax_mat.XLabel.String = 'time  [frames]';
        cmap_mat = [0 0 0; cmap];
        numcolors = length(0:num_base_sngs);
        colormap(ax_mat, cmap_mat)
        min_cval = -0.5;
        max_cval = numcolors-0.5;
        caxis([min_cval max_cval]);
        colorbar(ax_mat, 'YTick',...
                ((min_cval+(numcolors-1)/numcolors):((numcolors-1)/numcolors):num_base_sngs),...
                'YTickLabel',[{'none'} base_cp(1:num_base_sngs)], 'YLim', [0 num_base_sngs]);
        
    end

    function plot_3d_matrix_a(ax_mat)
        this_matrix = squeeze(sum(obj_singularity.tracking_3d_matrix, 2));
        max_val = max(this_matrix(:));
        min_val = 0;
        imagesc(ax_mat, this_matrix)
        ax_mat.YLabel.String = 'singularity type';
        ax_mat.YTick = 1:num_base_sngs;
        ax_mat.YTickLabel = base_cp(:);
        ax_mat.XLabel.String = 'time  [frames]';
        numcolors = length(0:max_val);
        colormap(ax_mat, viridis(numcolors))
        min_cval = min_val - 0.5;
        max_cval = numcolors - 0.5;
        caxis([min_cval max_cval]);
        cbh = colorbar(ax_mat, 'YTick',...
                ((-1/numcolors)+((numcolors-1)/numcolors):((numcolors-1)/numcolors):max_val),...
                'YTickLabel',int2str([0:max_val]'), 'YLim', [0 max_val]);
        cbh.Label.String = '# nodes';
    end

    function plot_3d_matrix_b(ax_mat)
        this_matrix = sum(obj_singularity.tracking_3d_matrix, 3);
        max_val = ceil(max(this_matrix(:)));
        min_val = 0;
        imagesc(ax_mat, this_matrix)
        ax_mat.YLabel.String = 'singularity type';
        ax_mat.YTick = 1:num_base_sngs;
        ax_mat.YTickLabel = base_cp(:);
        ax_mat.XLabel.String = 'nodes';
        numcolors = length(0:max_val);
        colormap(ax_mat, viridis(numcolors))
        min_cval = min_val - 0.5;
        max_cval = numcolors - 0.5;
        caxis([min_cval max_cval]);
        cbh = colorbar(ax_mat, 'YTick',...
                (0:max_val),...
                'YTickLabel',int2str([0:max_val]'), 'YLim', [min_cval max_cval]);
        cbh.Label.String = '# time frames';

       
    end


end % function plot2d_singularity_occupancy()
function figure_handle = plot_singularity_count_traces(sing_count)

% This function plots the traces of the singularity counts
%
%
% ARGUMENTS:
%        sing_count -- a 2D array of size tpts x num_singularity_type
%
% OUTPUT: 
%        figure_handle 
%
% REQUIRES: 
%        s3d_get_base_singularity_list()
%        s3d_get_numlabel()
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}

        base_list = s3d_get_base_singularity_list();
        cmap_base_list = s3d_get_colours('critical-points');
        
        figure_handle = figure('Name', 'nflows-singularities-over-time');
        numsubplots = 8;
        
        % Preallocate array of graphic objects
        ax = gobjects(numsubplots, 1);
        for jj=1:numsubplots     
            ax(jj) = subplot(4, 2, jj, 'Parent', figure_handle);
            hold(ax(jj), 'on')
        end

        for jj=1:numsubplots
            stairs(ax(jj), sing_count(:, jj), 'color', cmap_base_list(jj, :), 'linewidth', 2)
            ax(jj).Title.String = base_list{jj};
            ax(jj).XLabel.String = 'time';
            ax(jj).YLabel.String = 'count';
        end
        
        linkaxes(ax, 'x')

end
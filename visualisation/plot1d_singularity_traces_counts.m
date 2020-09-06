function figure_handle = plot1d_singularity_traces_counts(singularity_counts, varargin)
% This function plots the traces of the singularity counts
%
%
% ARGUMENTS:
%        sing_count -- a 2D array of size tpts x num_singularity_type
%        varargin   -- for the time being a 1 x 2 cell array with
%                      {'Visible', 'off'}:
%
% OUTPUT: 
%        figure_handle 
%
% REQUIRES: 
%        s3d_get_base_singularity_list()
%        s3d_get_colours
%
% USAGE:
%{

%}

figure_handle{1} = plot_fun(singularity_counts, 'log');
figure_handle{2} = plot_fun(singularity_counts, 'lin');

    function figure_handle = plot_fun(singularity_counts, modality)
        base_list = s3d_get_base_singularity_list();
        cmap_base_list = s3d_get_colours('critical-points');
        
        figure_handle = figure('Name', 'nflows-singularity-count-over-time', varargin{:});
        numsubplots = 8;
        
        tpts = size(singularity_counts, 1);
        % Preallocate array of graphic objects
        ax = gobjects(numsubplots, 1);
        for jj=1:numsubplots     
            ax(jj) = subplot(4, 2, jj, 'Parent', figure_handle);
            hold(ax(jj), 'on')
        end
        
        if strcmp(modality, 'log')

        for jj=1:numsubplots
             stem(ax(jj), log10(singularity_counts(:, jj)), 'o', 'linewidth', 1.5, ...
                                                            'markerfacecolor', [0.65 0.65 0.65], ...
                                                            'markeredgecolor',cmap_base_list(jj, :), ...
                                                            'color',  cmap_base_list(jj, :), ...
                                                            'markersize', 3.4)
            ax(jj).Title.String = base_list{jj};
            ax(jj).XLabel.String = 'time';
            ax(jj).YLabel.String = [{'log_{10}'}, {'(counts)'}];
            ax(jj).XLim = [-1 tpts+1];
            ax(jj).YLim = [-0.1 2.5];
        end
        else
           for jj=1:numsubplots
%             stem(ax(jj), singularity_counts(:, jj), 'o', 'linewidth', 1.5, 'markerfacecolor', [0.65 0.65 0.65], ...
%                                                           'markeredgecolor',cmap_base_list(jj, :), ...
%                                                           'color',  cmap_base_list(jj, :), 'markersize', 3.4)
                                                      
            bar(ax(jj), singularity_counts(:, jj), 'facecolor',  cmap_base_list(jj, :), 'edgecolor', 'k')
            ax(jj).Title.String = base_list{jj};
            if jj>6 
            ax(jj).XLabel.String = 'time';
            else
                ax(jj).XLabel.String = '';
                ax(jj).XTick = [];
            end
            ax(jj).YLabel.String = '#';
            ax(jj).XLim = [-1 tpts+1];
            %ax(jj).YLim = [-0.1 2.5];
          end
        
        linkaxes(ax, 'x')
        end
    end

end
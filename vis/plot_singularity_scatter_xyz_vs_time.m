function figure_handle_xyz = plot_singularity_scatter_xyz_vs_time(singularity_list_num, null_points_3d, cp_type, varargin)
% This function plots singularities as a a function of 
% their position along one axis (X, Y, Z) vs time.
%
% ARGUMENTS:
%        singularity_list_num -- a cell array of size 1 x tpts with the numeric labels of singularities.
%        null_point_3d -- a structure of length tpts whose field contains
%                         the position of the detected singularities.
%        cp_type       -- a cell array with the str labes of the singularities we want to plot. 
%        figure_handle_xyz -- a handle to the figure with 3 subplots where
%                             we want to plot the results. Normally first
%                             call should omit this input, but passed to
%                             the function in subsequent calls.
%         varargin   -- for the time being a 1 x 2 cell array with
%                      {'Visible', 'off'}:
%
% OUTPUT: 
%        figure_handle_xyz 
%
% REQUIRES: 
%       s3d_get_numlabel()
%       s3d_get_colours()
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}

numsubplot = 3; % One for each spatial dimension

figure_handle_xyz = figure('Name', 'nflows-singularities-over-1d-space-time');
ax_xyz = gobjects(numsubplot);

for jj=1:numsubplot
    ax_xyz(jj) = subplot(numsubplot, 1, jj, 'Parent', figure_handle_xyz, varargin{:});
    hold(ax_xyz(jj), 'on')
end

% else 
%     ax_xyz = gobjects(numsubplot);
%     for jj=1:3
%        ax_xyz(4-jj) = figure_handle_xyz.Children(jj);
%     end
%         
% end

num_frames = length(singularity_list_num);
    
y_labels = {'X', 'Y', 'Z'};
x_labels = {'', '', 'time'};
xplot = 1;
yplot = 2;
zplot = 3;

num_sing_to_plot = length(cp_type);

% Anonymous function to get the indices of the singularity we want to plot
get_idx_cp_type = @(sing_list_frame, num_label_cp_type) find(sing_list_frame == num_label_cp_type);


for cc=1:num_sing_to_plot
    
    num_label_cp = s3d_get_numlabel(cp_type{cc});
    cmap_cp = s3d_get_colours(cp_type{cc});
        
    for tt=1:num_frames
        x = null_points_3d(1, tt).x;
        y = null_points_3d(1, tt).y;
        z = null_points_3d(1, tt).z;
        idx_cp_type = get_idx_cp_type(singularity_list_num{tt}, num_label_cp);
        plot(ax_xyz(xplot), tt*ones(length(idx_cp_type), 1), x(idx_cp_type), '.', 'markeredgecolor', cmap_cp)
        plot(ax_xyz(yplot), tt*ones(length(idx_cp_type), 1), y(idx_cp_type), '.', 'markeredgecolor', cmap_cp)
        plot(ax_xyz(zplot), tt*ones(length(idx_cp_type), 1), z(idx_cp_type), '.', 'markeredgecolor', cmap_cp)

    end
        % Limits
        offset_factor = 2; % NOTE: this should be a configurable parameter
        [ax_xyz(xplot:zplot).XLim] = deal([1 num_frames]);
        temp_lim =  ax_xyz(xplot).YLim;
        ax_xyz(xplot).YLim = [temp_lim(1)-offset_factor temp_lim(2)+offset_factor]; 
        temp_lim =  ax_xyz(yplot).YLim;
        ax_xyz(yplot).YLim = [temp_lim(1)-offset_factor temp_lim(2)+offset_factor]; 
        temp_lim =  ax_xyz(zplot).YLim;
        ax_xyz(zplot).YLim = [temp_lim(1)-offset_factor temp_lim(2)+offset_factor];
        
        % Labels
        ax_xyz(xplot).YLabel.String = y_labels{xplot}; 
        ax_xyz(xplot).XLabel.String = x_labels{xplot};
        ax_xyz(yplot).YLabel.String = y_labels{yplot}; 
        ax_xyz(yplot).XLabel.String = x_labels{yplot}; 
        ax_xyz(zplot).YLabel.String = y_labels{zplot}; 
        ax_xyz(zplot).XLabel.String = x_labels{zplot}; 
        
end
    linkaxes(ax_xyz, 'x')
end
% function plot_singularity_scatter_xyz_vs_time()

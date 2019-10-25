function sing_count = analyse_singularities(singularity_list_str, XYZ)
% This function takes as an input a matfile with the list of
% singularities, and generates plots to give an idea of their
% beahviour over time
%
%
% ARGUMENTS:
%        singularity_list_str -- singularity cell array of size 1 x tpts,
%                                with the string labels of singularities detected at each time
%                                point
%        XYZ       -- the original XYZ grid as a 2D array of size [numpoints x 3] array  
%
% OUTPUT: 
%        sing_numeric_labels -- a struct of length num_frames/timepoints
%             .numlabels     -- 
%             .color         --  
%
% REQUIRES: 
%        s3d_get_base_singularity_list()
%        s3d_get_numlabel()
%        s3d_count_singularities()
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
% PSL, QIMR 2019

% Get basic info
num_frames = length(singularity_list_str);

singularity_list_num = s3d_str2d_num_label(singularity_list_str);

% Count how many singularities of each type we have
sing_count = s3d_count_singularities(singularity_list_num);


% Plot traces of each singularity
plot_singularity_count_traces(sing_count)

% NOTE: use sing_labels, rather than the file, so we can 
% pass directly the output of this function and save ourselves a bit of
% time.
plot_singularity_scatter(singularity_list_str, sing_labels, XYZ, num_frames)


end % function analyse_singularities()


function plot_singularity_scatter(mfile_sing, sing_labels, XYZ, num_frames)
    
    cmap_base_list = s3d_get_colours('all');

    figure_handle_xyz = figure('Name', 'nflows-singularities-over-spacetime');
    numsubplot = 3; % One for each spatial dimension
    ax_xyz = gobjects(numsubplot);
    for jj=1:numsubplot
        ax_xyz(jj) = subplot(numsubplot, 1, jj, 'Parent', figure_handle_xyz);
        hold(ax_xyz(jj), 'on')
    end
    
    % Kindda hardcoded values, but at least make it idiomatic
    source_ = 1;
    spiral_source_ = 5;
    saddle_source = 3;
    saddle_source_ = 7;

    sink_ = 2;
    spiral_sink_ = 6;
    saddle_sink = 4;
    saddle_sink_ = 8; 

    xyz_idx = mfile_sing.xyz_idx;
    
    y_labels = {'X', 'Y', 'Z'};

    for ii=1:numsubplot     
        for tt=256:num_frames
            xyz = xyz_idx(1, tt).xyz_idx;  
            idx_source = find(sing_labels(tt).numlabel == source_);
            idx_spiral_source = find(sing_labels(tt).numlabel == spiral_source_);
            idx_saddle_source = find(sing_labels(tt).numlabel == saddle_source);
            idx_saddle_source_ = find(sing_labels(tt).numlabel == saddle_source_);

            idx_sink = find(sing_labels(tt).numlabel == sink_);
            idx_spiral_sink = find(sing_labels(tt).numlabel == spiral_sink_);
            idx_saddle_sink = find(sing_labels(tt).numlabel == saddle_sink);
            idx_saddle_sink_ = find(sing_labels(tt).numlabel == saddle_sink_);


            plot(ax_xyz(ii), tt*ones(length(idx_source), 1), XYZ(xyz(idx_source), ii), ...
                 '.', 'markeredgecolor', 'r')
            plot(ax_xyz(ii), tt*ones(length(idx_spiral_source), 1), XYZ(xyz(idx_spiral_source), ii), ...
                 '.', 'markeredgecolor', 'r')
            % 
            plot(ax_xyz(ii), tt*ones(length(idx_sink), 1), XYZ(xyz(idx_sink), ii), ...
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
    end
    
    ax_xyz(3).XLabel.String = 'time';
    linkaxes(ax_xyz, 'x')
end

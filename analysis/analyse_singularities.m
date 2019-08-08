function sing_labels = analyse_singularities(singularity_output, XYZ)
% This function takes as an input a matfile with the list of
% singularities, or the cell array with the singularities.
%
%
% ARGUMENTS:
%        singularity_output -- a matfile with the classified singularities
%        XYZ                -- the original XYZ grid as a 2D array of size [numpoints x 3] array  
%
% OUTPUT: 
%        sing_numeric_labels -- a struct of length num_frames/timepoints
%             .numlabels     -- 
%             .color         --  
%
% REQUIRES: 
%        get_singularity_list()
%        get_singularity_numlabel()
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
% PSL, QIMR 2019

singularity_cell = singularity_output.singularity_classification;


% Get basic info
num_frames = length(singularity_cell);
num_sing_per_frame = cellfun(@length, singularity_cell);

% Get numeric_labels and colours
sing_labels = struct([]);

for tt=1:num_frames
    if num_sing_per_frame(tt) == 0
        [sing_labels(tt).numlabel(1),  ...
         sing_labels(tt).color(1, :)] = get_singularity_numlabel([]);
    else    
        for ss=1:num_sing_per_frame(tt)
            [sing_labels(tt).numlabel(ss), ...
             sing_labels(tt).color(ss, :)] = get_singularity_numlabel(singularity_cell{tt}{ss});
        end
    end
end

% Count how many singularities of each type we have
out = count_singularities(sing_labels);

% Get string labels and singularity colourmap
singularity_list = get_singularity_list();
cmap(length(singularity_list), 4) = 0;    

for ii=1:length(singularity_list)
  [~, cmap(ii, :)] = get_singularity_numlabel(singularity_list{ii});
end

figure_handle = figure('Name', 'nflows-singularities-over-time');
for ii=1:8     
    ax(ii) = subplot(4, 2, ii, 'Parent', figure_handle);
    hold(ax(ii), 'on')
end

for ii=1:8
    stairs(ax(ii), out(:, ii), 'color', cmap(ii, 1:3), 'linewidth', 2)
    ax(ii).Title.String = singularity_list{ii};
    ax(ii).XLabel.String = 'time';
    ax(ii).YLabel.String = 'count';
end

figure_handle_xyz = figure('Name', 'nflows-singularities-over-spacetime');
for ii=1:3     
    ax_xyz(ii) = subplot(3, 1, ii, 'Parent', figure_handle_xyz);
    hold(ax_xyz(ii), 'on')
end

%linkaxes([ax_xyz(1), ax_xyz(2), ax_xyz(3)], 'x')

% Kindda hardcoded values, but at least make it idiomatic
source_ = 1;
spiral_source_ = 5;
saddle_source = 3;
saddle_source_ = 7;

sink_ = 2;
spiral_sink_ = 6;
saddle_sink = 4;
saddle_sink_ = 8; 

% 
xyz_idx = singularity_output.xyz_idx;

for tt=1:num_frames
    xyz = xyz_idx(1, tt).xyz_idx;  
    for ii=1:3
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
             '.', 'markeredgecolor', cmap(saddle_sink, 1:3))
        plot(ax_xyz(ii), tt*ones(length(idx_saddle_sink_), 1), XYZ(xyz(idx_saddle_sink_), ii), ...
             '.', 'markeredgecolor', cmap(saddle_sink, 1:3)) 
        
        plot(ax_xyz(ii), tt*ones(length(idx_saddle_source), 1), XYZ(xyz(idx_saddle_source), ii), ...
             '.', 'markeredgecolor', cmap(saddle_source, 1:3))
        plot(ax_xyz(ii), tt*ones(length(idx_saddle_source_), 1), XYZ(xyz(idx_saddle_source_), ii), ...
             '.', 'markeredgecolor', cmap(saddle_source, 1:3)) 
       
         
        ax_xyz(ii).YLim = [-max(abs(XYZ(:, ii))) max(abs(XYZ(:, ii)))];

    end
        
end

end % function analyse_singularities()

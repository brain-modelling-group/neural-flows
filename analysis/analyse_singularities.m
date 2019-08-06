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
%                           .numlabels
%                           .color
%        <output2> -- <description>
%
% REQUIRES: 
%        get_singularity_list()
%        get_singularity_numlabel()
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
%

if ~iscell(singularity_output)
    singularity_cell = singularity_output.singularity_classification;
else
    singularity_cell = singularity_output;
    clear singularity_output
end

% Get basic info
num_frames = length(singularity_cell);
num_sing_per_frame = cellfun(@length, singularity_cell);

% Get numeric_labels and colours
sing_labels = struct([]);
for tt=1:num_frames
    for ss=1:num_sing_per_frame(tt)
     [sing_labels(tt).numlabel(ss), ...
      sing_labels(tt).color(ss, :)] = get_singularity_numlabel(singularity_cell{tt}{ss});
    end
end

% Count how many singularities of each type we have
out = count_singularities(num_label);

% Get string labels and singularity colourmap
singularity_list = get_singularity_list();
cmap(length(singularity_list), 4) = 0;             
for ii=1:length(singularity_list)
  [~, cmap(ii, :)] = get_singularity_numlabel(singularity_list{ii});
end

% figure_handle = figure;
% for ii=1:size(out, 2)
%     ax(ii) = subplot(8, 2, ii);
%     hold(ax(ii), 'on')
% end
% 
% 
% for ii=1:size(out, 2)
% stairs(ax(ii), out(:, ii), 'color', cmap(ii, 1:3), 'linewidth', 2)
% ax(ii).Title.String = singularity_list{ii};
% end


end % function analyse_singularities()

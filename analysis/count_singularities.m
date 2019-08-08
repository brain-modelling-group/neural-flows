function out = count_singularities(sing_numeric_labels)
% A wrapper function to count how many singularities of each type
% we have in the input structure.
%
%
% ARGUMENTS:
%        sing_numeric_labels -- a struct of length num_frames/timepoints
%                           .numlabels
%                           .color
%        <arg2> -- <description>
%
% OUTPUT: 
%        <output1> -- <description>
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

% NOTE: Hardcoded ==> we may end up with more types
base_singularity_list_str = get_singularity_list();

base_singularity_list_numeric(length(base_singularity_list_str)) = 0;

% Get singularity numeric label assigned to each singularity string label 
for ss=1:length(base_singularity_list_str)
    base_singularity_list_numeric(ss) = get_singularity_numlabel(base_singularity_list_str{ss});
end

out = zeros(length(sing_numeric_labels), length(base_singularity_list_numeric));

for tt=1:length(sing_numeric_labels)
    [counts,~] = hist(sing_numeric_labels(tt).numlabel, base_singularity_list_numeric);
    out(tt, :) = counts;
end

end % function count_singularities()

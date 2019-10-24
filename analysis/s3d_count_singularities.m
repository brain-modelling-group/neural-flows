function out = s3d_count_singularities(singularity_classification_num_list)
% A wrapper function to count how many singularities of each type
% we have in the input structure.
% s3d_count_singularities
%
% ARGUMENTS:
%        singularity_classification_num_list -- a cell array of siz 1 x tpts
%
% OUTPUT: 
%        <output1> -- <description>
%        <output2> -- <description>
%
% REQUIRES: 
%        s3d_get_singularity_list()
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
%

base_singularity_num_list = cellfun(@(x) s3d_get_numlabel(x), s3d_get_singularity_list());

out = zeros(length(singularity_classification_num_list), length(base_singularity_num_list));

for tt=1:length(singularity_classification_num_list)
    [counts, ~] = hist(singularity_classification_num_list{tt}, base_singularity_num_list);
    out(tt, :) = counts;
end

end % s3d_count_singularities()

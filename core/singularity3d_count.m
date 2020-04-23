function singularity_count = singularity3d_count(classification_cell)
% A wrapper function to count how many singularities of each type
% we have in the input structure.
% s3d_count_singularities
%
% ARGUMENTS:
%        classification_cell -- a cell array of siz 1 x tpts
%
% OUTPUT: 
%        
%        <output2> -- <description>
%
% REQUIRES: 
%        s3d_get_numlabel()
%        s3d_get_base_singularity_list()
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
%

base_singularity_num_list = cellfun(@(x) s3d_get_numlabel(x), s3d_get_base_singularity_list());
singularity_count = zeros(length(classification_cell), length(base_singularity_num_list));

for tt=1:length(classification_cell)
    [counts, ~] = hist(classification_cell{tt}, base_singularity_num_list);
    singularity_count(tt, :) = counts;
end

end % singularity3d_count()

function singularity_count = singularity3d_count(classification_cell_num, base_singularity_num_list)
% A wrapper function to count how many singularities of each type
% we have in the input structure.
% s3d_count_singularities
%
% ARGUMENTS:
%        classification_cell -- a cell array
%
% OUTPUT: 
%        
%        <output2> -- <description>
%
% REQUIRES: 

%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
%


    [singularity_count, ~] = hist(classification_cell_num, base_singularity_num_list);


end % singularity3d_count()

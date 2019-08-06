function out = count_singularities(sing_numeric_labels)
% <ShortDescription>
%
%
% ARGUMENTS:
%        numeric_labels -- <description>
%        <arg2> -- <description>
%
% OUTPUT: 
%        <output1> -- <description>
%        <output2> -- <description>
%
% REQUIRES: 
%        get_singularity_list()
%        map_str2int()
%
% USAGE:
%{
    <example-commands-to-make-this-function-run>
%}
%

% NOTE: Hardcoded ==> we may end up with more types
singularity_list = get_singularity_list();

types_of_singularity(length(singularity_list)) = 0;

% Get singularity numeric label assigned to each singularity string label 
for ss=1:length(singularity_list)
    types_of_singularity(ss) = get_singularity_numlabel(singularity_list{ss});
end

out = zeros(length(numeric_labels), length(types_of_singularity));

for tt=1:length(sing_numeric_labels)
    [counts,~] = hist(sing_numeric_labels(tt).label, types_of_singularity);
    out(tt, :) = counts;
end

end % function count_singularities()

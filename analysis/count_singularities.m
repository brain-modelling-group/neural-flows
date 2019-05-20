function out = count_singularities(numeric_labels)

% NOTE: Hardcoded ==> we may end up with more types

singularity_list = get_singularity_list();

types_of_singularity(length(singularity_list)) = 0;
for ss=1:length(singularity_list)
    types_of_singularity(ss) = map_str2int(singularity_list{ss});
end

out = zeros(length(numeric_labels), length(types_of_singularity));

for tt=1:length(numeric_labels)
    
    [counts,~] = hist(numeric_labels(tt).label, types_of_singularity);
    out(tt, :) = counts;

end

end % function count_singularities()

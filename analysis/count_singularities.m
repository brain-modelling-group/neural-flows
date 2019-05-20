function out = count_singularities(numeric_labels)


% NOTE: Hardcoded ==> we may end up with more types
types_of_singularity = 0:13;

out = zeros(length(numeric_labels), length(types_of_singularity));

for tt=1:length(numeric_labels)
    
    [counts,~] = hist(numeric_labels(tt).label, types_of_singularity);
    out(tt, :) = counts;

end

end % function count_singularities

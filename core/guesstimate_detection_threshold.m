function [detection_threshold] = guesstimate_detection_threshold(data)
% Ad hoc way of guesstimating threshold for detecting singularities.

%[~, edges] = histcounts(data);

% discard first edge
% data assumed to be a sequence of minimum values of the vector field norm 
detection_threshold = [0; median(data)];

end % function guesstimate_detection_theshold()
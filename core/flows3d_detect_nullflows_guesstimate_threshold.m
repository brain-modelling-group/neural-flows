function [detection_threshold] = flows3d_detect_nullflows_guesstimate_threshold(data)
% Ad hoc way of guesstimating threshold for detecting singularities.

%[~, edges] = histcounts(data);

% discard first edge
% data assumed to be a sequence in time of the minimum values of the vector field norm 
detection_threshold = [0; median(data)];

end % function guesstimate_detection_theshold()

function [detection_threshold] = guesstimate_detection_threshold(data)
% Ad hoc way of guesstimating threshold for detecting singularities.

[~, edges] = histcounts(data);

% discard first edge

detection_threshold = [edges(2); edges(3)];

end % function guesstimate_detection_theshold()
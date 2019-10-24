function [singularity_classification_num_list] = s3d_str2num_label(singularity_classification_str_list)
% This function maps singularity human-readable string labels inside the 
% cell array into integer numbers for quantitative classification,
%
% ARGUMENTS:
%        sing_label -- a string specifying the type of hyperbolic singularity.
%                     Options: {'source', ...
%                    'sink', ...
%                    'spiral-source',... 
%                    'spiral-sink',...
%                    '1-2-saddle',... 
%                    '2-1-saddle',...
%                    '1-2-spiral-saddle', ...
%                    '2-1-spiral-saddle', ...
%                    'source-po',...         % untested
%                    'sink-po',...           % untested
%                    'saddle-po',...         % untested
%                    'twisted-po',...        % untested
%                    'spiral-source-po',...  % untested
%                    'spiral-sink-po', ...   % untested
%                    '1-1-0-saddle', ...     % untested
%                    'nan', 'empty', 'unknown'};                
%
% OUTPUT: 
%        sing_numeric_labelr -- an integer
%
% REQUIRES: 
%        s3d_get_num_label
% USAGE:
%{
    
%}
% AUTHOR: Paula Sanz-Leon, QIMR February 2019 

tpts = size(singularity_classification_str_list, 2);
singularity_classification_num_list = cell(size(singularity_classification_str_list));

for tt=1:tpts
     
    singularity_classification_num_list{tt} = cellfun(@(x) s3d_get_numlabel(x), singularity_classification_str_list{tt});

end

end
% function s3d_str2num_label()

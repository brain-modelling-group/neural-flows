function [singularity_classification_num_list] = s3d_str2num_label(singularity_classification_str_list)
% This function maps singularity human-readable string labels inside the 
% cell array into integer numbers for quantitative classification,
%
% ARGUMENTS:
%        singularity_classification_str_list -- a celll array of size 1 x
%        tpts, where each element is a cell array of different size
%        depending on how many singularities where found.
%
% OUTPUT: 
%        singularity_classification_num_list -- a cell array of the same
%        size as singularity_classification_str_list, but with numeric
%        labels.
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

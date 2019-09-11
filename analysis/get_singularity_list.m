function singularity_list = get_singularity_list()
% This is kind of a dummy function that returns the list with available 
% types of singularities in the classification functions. 
%
%
% ARGUMENTS:
%        None
%       
%
% OUTPUT: 
%        singularity_list -- a cell array with human readbale string, with 
%                            the names of 3D hyperbolic singularities. 
%
% REQUIRES: 
%       None
% USAGE:
%{
    
%}
%
% NOTE TO SELF: Check with function map_str2int()

singularity_list = {'source', ...
                    'sink', ...
                    '2-1-saddle',...
                    '1-2-saddle',... 
                    'spiral-source',... 
                    'spiral-sink',...
                    '2-1-spiral-saddle', ...
                    '1-2-spiral-saddle', ...
                    'source-po',...
                    'sink-po',...
                    'saddle-po',...
                    'twisted-po',...
                    'spiral-source-po',...
                    'spiral-sink-po', ...
                    '1-1-0-saddle', ... % unclassified
                    'nan'}; % unclassified
                
end % function get_singularity_list()

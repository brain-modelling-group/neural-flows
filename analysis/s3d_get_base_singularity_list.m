function singularity_list = s3d_get_singularity_list()
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
% NOTE TO SELF: Check this list is consitent with s3d_get_numlabel()

singularity_list = {'source', ...
                    'sink', ...
                    'spiral-source',... 
                    'spiral-sink',...
                    '1-2-saddle',... 
                    '2-1-saddle',...
                    '1-2-spiral-saddle', ...
                    '2-1-spiral-saddle', ...
                    'source-po',...         % untested
                    'sink-po',...           % untested
                    'saddle-po',...         % untested
                    'twisted-po',...        % untested
                    'spiral-source-po',...  % untested
                    'spiral-sink-po', ...   % untested
                    '1-1-0-saddle', ...     % untested
                    'nan', ...
                    'boundary', ...
                    'empty'};                
                
end % function s3d_get_singularity_list()

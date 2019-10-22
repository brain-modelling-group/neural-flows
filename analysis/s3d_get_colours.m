function [color] = s3d_get_colours(sing_label)
% This function maps singularity human-readable labels, expressed as strings or
% integer numbers into the predefined colour for that singularity type. 
%
% ARGUMENTS:
%        sing_label -- a string or integer specifying the type of hyperbolic singularity.
%
% OUTPUT: 
%        colour -- a  1 x 4 vector whose values correspond to [r, g, b, alpha]
%
% REQUIRES: 
%        None
% USAGE:
%{
    
%}
% AUTHOR: Paula Sanz-Leon, QIMR September 2019 

if isempty(sing_label)
    sing_str_label = 'empty';
end
switch sing_str_label
    % FIXED POINTS
    case {'source', 1} 
        color = [165, 0, 38, 1];
    case {'sink', 2}       
        color = [49, 54, 149, 1];
    case {'spiral-source', 3} % done
        color = [244, 109, 67, 1];
    case {'spiral-sink', 4}   % done
        color = [69, 117, 180, 1];
    case {'1-2-saddle', 5}    % done - more source (red) than sink m-in-n-out
        color = [253, 174, 97, 1];
    case {'2-1-saddle', 6}    % done - more sink (blue) than source
        color = [116, 173, 209, 1];
    case {'1-2-spiral-saddle', 7} % done - more source (red) than sink -- first number indicates number of directions going "IN"/sink
        color = [254 224,144, 1];
    case {'2-1-spiral-saddle', 8} % done - more sink (blue) than source
        color = [171, 217, 233, 1];        
    % ORBITS
    case {'source-po', 9}% done
        color = [197, 27, 125, 1];
    case {'sink-po', 10} % done
        color = [77, 146, 33, 1];
    case {'saddle-po', 11}
        color = [253, 224, 239, 1];
    case {'twisted-po', 12}
        color = [230, 245, 208, 1];
    case {'spiral-source-po', 13} % done
        color = [233, 163, 201, 1];
    case {'spiral-sink-po', 14}% done
        color = [161, 215, 106, 1];
    case {'1-1-0-saddle', 15} 
        color = [0 255 0 0];   % These ones may be artificial  
    case {'nan', 'orbit?', 'boundary', 'zero', 'empty', 'centre', 16}
        color = [0, 0, 0, 0];
    otherwise
        error(['neuralflows:' mfilename ':BadInput'], ...
              'Unknown singularity type');
end
color = color./255;
end
% function  s3d_get_colours()

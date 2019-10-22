function [sing_numeric_label] = s3d_get_numlabel(sing_str_label)
% This function maps singularity human-readable labels into integer numbers
% for quantitative classification.
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

if isempty(sing_str_label)
    sing_str_label = 'empty';
end
switch sing_str_label
    % FIXED POINTS
    case 'source' % done
        sing_numeric_label = 1;
    case 'sink'   % done
        sing_numeric_label = 2;
    case 'spiral-source' % done
        sing_numeric_label = 3;
    case 'spiral-sink' % done
        sing_numeric_label = 4;
    case '1-2-saddle' % done - more source (red) than sink m-in-n-out
        sing_numeric_label = 5;  
    case '2-1-saddle'   % done - more sink (blue) than source
        sing_numeric_label = 6;
    case '1-2-spiral-saddle' % done - more source (red) than sink -- first number indicates number of directions going "IN"/sink
        sing_numeric_label = 7;
    case '2-1-spiral-saddle' % done - more sink (blue) than source
        sing_numeric_label = 8;
    % ORBITS
    case 'source-po'% done
        sing_numeric_label = 9;
    case 'sink-po' % done
        sing_numeric_label = 10;
    case 'saddle-po'
        sing_numeric_label = 11;
    case 'twisted-po'
        sing_numeric_label = 12;
    case 'spiral-source-po' % done
        sing_numeric_label = 13;
    case 'spiral-sink-po'% done
        sing_numeric_label = 14;
    case {'1-1-0-saddle'} 
        sing_numeric_label = 15;
    case {'nan', 'orbit?', 'boundary', 'zero', 'empty', 'centre'}
        sing_numeric_label = 16;
    otherwise
        error(['neuralflows:' mfilename ':BadInput'], ...
           'Unrecognised singularity type');
end
end
% function s3d_get_numlabell()

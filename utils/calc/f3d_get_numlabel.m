function [flow_numeric_label] = f3d_get_numlabel(flow_str_label)
% This function maps singularity human-readable string labels into integer numbers
% for quantitative classificatio of loca flows based on curl and divergence
%
% ARGUMENTS:
%        flow_numeric_label -- a string specifying the type of local flow
%                     options: 
%     {'irrotational-zero-divergent',
%      'irrotational-divergent', 
%      'irrotational-convergent',       
%      'positive-rotational-divergent',  
%      'positive-rotational-convergent', 
%      'negative-rotational-divergent', 
%      'negative-rotational-convergent',
%      'positive-rotational-zero-divergent',
%      'negative-rotational-zero-divergent',
%      'nan', 'empty', 'boundary'} 
%
% OUTPUT: 
%        flow_numeric_label -- an integer
%
% REQUIRES: 
%        None
% USAGE:
%{
    
%}
% AUTHOR: Paula Sanz-Leon, QIMR May 2021 
switch flow_str_label
    case {'irrotational-zero-divergent'} % done
        flow_numeric_label = 0;
    case {'irrotational-divergent'}         % done
        flow_numeric_label = 1;
    case {'irrotational-convergent'}        % done
        flow_numeric_label = 2;
    case {'positive-rotational-divergent'}  % done
        flow_numeric_label = 3;
    case {'positive-rotational-convergent'} % done -
        flow_numeric_label = 4;  
    case {'negative-rotational-divergent'}  % done - 
        flow_numeric_label = 5;
    case {'negative-rotational-convergent'} % done -
        flow_numeric_label = 6;
    case {'positive-rotational-zero-divergent'} % done - 
        flow_numeric_label = 7;
    case {'negative-rotational-zero-divergent'}% done
        flow_numeric_label = 8;
    case {'nan', 'empty', 'boundary'} % done
        flow_numeric_label = 9;
    otherwise
        error(['neural-flows::' mfilename '::BadInput'], ...
               'Unrecognised local flow type');
end
end
% function f3d_get_numlabell()

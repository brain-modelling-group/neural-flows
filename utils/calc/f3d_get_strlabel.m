function [flow_string_label] = f3d_get_strlabel(flow_num_label)
% This function maps flow numeric labels into human-readbale strings 
% for quantitative classificatio of local flows based on curl and divergence
%
% ARGUMENTS:
%        flow_num_label -- an integer specifying the type of local flow
%        options: 
%     {0: 'irrotational-zero-divergent',
%      1: 'irrotational-divergent', 
%      2: 'irrotational-convergent',       
%      3: 'positive-rotational-divergent',  
%      4: 'positive-rotational-convergent', 
%      5: 'negative-rotational-divergent', 
%      6: 'negative-rotational-convergent',
%      7: 'positive-rotational-zero-divergent',
%      8: 'negative-rotational-zero-divergent',
%      9: 'nan', 'empty', 'boundary'} 
%
% OUTPUT: 
%        flow_string_label -- a 1x1 cell with a string label
% REQUIRES: 
%        None
% USAGE:
%{
    
%}
% AUTHOR: Paula Sanz-Leon, QIMR May 2021 
switch flow_num_label
    case 0
        flow_string_label = {'irrotational-zero-divergent'};
    case 1
        flow_string_label = {'irrotational-divergent'};
    case 2
        flow_string_label = {'irrotational-convergent'};  
    case 3
        flow_string_label = {'positive-rotational-divergent'};      % done
    case 4
        flow_string_label = {'positive-rotational-convergent'};     % done -
    case 5
        flow_string_label = {'negative-rotational-divergent'};      % done - 
    case 6
        flow_string_label = {'negative-rotational-convergent'};     % done -
    case 7
        flow_string_label = {'positive-rotational-zero-divergent'}; % done - 
    case 8
        flow_string_label = {'negative-rotational-zero-divergent'};% done
    case 9
        flow_string_label = {'nan'}; % done
    otherwise
        error(['neural-flows::' mfilename '::BadInput'], ...
               'Unrecognised local flow numeric type');
end
end
% function f3d_get_strlabell()

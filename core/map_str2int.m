function [label, color] = map_str2int(str_label)
% This function maps singularity human-readable labels into integer numbers
% for quantitative classification.

% Classification of stationary points in 3D
% l1, l2, l3 are eigenvalues of the jacbian
% If l1, l2, l3 are all real then:
%    all positive > source
%    all negative > sink
%    1 positive, 2 negative > 1:2 saddle
%    2 positive, 1 negative > 2:1 saddle
% If one eigenvalue is real and the two imaginary eigenvalues are complex
% conjugates (a+ib, a-ib):
%    if real eigenvalue > 0
%                      if a > 0 --> spiral source
%                      if a < 0 --> spiral saddle  
%    if real eigenvalue < 0
%                      if a > 0 --> spiral saddle
%                      if a < 0 --> spiral sink
% ORBITS
% Hyperbolic periodic orbits in 3D can be classified as follows:
% Two real eigenvalues (one complex):
%  If real eigenvalues inside the unit circle:   source p.o 
%                      both outside unit circle: sink p.o
%                      one inside, two outside: 
%                                             both positive: saddle p.o                    
%                                             bith negative: twisted p.o
% One real eigenvalue, two complex conjugate:
% complex eigenvalues outside the unit circle : spiral source p.o
% complex eigenvalues inside the unit circle  : spiral sink p.o

switch str_label
    % FIXED POINTS
    case 'source' % done
        label = 1;
        color = [165, 0, 38, 1];
    case 'sink'   % done
        label = 2;
        color = [49, 54, 149, 1];
    case '2-1-saddle' % done - more source (red) than sink
        label = 3;
        color = [244, 109, 67, 1];
    case '1-2-saddle'   % done - more sink (blue) than source
        label = 4;
        color = [69, 117, 180, 1];
    case 'spiral-source' % done
        label = 5;  
        color = [253, 174, 97, 1];
    case 'spiral-sink' % done
        label = 6;
        color = [116, 173, 209, 1];
    case '2-1-spiral-saddle' % done - more source (red) than sink
        label = 7;
        color = [254 224,144, 1];
    case '1-2-spiral-saddle' % done - more sink (blue) than source
        label = 8;
        color = [171, 217, 233, 1];        
    % ORBITS
    case 'source-po'% done
        label = 9;
        color = [197, 27, 125, 1];
    case 'sink-po' % done
        label = 10;
        color = [77, 146, 33, 1];
    case 'saddle-po'
        label = 11;
        color = [253, 224, 239, 1];
    case 'twisted-po'
        label = 12;
        color = [230, 245, 208, 1];
    case 'spiral-source-po' % done
        label = 13;
        color = [233, 163, 201, 1];
    case 'spiral-sink-po'% done
        label = 14;
        color = [161, 215, 106, 1];
    case {'1-1-0-saddle'} 
        label = 15;
        color = [0 255 0 0];   % These ones may be artificial  
    case {'nan', 'orbit?', 'boundary', 'zero'}
        label = 16;
        color = [0, 0, 0, 0];
    otherwise
        error(['neuralflows:' mfilename ':BadInput'], ...
           'Unrecognised singularity type');
end
color = color./255;
end
% function map_str2int()

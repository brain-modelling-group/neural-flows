function [label, color] = map_str2int(str_label)
% This funciton maps singularity human readbale labels into integer numbers
% for quantitative purposed better classification.

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
    case 'source'
        label = 1;
    case 'sink'
        label = 2;
    case '1-2-saddle'
        label = 3;
    case '2-1-saddle'
        label = 4;
    case 'nan'
        label = nan;
    case 'spiral-source'
        label = 5;
    case 'spiral-sink'
        label = 6;
    case 'source-po'
        label = 7;
    case 'sink-po'
        label = 8;
    case 'saddle-po'
        label = 9;
    case 'twisted-po'
        label = 10;
    case 'spiral-source-po'
        label = 11;
    case 'spiral-sink-po'
        label = 12;      
    otherwise
        error(['neuralflows:' mfilename ':BadInput'], ...
           'The input xyz_idx must be a N x 3 array');
        


end
% function map_str2int()

function c = nanconvn(A, B, varargin)
% NANCONVN Convolution in ND ignoring NaNs.
%   C = NANCONV(A, K) convolves A and K, correcting for any NaN values
%   in the input vector A. The result is the same size as A (as though you
%   called 'conv' or 'conv2' with the 'same' shape).
%
%   C = NANCONV(A, K, 'param1', 'param2', ...) specifies one or more of the following:
%     'edge'     - Apply edge correction to the output.
%     'noedge'   - Do not apply edge correction to the output (default).
%     'nanout'   - The result C should have NaNs in the same places as A.
%     'nonanout' - The result C should have ignored NaNs removed (default).
%                  Even with this option, C will have NaN values where the
%                  number of consecutive NaNs is too large to ignore.
%     'nd'       - Treat the input vectors as ND matrices (default).
%     '1d'       - Treat the input vectors as 1D vectors.
%                  This option only matters if 'a' or 'k' is a row vector,
%                  and the other is a column vector. Otherwise, this
%                  option has no effect.
%
%   NANCONV works by running 'conv2' either two or three times. The first
%   time is run on the original input signals A and K, except all the
%   NaN values in A are replaced with zeros. The 'same' input argument is
%   used so the output is the same size as A. The second convolution is
%   done between a matrix the same size as A, except with zeros wherever
%   there is a NaN value in A, and ones everywhere else. The output from
%   the first convolution is normalized by the output from the second 
%   convolution. This corrects for missing (NaN) values in A, but it has
%   the side effect of correcting for edge effects due to the assumption of
%   zero padding during convolution. When the optional 'noedge' parameter
%   is included, the convolution is run a third time, this time on a matrix
%   of all ones the same size as A. The output from this third convolution
%   is used to restore the edge effects. The 'noedge' parameter is enabled
%   by default so that the output from 'nanconv' is identical to the output
%   from 'conv2' when the input argument A has no NaN values.
%
% Based on nanconv from: 
% AUTHOR: Benjamin Kraus (bkraus@bu.edu, ben@benkraus.com)
% Copyright (c) 2013, Benjamin Kraus
% $Id: nanconv.m 4861 2013-05-27 03:16:22Z bkraus $

% Process input arguments
    for arg = 1:nargin-2
        switch lower(varargin{arg})
            case 'edge' 
                 edge = true;           % Apply edge correction
            case 'noedge' 
                 edge = false;          % Do not apply edge correction
            case {'same','full','valid'} 
                 shape = varargin{arg}; % Specify shape
            case 'nanout'
                 nanout = true;         % Include original NaNs in the output.
            case 'nonanout' 
                 nanout = false;        % Do not include NaNs in the output.
            case {'2d','is2d', 'nd', '3d'} 
                 is1D = false;          % Treat the input as ND
            case {'1d','is1d'} 
                is1D = true;            % Treat the input as 1D
        end
    end

    % Apply default options when necessary.
    if ~exist('edge','var') 
        edge = true; 
    end

    if ~exist('nanout','var')
        nanout = true; 
    end

    if ~exist('is1D','var') 
        is1D = false; 
    end

    if ~exist('shape','var') 
        shape = 'same';    
    elseif(~strcmp(shape,'same'))
        error([mfilename ':NotImplemented'],'Shape ''%s'' not implemented', shape);
    end

    % Get the size of 'A' for use later.
    array_shape = size(A);

    % If 1D, then convert them both to columns.
    % This modification only matters if 'a' or 'k' is a row vector, and the
    % other is a column vector. Otherwise, this argument has no effect.
    if(is1D)
        if(~isvector(A) || ~isvector(B))
            error('MATLAB:conv:AorBNotVector','A and B must be vectors.');
        end
        A = A(:); 
        B = B(:);
    end

    % Flat function for comparison.
    o  = ones(array_shape);

    % Flat function with NaNs for comparison.
    on = ones(array_shape);

    % Find all the NaNs in the input.
    nan_idx = isnan(A);

    % Replace NaNs with zero, both in 'A' and 'on'.
    A(nan_idx)  = 0;
    on(nan_idx) = 0;

    % Check that the filter does not have NaNs.
    if(any(isnan(B)))
        error([mfilename ':NaNinFilter'],'Filter (B) contains NaN values.');
    end

    % Calculate what a 'flat' function looks like after convolution.
    if(any(nan_idx(:)) || edge)
        flat = convn(on, B, shape);
    else
        flat = o;
    end

    % The line above will automatically include a correction for edge effects,
    % so remove that correction if the user does not want it.
    if(any(nan_idx(:)) && ~edge)
        flat = flat./convn(o, B, shape); 
    end

    % Do the actual convolution
    c = convn(A, B, shape)./flat;

    % If requested, replace output values with NaNs corresponding to input.
    if(nanout); c(nan_idx) = NaN; end

    % If 1D, convert back to the original shape.
    if(is1D && arrray_shape(1) == 1) 
        c = c.'; 
    end

end % function nanconvn()


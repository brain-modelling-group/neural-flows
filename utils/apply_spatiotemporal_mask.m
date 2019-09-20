function wave = spatiotemporal_masks(wave, Aspace, Atime)
% spatiotemporal_masks. Apply separate spatial and temporal amplitude
% profiles to a wave 2D+t pattern
% INPUTS:
%   - wave: X x Y x T matrix of a real or complex wave pattern
%   - Aspace: scalar or X x Y matrix giving spatial amplitude profile
%   - Atime: scalar or vector with length T giving temporal amplitude
%       profile

% Apply spatial amplitude
if nargin>1 && ~isempty(Aspace)
    if isscalar(Aspace)
        wave = Aspace * wave;
    elseif ismatrix(Aspace) && size(Aspace,1)==size(wave,1) && ...
            size(Aspace,2)==size(wave,2)
        wave = bsxfun(@times, Aspace, wave);
    else
        error('Invalid dimensions of Aspace!')
    end
end

% Apply temporal amplitude
if nargin>2 && ~isempty(Atime)
    if isscalar(Atime)
        wave = Atime * wave;
    elseif isvector(Atime) && length(Atime)==size(wave,3)
        Atime = permute(Atime(:), [2, 3, 1]);
        wave = bsxfun(@times, Atime, wave);
    else
        error('Invalid dimensions of Atime!')
    end
end

end

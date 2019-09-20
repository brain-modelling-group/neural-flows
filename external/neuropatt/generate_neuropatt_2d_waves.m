function [wave, pattType] = generate_neuropatt_2d_waves(gridSize, pattType, amp, ...
    freq, wavelength, loc, vel, gausswidth)
% GENERATEPATTERN generates a custom wave pattern based on inputs
% INPUTS:
%   - gridSize: 3 element vector [NX NY NT] giving the x, y, and time
%       dimensions of the grid underlying the wave pattern
%   - pattType: string giving the type of pattern to create, 'plane'
%       for plane wave, 'sink' for sink pattern, 'source' for source
%       pattern, 'spiral' for spiral wave, or 'saddle' for saddle pattern.
%       'random' picks a random critical point pattern.
%   - amp: scalar specifying the maximum amplitude of the wave
%   - freq: scalar specifying the wave oscillation frequency (per time
%       step)
%   - wavelength: scalar specifying the spatial wavelength of patterns (in
%       grid spaces)
%   - loc: 2 element vector [X0, Y0] giving the x-y coordinates of the
%       pattern centre
%   - vel: 2 element vector [VX, VY] giving the displacement per time step
%       of pattern centre (or plane wave front)
%   - gausswidth: scalar giving the full width at half maxiumum of the
%       Gaussian amplitude mask applied around the pattern centre. If not
%       supplied, amplitude will be uniform
% OUTPUTS:
%   - wave: NX x NY x NT matrix of complex numbers containing specified
%       wave pattern activity

%% Process inputs
% If pattern type is 'random', return a random critical point type
if strcmp(pattType, 'random')
    pattList = {'sink', 'source', 'spiral', 'saddle'};
    pattType = pattList{randi(length(pattList))};
end

% Create grid of coordinates
hx = 0.5;
hy = 0.5;
ht = 0.5;
[x, y, t] = meshgrid(1:hx:gridSize(1), 1:hy:gridSize(2), 1:gridSize(3));

% Convert parameters into more useful quantities
% Angular frequency
w = 2*pi*freq;
% Wavenumber
k = 2*pi/wavelength;
% Gaussian width parameter
if exist('gausswidth', 'var') && isscalar(gausswidth) && gausswidth~=0
    c = gausswidth / (2*sqrt(2*log(2)));
end

% Set velocity as zero by default if not specified
if ~exist('vel', 'var') || isempty(vel)
    vel = [0 0];
end

% A source pattern is just a sink pattern with negative frequency
if strcmp(pattType, 'source')
    pattType = 'sink';
    w = -w;
end

%% Generate wave
switch pattType
    case 'plane'
        % Plane wave
        vel = vel/abs(sum(vel)); % Ensure direction sums to 1
        wave = exp(1i * (w*t + k*(vel(1)*x + vel(2)*y)));
        
    case 'sink'
        % Sink pattern
        wave = exp(1i * (w*t + k*sqrt((x-loc(1)-vel(1)*t).^2 + ...
            (y-loc(2)-vel(2)*t).^2)));
        
    case 'spiral'
        % Spiral wave
        wave = exp(1i*(-w*t + ...
            angle(x-loc(1)-vel(1)*t + 1i*(y-loc(2)-vel(2)*t)) - ...
            k*sqrt((x-loc(1)-vel(1)*t).^2 + (y-loc(2)-vel(2)*t).^2)...
            ));
        
    case 'saddle'
        % Saddle pattern
        wave = exp(1i * (-w*t + k*abs(x-loc(1)-vel(1)*t) - ...
            k*abs(y-loc(2)-vel(2)*t)));
        
    otherwise
        error('Invalid pattern type!')
end

%% Apply amplitude mask
% Ensure that wave has equal amplitude everywhere
wave(wave~=0) = amp * wave(wave~=0) ./ abs(wave(wave~=0));

% Apply gaussian mask around centre location if specified
if exist('c', 'var')
    gaussian = @(c, loc) exp(-1/(2*c^2) * (((x(:,:,1)-loc(1)).^2 + ...
        (y(:,:,1)-loc(2)).^2)));
    wave = addAmplitudeProfiles(wave, gaussian(c, loc));
end

% Ensure that the maximum amplitude is still AMP
wave = wave / max(abs(wave(:))) * amp;


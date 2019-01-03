function [activity_pattern] = generate_demo_data(data_type, singularity_type)
% kinematic singularities (0 of the velocity field)
% generate_demo_data generates activity data in a variety of spatiotemporal
% domains for testing purposes.
% This is not meant to be a general function, but to have light weight
% examples of every modality, woth known solutions.
% Dimensions are based on 'average values' for the modalities
% Example: 
% EEG: sensors: 64 channels, fs: 1024Hz; epoch length 4 seconds
% MEG: sensors: 256 channels, fs: 2048;  epoch length 4 seconds
% fMRI: x, Y, Z: 96, 128, 116, fs: 1/TR with TR=0.8 s, epoch length: 8 min/384 seconds  the different size in each dimension is to avoid confusion ib the plotting routines. 
% ECoG grid: TBD
% LFP: X, Y, 32, 64, fs:256Hz, epoch length: 10s. -- This is the generic for
% rectangular grids
% VSDI: TBD
% BNM: X, Y, Z: coordinates of N nodes, nodes 512, fs: 1024 hz-- normally
% it's dt but it has to be downsampled
% MESH: X, Y, Z, coordinates of N vertices, vertex: 16384, fs: 512Hz 
% Units can be interpreted as mm/ms or m/s -- eg speed: 10 is m/s or mm/ms
% If your units are expressed in m/ms, first convert it to m/s or mm/ms

% NOTE: tested and developed in matlab 2018b

% INPUTS:
%   - data_type.main_type: string {'eeg', 'meg', 'fmri', 'ecog', 'lfp', 'vsdi', 'bnm', 'mesh'}
%   - data_type.sub_type: only necessary for mesh string {'sphere', 'cortex'}
%   - data_type.xyz: locations of each point of the grid ( [nodes x2, nodes
%   x3]) (optional)
%   - data_type.xyz_shape: size of the grid along each dimension
%   - data_type.t  : time vector (optional) - better create this ? rather
%                                             than having large arrays in a structure?
%   - data_type.t_shape: size of the temporal dimension in samples ()
%   - data_type.ds : spatial sampling interval -- identical for all dimensions ()
%   - data_type.dt : temporal sampling interval ()  
%   - data_type.fs : temporal sampling frequency Hz
%   - data_type.ks : spatial sampling frequency

%   - singularity_type.list: {'sink', 'source', 'spiral', 'saddle'}
%   - gives the type of pattern to create / 'random' picks a random critical pattern.
%   - singularity_type.freq: temporal oscillation frequency (in Hz), either
%     a scalar or a vector
%   - singularity_type.lambda: scalar specifying the spatial wavelength of the singularity in m or mm
%   - singularity_type.centroids: cell with 2 or 3 element vectors giving
%   the xyz coordinates of the singularity centre
%   - singularity_type.velocity:  cell with 2 or 3 element vectors giving the
%     vx, vy, and vz components of the velocity.
%   - gausswidth: scalar giving the full width at half maxiumum of a
%       Gaussian mask applied around the pattern centre.
% OUTPUTS:
% activity_pattern: NX x NY x NT matrix of complex numbers containing specified wave pattern activity

%% Process inputs
% If singularity type is 'random', return a random critical point type


switch data_type.main_type
    case {'vsd', 'vsdi', 'lfp', 'ecog', 'rectangular', 'square'}       
        [activity_pattern] = generate_activity_2d_rectangular(data_type, singularity_type);
    
    case {'eeg', 'meg'}
        [activity_pattern] = generate_activity_2d_disk(data_type, singularity_type);
    
    case {'fmri', 'bnm'}
        [activity_pattern] = generate_activity_3d_unstructured(data_type, singularity_type);
    
    case {'mesh'}
        [activity_pattern] = generate_activity_2d_unstructured(data_type, singularity_type);
    
    otherwise
        error(['patchflow:' mfilename ':NotImplemented'], ...
                       'Unknown data type. Sorry.');
        
end

end % function % generate_demo_data()

% case LFP or VSDI ECOG (may need interpolation)
function [activity_pattern] = generate_activity_2d_rectangular(data_type, singularity_type)

    % Singularity list for rectangular domains 
    singularity_list = {'sink', 'source', 'spiral', 'saddle'};

    if length(singularity_type.list) == 1 && strcmp(singularity_type.list, 'random')
       singularities = singularity_list{randi(length(singularity_list))};
    else
       singularities = singularity_type.list;
    end 
    
    % NOTE: The grid coordinates will be centred at half the sampling interval --
    % makes it easier for the treatment of periodic boundary conditions
    half_ds = data_type.ds / 2;

    % NOTE: Time starts at dt
    [x, y, t] = meshgrid((1:data_type.xyz_shape(1))*data_type.ds - half_ds, ...
                         (1:data_type.xyz_shape(2))*data_type.ds - half_ds, ...
                         (1:data_type.t_shape)*data_type.dt);
    
    % Idiomatic indexing for space
    xdim = 1;
    ydim = 2;
        
    % Check if we want a gaussian window around the singularity
    % Gaussian width parameter
    if isscalar(singularity_type.gausswidth) && singularity_type.gausswidth~=0
       c = singularity_type.gausswidth / (2*sqrt(2*log(2)));
       gaussian_handle = @(c, loc) exp(-1/(2*c^2) * (((x(:,:,1)-loc(1)).^2 + (y(:,:,1)-loc(2)).^2)));
    else
       gaussian_handle = @(c, loc) 1;
    end
             
    % Pre-allocate space; 
    activity_pattern = zeros(size(x));
    for this_singularity=1:length(singularities)
        % Angular frequency
        w = 2*pi*singularity_type.freq(this_singularity);
        % Angular wavenumber
        k = 2*pi/singularity_type.wavelength(this_singularity);
        
        % A source pattern is just a sink pattern with negative frequency
        if strcmp(singularities{this_singularity}, 'source')
           w = -w;
        end
        
        loc = singularity_type.centroids(this_singularity);

        vel = singularity_type.vel{this_singularity};
        

        switch singularities{this_singularity}
            case 'plane'
                % Plane wave
                %vel = singularity_type.vel{this_singularity}/abs(sum(vel)); % Ensure direction sums to 1
                activity_pattern = activity_pattern + exp(1i * (w*t + k*(vel(xdim)*x + vel(ydim)*y))).* gaussian_handle(c, loc).';

            case {'sink', 'source'}
                % Sink pattern
                activity_pattern = activity_pattern + exp(1i * (w*t + k*sqrt((x-loc(xdim)-vel(ydim)*t).^2 + ...
                    (y-loc(ydim)-vel(ydim)*t).^2))) .* gaussian_handle(c, loc).';

            case 'spiral'
                % Spiral wave
                activity_pattern = activity_pattern + ...
                    exp(1i*(-w*t + angle(x-loc(xdim)-vel(dim)*t + 1i*(y-loc(ydim)-vel(ydim)*t))- ...
                    k*sqrt((x-loc(xdim)-vel(xdim)*t).^2 + (y-loc(ydim)-vel(ydim)*t).^2))).* gaussian_handle(c, loc).' ;

            case 'saddle'
                % Saddle pattern
                activity_pattern = activity_pattern + exp(1i * (-w*t + k*abs(x-loc(xdim)-vel(xdim)*t) - ...
                    k*abs(y-loc(ydim)-vel(ydim)*t))) .* gaussian_handle(c, loc).';

            otherwise
                error(['patchflow:' mfilename ':NotImplemented'], ...
                       'Unknown singularity type. Use plane, source, sinkk or saddle.');
        end
        
        
    end

        
end
% function generate_activity_2d_rectangular()

% For EEG - MEG
function generate_activity_2d_disk()
% This function should generate activity natively on a disk OR
% use the topographic projection from a cloud of points in 3D to 2D
end

